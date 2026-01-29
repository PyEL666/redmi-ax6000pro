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

# --- 4. 终极修复 Rust 编译报错 ---
# 这一步是关键：即使 YML 设置了环境变量，Makefile 内部可能还会重新赋值或检测
# 我们直接修改 rust 包的 Makefile 和所有相关文件，强制它不使用 CI 逻辑

echo "Applying aggressive Rust build fix..."

# 1. 找到 rust 包的目录
RUST_PKG_DIR="package/feeds/packages/rust"

if [ -d "$RUST_PKG_DIR" ]; then
    echo "Found rust package directory: $RUST_PKG_DIR"
    
    # 强制将所有文件中的 download-ci-llvm = true 替换为 false
    # 这包括 Makefile, patches, 或者任何 config 模板
    grep -rl "download-ci-llvm = true" "$RUST_PKG_DIR" | xargs sed -i 's/download-ci-llvm = true/download-ci-llvm = false/g' || true
    
    # 专门处理 Makefile，防止它导出 GITHUB_ACTIONS 变量
    # 如果 Makefile 里有 export GITHUB_ACTIONS，强制改为 export GITHUB_ACTIONS=false
    find "$RUST_PKG_DIR" -name "Makefile" -exec sed -i 's/export GITHUB_ACTIONS/export GITHUB_ACTIONS=false/g' {} +
    
    echo "Rust build fix applied."
else
    echo "Warning: rust package directory not found at $RUST_PKG_DIR"
fi

# 2. 再次确保全局没有 GITHUB_ACTIONS 变量干扰
export GITHUB_ACTIONS=false
