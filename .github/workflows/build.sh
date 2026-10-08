#!/bin/sh
set -eu

cd /builder

archive_logs() {
	status=$?
	trap - 0
	if [ -d logs ]; then
		mkdir -p bin && tar -cJf bin/logs.tar.xz logs || :
	fi
	exit "$status"
}
trap archive_logs 0

if [ ! -d ./scripts ]; then
	./setup.sh
fi

sed -i 's/git\.openwrt\.org\/project\/luci/github\.com\/openwrt\/luci/g' ./feeds.conf.default
# The SDK keeps core dependencies (OpenSSL, zlib, jsonfilter) in the base feed.
# Index it before installing packages so their dependencies can be resolved.
./scripts/feeds update base packages luci
./scripts/feeds install -a -p base
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p luci
mv ./bin/luci-app-argon-config ./package/
mv ./bin/luci-theme-argon ./package/

cat >> .config <<'CONFIG'
CONFIG_PACKAGE_luci-theme-argon=m
CONFIG_PACKAGE_luci-app-argon-config=m
CONFIG_PACKAGE_luci-i18n-argon-config-ar=m
CONFIG_PACKAGE_luci-i18n-argon-config-de=m
CONFIG_PACKAGE_luci-i18n-argon-config-es=m
CONFIG_PACKAGE_luci-i18n-argon-config-fr=m
CONFIG_PACKAGE_luci-i18n-argon-config-it=m
CONFIG_PACKAGE_luci-i18n-argon-config-ja=m
CONFIG_PACKAGE_luci-i18n-argon-config-ko=m
CONFIG_PACKAGE_luci-i18n-argon-config-nl=m
CONFIG_PACKAGE_luci-i18n-argon-config-pl=m
CONFIG_PACKAGE_luci-i18n-argon-config-pt-br=m
CONFIG_PACKAGE_luci-i18n-argon-config-ru=m
CONFIG_PACKAGE_luci-i18n-argon-config-tr=m
CONFIG_PACKAGE_luci-i18n-argon-config-uk=m
CONFIG_PACKAGE_luci-i18n-argon-config-vi=m
CONFIG_PACKAGE_luci-i18n-argon-config-zh-cn=m
CONFIG_PACKAGE_luci-i18n-argon-config-zh-tw=m
CONFIG

make defconfig
make package/luci-app-argon-config/compile V=s -j$(nproc) BUILD_LOG=1

package_file="$(find bin/packages -type f \( -name 'luci-app-argon-config*.ipk' -o -name 'luci-app-argon-config*.apk' \) -print -quit)"
if [ -z "$package_file" ]; then
	echo 'Build did not produce luci-app-argon-config package' >&2
	exit 1
fi
