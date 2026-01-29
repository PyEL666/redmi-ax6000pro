#!/bin/bash
#
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# --- 1. 系统设置 ---
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# --- 2. 清理不需要的预置插件 ---
rm -rf feeds/luci/applications/luci-app-adguardhome
rm -rf feeds/packages/net/adguardhome

# --- 3. 终极修复 Rust 编译报错 (精准打击版) ---
echo "Searching for Rust Makefile..."

# 使用 find 命令模糊查找 rust 的 Makefile，不管它藏在 lang 还是其他目录下
RUST_MAKEFILE=$(find package -wholename "*/lang/rust/Makefile" 2>/dev/null || find package -name Makefile | grep "/rust/Makefile" | head -n 1)

if [ -f "$RUST_MAKEFILE" ]; then
    echo "Found Rust Makefile at: $RUST_MAKEFILE"
    
    # 核心修复：替换掉 Makefile 中硬编码的开启命令
    # 匹配 --set=llvm.download-ci-llvm=true 并改为 false
    sed -i 's/--set=llvm.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/g' "$RUST_MAKEFILE"
    
    # 双重保险：防止有其他格式的写法
    sed -i 's/download-ci-llvm = true/download-ci-llvm = false/g' "$RUST_MAKEFILE"
    
    echo "Fixed: Disabled llvm.download-ci-llvm in $RUST_MAKEFILE"
else
    echo "ERROR: Rust Makefile not found! Fix script failed."
fi

# 移除全局 GITHUB_ACTIONS 变量干扰 (双重保险)
export GITHUB_ACTIONS=false

