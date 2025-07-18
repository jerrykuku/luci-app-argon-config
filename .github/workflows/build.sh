#!/bin/sh

PKG_PATH="$(readlink -f .)"

cd /builder
sed -i 's/git\.openwrt\.org\/project\/luci/github\.com\/openwrt\/luci/g' ./feeds.conf.default
./scripts/feeds update luci
./scripts/feeds install luci
ln -sv "$PKG_PATH" "./package/"
make defconfig
make package/luci-app-argon-config/compile V=s -j$(nproc) BUILD_LOG=1

tar -cJf logs.tar.xz logs
mv logs.tar.xz bin
