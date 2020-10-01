NightSky Firmware
===============================

This repo builds the firmwares for all devices supported by the NightSky project.

It basically downloads [OpenWrt](https://github.com/openwrt/openwrt/), the [packages](https://github.com/openwrt/packages/) and the [luci](https://github.com/openwrt/packages/) repositories and orchestrates the build around it.

The reason to do this, is to offer some sort of pre-configured "recipes" for building an OpenWrt image that just works with the [Nightsky mobile app](https://github.com/nightsky-project/mobile/)

Folder structure:

* **target** - contains the specific files for each supported board
 * contains OpenWrt configurations for each supported device in the `target/<vendor>/<device>/config` files
 * contains overlay rootfs files for each device in  `target/<vendor>/<device>/rootfs`
 * the `target/generic` is common stuff for all boards ; typically, what's in this folder gets applied first, then the data in `target/<vendor>/<device>/config`
* **build** - gets generated during build; the sub-folder structure is similar to **target** sub-folder structure (i.e. `target/<vendor>/<device>` )
* **dl__cache** - if no `DL_CACHE` env var exists this will be created to download all packages (archived) and re-use them between builds

Commands:

* running `make` will list all the supported devices/platforms
* then, running OpenWrt commands should work ; example for `target/ar71xx/tlwr740n-v4`
  * **make target/ar71xx/tlwr740n-v4** - builds the firmware for TP-Link WR740N V4
  * **target/ar71xx/tlwr740n-v4/<command>** - runs <command> for this target inside the `build/ar71xx/tlwr740n-v4` subfolder ; commands are `menuconfig`, `defconfig`, `feeds`, `mkbuildir`

Output is in the `build/<vendor>/<device>/bin/targets` subfolder. This will be optimized later for simplicity, but you need to take it out manually and install it on a device for now.
