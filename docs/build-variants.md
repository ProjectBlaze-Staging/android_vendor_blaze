# BlazeAOSP build variants

BlazeAOSP defaults to a fully buildable vanilla image. The optional
`litegapps` variant is kept separate so proprietary Google packages never
enter the public Blaze source repositories.

## Vanilla

```bash
source build/envsetup.sh
export BLAZE_BUILD_VARIANT=vanilla
lunch lineage_bluejay-cp2a-userdebug
m bacon
```

`BLAZE_BUILD_VARIANT` may be omitted for vanilla builds.

## LiteGApps-integrated image

Provide a legally obtained, Android 17-compatible partner tree at
`vendor/partner_gms`. It must expose
`products/gms_minimal.mk`, or set `GMS_MAKEFILE` to another product makefile
within that directory.

```bash
source build/envsetup.sh
export BLAZE_BUILD_VARIANT=litegapps
export GMS_MAKEFILE=gms_minimal.mk
lunch lineage_bluejay-cp2a-userdebug
m bacon
```

The build intentionally fails during product configuration when the partner
tree is absent. The public LiteGApps project distributes a separately
installable package; it is not itself an Android `vendor/partner_gms` source
tree and must not be added to the manifest under that path.

Every image records its flavor in `ro.blaze.build.variant`.
