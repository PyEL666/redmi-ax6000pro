#!/bin/bash
#
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# --- 1. 清理原仓库可能自带的插件源 (Passwall, Alist, HelloWorld 等) ---
# 使用 sed 命令删除 feeds.conf.default 中包含 passwall, alist, helloworld 的行
# 这样 update feeds 时就不会拉取这些你不需要的插件
sed -i '/passwall/d' feeds.conf.default
sed -i '/helloworld/d' feeds.conf.default
sed -i '/alist/d' feeds.conf.default

# --- 2. 添加你需要的自定义插件源码 ---

# 添加 UA3F (校园网防检测)
# 对应菜单: Network -> Web Servers/Proxies -> ua3f
git clone https://github.com/SunBK201/UA3F.git package/UA3F

# 添加 MiniEAP (校园网 802.1x 认证)
# 对应菜单: LuCI -> Applications -> luci-app-minieap
git clone https://github.com/BoringCat/minieap-openwrt.git package/minieap
git clone https://github.com/BoringCat/luci-app-minieap.git package/luci-app-minieap

# 添加 Open App Filter (OAF 应用过滤 - 国内版)
# 对应菜单: LuCI -> Applications -> luci-app-oaf
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 至于 TurboACC、SQM、Adblock-Fast、OpenClash：
# ImmortalWrt 源里通常自带 TurboACC/SQM/Adblock-Fast，不需要这里 clone。
# OpenClash 如果仓库里没有，可以取消下面这行的注释(#)来添加：
# git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash


