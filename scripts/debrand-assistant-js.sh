#!/bin/bash
# SPDX-FileCopyrightText: 2026 Shengsheng International Business Division (SSI)
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# SSI Cloud：assistant 应用产物的去 Nextcloud 化（品牌替换）
#
# 说明：网页端的助手按钮文案/标题由编译产物（js bundle、l10n、PHP 常量）提供，
#       theme l10n 覆盖对浏览器端无效，需对应用本目录原地替换。
# ⚠️ 升级 assistant 应用会重置这些改动，升级后需重打本脚本。
set -e
C=${NC_CONTAINER:-nextcloud-app-1}
APP=/var/www/html/custom_apps/assistant

echo "== 备份（容器内 /tmp）=="
docker exec $C sh -c "cd $APP && tar czf /tmp/assistant-backup-\$(date +%s).tgz js l10n lib 2>/dev/null; ls -la /tmp/assistant-backup-*.tgz | tail -1"

echo "== JS bundle =="
docker exec $C sh -c "cd $APP && sed -i 's/Nextcloud Assistant/SSI Assistant/g' js/*.mjs"

echo "== l10n（.json 与 .js 都要改：浏览器端加载 .js）=="
docker exec $C sh -c "cd $APP && sed -i 's/Nextcloud Assistant/SSI Assistant/g; s/Nextcloud 助手/SSI 助手/g' l10n/*.json l10n/*.js"

echo "== PHP（聊天系统提示词/通知器）=="
docker exec $C sh -c "cd $APP && sed -i 's/Nextcloud Assistant/SSI Assistant/g' lib/AppInfo/Application.php lib/Notification/Notifier.php 2>/dev/null || true"

echo "DONE（opcache validate_timestamps=On 时即时生效）"
