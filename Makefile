
default: help

OWRT_GIT_URL:=https://github.com/openwrt/openwrt
PACKAGES_GIT_URL:=https://github.com/openwrt/packages
LUCI_GIT_URL:=https://github.com/openwrt/luci

# FIXME: these need to be git hashes [for now]
OWRT_REV:=3d771602e99af29b4a194d81647a26a7af8c5784
PACKAGES_REV:=dc09a379134ba7e2b6ecc929507c6bf14c514f76
LUCI_REV:=479154eb340d24d7d82ed94d43f5a73e91e2e82b

# Set this, so that builds are reproduce-able
SOURCE_DATE_EPOCH ?= 1601246270

DL_CACHE_DFLT:=../../../dl-cache
DL_CACHE ?= $(DL_CACHE_DFLT)
LN ?= ln -sf
CP ?= cp -rf
RM := rm -rf

target_prepare_base:
	[ "$(DL_CACHE)" != "$(DL_CACHE_DFLT)" ] || [ -d dl-cache ] || mkdir dl-cache

NOT_PARALLEL_BUILDS:= \
	target_prepare_base

define iterate_devices
$(foreach vendor,$(filter-out generic,$(shell ls target)),$(foreach device,$(shell ls target/$(vendor)),$(call $(1),$(vendor),$(device))))
endef

define print_device
printf "\ttarget/$(1)/$(2)\n";
endef

help:
	@echo "nightsky targets:"
	@$(call iterate_devices,print_device)

define target_template

target/$(1)/$(2)/mkbuildir: target_prepare_base
	[ -e build/openwrt ] || ( \
		mkdir -p build ; \
		git clone $(OWRT_GIT_URL) build/openwrt ; \
	)
	[ -e build/$(1)/$(2) ] || ( \
		mkdir -p build/$(1)/$(2) ; \
		cd build/openwrt ; \
		git worktree add ../$(1)/$(2) ; \
	)
	( cd build/$(1)/$(2) ; git checkout $(OWRT_REV) )
	( \
		$(RM) build/$(1)/$(2)/files ; \
		mkdir -p build/$(1)/$(2)/files ; \
	)

target/$(1)/$(2)/feeds: target/$(1)/$(2)/mkbuildir
	echo "src-git packages $(PACKAGES_GIT_URL)^$(PACKAGES_REV)" > build/$(1)/$(2)/feeds.conf
	echo "src-git luci $(LUCI_GIT_URL)^$(LUCI_REV)" >> build/$(1)/$(2)/feeds.conf
	$(RM) build/$(1)/$(2)/dl
	$(LN) $(DL_CACHE) build/$(1)/$(2)/dl
	build/$(1)/$(2)/scripts/feeds update
	build/$(1)/$(2)/scripts/feeds install -a

target/$(1)/$(2)/config: target/$(1)/$(2)/feeds
	$(CP) target/$(1)/$(2)/config build/$(1)/$(2)/.config

target/$(1)/$(2)/defconfig: target/$(1)/$(2)/config
	make -C build/$(1)/$(2) defconfig
	$(CP) build/$(1)/$(2)/.config target/$(1)/$(2)/config

target/$(1)/$(2)/menuconfig: target/$(1)/$(2)/config
	make -C build/$(1)/$(2) menuconfig
	$(CP) build/$(1)/$(2)/.config target/$(1)/$(2)/config

target/$(1)/$(2): target/$(1)/$(2)/defconfig
	+make -C build/$(1)/$(2)

NOT_PARALLEL_BUILDS+= \
	target/$(1)/$(2)/mkbuildir \
	target/$(1)/$(2)/feeds \
	target/$(1)/$(2)/config \
	target/$(1)/$(2)/defconfig \
	target/$(1)/$(2)/menuconfig \

endef

$(eval $(call iterate_devices,target_template))

define build_dep
$(1)/$(2)
endef

define build_dep_defconfig
target/$(1)/$(2)/defconfig
endef

targets: $(call iterate_devices,build_dep)

all/defconfig: $(call iterate_devices,build_dep_defconfig)

.NOTPARALLEL: $(NOT_PARALLEL_BUILDS)

