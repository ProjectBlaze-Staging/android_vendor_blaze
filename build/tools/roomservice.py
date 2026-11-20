#!/usr/bin/env python3
# Copyright (C) 2012-2013, The CyanogenMod Project
#           (C) 2017-2024, The LineageOS Project
#           (C) 2026, The BlazeAOSP Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function

import glob
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from xml.etree import ElementTree

BLAZE_DEVICES_ORG = 'ProjectBlaze-Devices'
BLAZE_BRANCH = '17.0'
LINEAGE_FALLBACK_BRANCH = 'lineage-24.0'

dryrun = os.getenv('ROOMSERVICE_DRYRUN') == 'true'
if dryrun:
    print('Dry run roomservice, no change will be made.')

product = sys.argv[1]
depsonly = sys.argv[2] if len(sys.argv) > 2 else None

try:
    device = product[product.index('_') + 1 :]
except ValueError:
    device = product

local_manifests = r'.repo/local_manifests'
if not os.path.exists(local_manifests):
    os.makedirs(local_manifests)


def indent(elem, level=0):
    i = '\n' + level * '  '
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + '  '
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for child in elem:
            indent(child, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


def get_manifest_path():
    m = ElementTree.parse('.repo/manifest.xml')
    try:
        m.findall('default')[0]
        return '.repo/manifest.xml'
    except IndexError:
        return f'.repo/manifests/{m.find("include").get("name")}'


def get_from_manifest_project_paths(manifest_path):
    m = ElementTree.parse(manifest_path).getroot()
    return [x.get('path') for x in m.findall('project')]


def get_default_revision():
    m = ElementTree.parse(get_manifest_path())
    d = m.findall('default')[0]
    r = d.get('revision', LINEAGE_FALLBACK_BRANCH)
    return r.replace('refs/heads/', '').replace('refs/tags/', '')


def get_from_manifest(devicename):
    for path in glob.glob('.repo/local_manifests/*.xml'):
        try:
            lm = ElementTree.parse(path).getroot()
        except Exception:
            continue
        for localpath in lm.findall('project'):
            if re.search(rf'(?:android_)?device_.*_{re.escape(devicename)}$', localpath.get('name', '')):
                return localpath.get('path')
    return None


def is_in_manifest(tag, attr, attr_value):
    candidates = glob.glob('.repo/local_manifests/*.xml') + [
        get_manifest_path(),
        '.repo/manifests/snippets/lineage.xml',
        '.repo/manifests/snippets/blaze.xml',
    ]
    for path in candidates:
        if not os.path.exists(path):
            continue
        try:
            lm = ElementTree.parse(path).getroot()
        except Exception:
            continue
        for item in lm.findall(tag):
            if item.get(attr) == attr_value:
                return True
    return False


def list_remote_branches(repo_url):
    try:
        stdout = subprocess.run(
            ['git', 'ls-remote', '-h', repo_url],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=15,
        ).stdout.decode()
        return [line.split('refs/heads/')[-1] for line in stdout.splitlines() if 'refs/heads/' in line]
    except Exception:
        return []


def get_default_or_fallback_revision(repo_name, org='LineageOS'):
    branches = list_remote_branches(f'https://:@github.com/{org}/{repo_name}')
    preferred = [BLAZE_BRANCH, LINEAGE_FALLBACK_BRANCH] if org == BLAZE_DEVICES_ORG else [get_default_revision(), LINEAGE_FALLBACK_BRANCH]
    if os.getenv('ROOMSERVICE_BRANCHES'):
        preferred.extend(filter(bool, os.getenv('ROOMSERVICE_BRANCHES').split(' ')))
    for candidate in preferred:
        if candidate in branches:
            return candidate
    return ''


def add_to_manifest(dependencies, default_org='LineageOS'):
    if dryrun:
        return
    rs_path = '.repo/local_manifests/roomservice.xml'
    try:
        lm = ElementTree.parse(rs_path).getroot()
    except Exception:
        lm = ElementTree.Element('manifest')

    for dependency in dependencies:
        dependency_type = dependency.get('type', 'project')
        if dependency_type == 'kernel':
            include_name = f'manifests/snippets/kernel-{dependency["version"]}.xml'
            if is_in_manifest('include', 'name', include_name):
                continue
            lm.append(ElementTree.Element('include', attrib={'name': include_name}))
        elif dependency_type == 'project':
            repo_name = dependency['repository']
            repo_target = dependency['target_path']
            repo_revision = dependency.get('branch') or LINEAGE_FALLBACK_BRANCH
            org = dependency.get('org', default_org)
            full_name = repo_name if '/' in repo_name else f'{org}/{repo_name}'
            if is_in_manifest('project', 'path', repo_target):
                continue
            attrs = {
                'path': repo_target,
                'remote': dependency.get('remote', 'github'),
                'name': full_name,
                'revision': repo_revision,
            }
            if attrs['remote'].startswith('aosp-'):
                attrs['name'] = repo_name
                attrs['clone-depth'] = '1'
                del attrs['revision']
            print(f'Adding dependency: {attrs["name"]} -> {attrs["path"]} ({attrs.get("revision", "default")})')
            lm.append(ElementTree.Element('project', attrib=attrs))
        else:
            print(f'Unsupported dependency type: {dependency_type}')
            sys.exit(1)

    indent(lm, 0)
    raw_xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + ElementTree.tostring(lm).decode()
    with open(rs_path, 'w') as f:
        f.write(raw_xml)


def fetch_dependencies(repo_path):
    for fname in ('blaze.dependencies', 'lineage.dependencies'):
        dep_file = os.path.join(repo_path, fname)
        if os.path.exists(dep_file):
            dependencies_path = dep_file
            break
    else:
        print(f'{repo_path} has no additional dependencies.')
        return

    with open(dependencies_path, 'r') as f:
        dependencies = json.load(f)

    fetch_list = []
    syncable_repos = []
    verify_repos = []
    for dependency in dependencies:
        dependency_type = dependency.get('type', 'project')
        if dependency_type == 'kernel':
            include_name = f'manifests/snippets/kernel-{dependency["version"]}.xml'
            if not is_in_manifest('include', 'name', include_name):
                fetch_list.append(dependency)
                syncable_repos += get_from_manifest_project_paths(f'.repo/{include_name}')
        elif dependency_type == 'project':
            if not is_in_manifest('project', 'path', dependency['target_path']):
                if 'branch' not in dependency:
                    dependency['branch'] = get_default_or_fallback_revision(
                        dependency['repository'], dependency.get('org', 'LineageOS')
                    )
                    if not dependency['branch']:
                        sys.exit(1)
                fetch_list.append(dependency)
                syncable_repos.append(dependency['target_path'])
            verify_repos.append(dependency['target_path'])
            if not os.path.isdir(dependency['target_path']):
                syncable_repos.append(dependency['target_path'])

    if fetch_list:
        add_to_manifest(fetch_list)
    if syncable_repos and not dryrun:
        subprocess.run(['repo', 'sync', '--force-sync'] + list(dict.fromkeys(syncable_repos)))
    for deprepo in verify_repos:
        fetch_dependencies(deprepo)


def find_in_blaze_devices(devicename):
    api_url = f'https://api.github.com/search/repositories?q={devicename}+in:name+org:{BLAZE_DEVICES_ORG}'
    headers = {}
    token = os.getenv('GITHUB_TOKEN')
    if token:
        headers['Authorization'] = f'Bearer {token}'
    try:
        req = urllib.request.Request(api_url, headers=headers)
        data = json.loads(urllib.request.urlopen(req, timeout=10).read().decode())
        for item in data.get('items', []):
            name = item['name']
            m = re.match(rf'^(?:android_)?device_([^_]+)_{re.escape(devicename)}$', name)
            if m:
                rev = get_default_or_fallback_revision(name, BLAZE_DEVICES_ORG)
                if rev:
                    return BLAZE_DEVICES_ORG, name, f'device/{m.group(1)}/{devicename}', rev
    except Exception:
        pass
    return None


def find_in_lineage_mirror(devicename):
    try:
        req = urllib.request.Request('https://raw.githubusercontent.com/LineageOS/mirror/main/default.xml')
        result = ElementTree.fromstring(urllib.request.urlopen(req, timeout=10).read().decode())
        for res in result.findall('.//project'):
            name = res.attrib['name'][10:]
            m = re.match(rf'^android_device_([^_]+)_{re.escape(devicename)}$', name)
            if m:
                rev = get_default_or_fallback_revision(name, 'LineageOS')
                if rev:
                    return 'LineageOS', name, f'device/{m.group(1)}/{devicename}', rev
    except Exception as e:
        print(f'Failed to query LineageOS mirror: {e}')
    return None


if depsonly:
    repo_path = get_from_manifest(device)
    if repo_path:
        fetch_dependencies(repo_path)
    else:
        print('Trying dependencies-only mode on a non-existing device tree?')
    sys.exit(0)

print(f'Device {device} not found. Searching {BLAZE_DEVICES_ORG} ({BLAZE_BRANCH}) then LineageOS ({LINEAGE_FALLBACK_BRANCH})...')
match = find_in_blaze_devices(device) or find_in_lineage_mirror(device)
if match:
    org, repo_name, repo_path, revision = match
    print(f'Found repository: {org}/{repo_name} ({revision})')
    add_to_manifest([{'org': org, 'repository': repo_name, 'target_path': repo_path, 'branch': revision}], default_org=org)
    if not dryrun:
        subprocess.run(['repo', 'sync', '--force-sync', repo_path])
    fetch_dependencies(repo_path)
    print('Done')
    sys.exit(0)

print(f'Repository for {device} not found in {BLAZE_DEVICES_ORG} or LineageOS. Add it manually to .repo/local_manifests/roomservice.xml.')
sys.exit(1)
