#!/bin/bash
# SPDX-FileCopyrightText: 2026 Shengsheng International Business Division (SSI)
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# SSI Cloud：下发 customcss + 同步推进 cachebuster
#
# 背景：occ 命令行修改 theming_customcss 不会自动 bump cachebuster，
#       浏览器按 cacheFor(86400) 最长 24h 沿用旧样式（"改了看不到"的头号原因）。
# 用法：把目标 CSS 放到容器 /tmp/ssicloud.css（或先用 docker cp 拷入），再运行本脚本。
set -e
C=${NC_CONTAINER:-nextcloud-app-1}
docker cp /tmp/ssicloud.css $C:/tmp/ssicloud.css
docker exec -u www-data $C sh -c 'php /var/www/html/occ config:app:set theming_customcss customcss --value="$(cat /tmp/ssicloud.css)"' | tail -1
TS=$(date +%s000)
docker exec -u www-data $C php /var/www/html/occ config:app:set theming_customcss cachebuster --value="$TS" | tail -1 | cut -c1-60
echo "cachebuster -> $TS"
docker exec -u www-data $C php /var/www/html/occ config:app:get theming_customcss customcss | tail -4
