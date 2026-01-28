#!/bin/bash
#
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# --- 1. 系统设置 ---

# 修改默认 IP 为 192.168.6.1 (符合你的原仓库习惯)
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# 设置默认密码为空 (方便首次登录，无需密码)
sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# --- 2. 清理不需要的预置插件 ---
# 有些固件源会自动集成 adguardhome 或其他重型插件，这里强制删除以防万一
rm -rf feeds/luci/applications/luci-app-adguardhome
rm -rf feeds/packages/net/adguardhome

# --- 3. 针对 TurboACC 的一些修正 (可选，预防冲突) ---
# 如果编译时遇到 shortcut-fe 相关的报错，可以尝试取消下面的注释
# sed -i 's/"turboacc"/"package"/g' package/feeds/luci/luci-app-turboacc/root/etc/config/turboacc

# --- 修复 Rust 编译报错 (暴力修正版) ---
# 1. 强制关闭 download-ci-llvm
find package/feeds/packages/rust -name "Makefile" -exec sed -i 's/download-ci-llvm = true/download-ci-llvm = false/g' {} +

# 2. 有些 rust 版本会检查 GITHUB_ACTIONS 变量，这里我们在编译脚本里也 unset 掉它
sed -i '/PKG_BUILD_PARALLEL/a\export GITHUB_ACTIONS=false' package/feeds/packages/rust/Makefile
