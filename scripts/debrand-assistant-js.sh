#!/bin/bash
# SPDX-FileCopyrightText: 2026 Shengsheng International Business Division (SSI)
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# SSI Cloud：assistant 应用产物的去 Nextcloud 化（品牌替换）＋ l10n 数据级修复
#
# 说明：网页端的助手按钮文案/标题由编译产物（js bundle、l10n、PHP 常量）提供，
#       theme l10n 覆盖对浏览器端无效，需对应用本目录原地替换。
# ⚠️ 升级 assistant 应用会重置这些改动，升级后需重打本脚本。
# 用法：NC_CONTAINER=<容器名> bash debrand-assistant-js.sh   # 容器名缺省 nextcloud-app-1
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

echo "== l10n 数据级修复（非品牌替换，勿略）=="
# ① 占位符大小写：中文包 "{taskTypename}"（小写 n）与代码参数 {taskTypeName} 大小写不一致 → 空状态页裸奔占位符
docker exec $C sh -c "cd $APP && sed -i 's/{taskTypename}/{taskTypeName}/g' l10n/zh_CN.json l10n/zh_CN.js"
# ② 缺译补全："Remember this" 中文包缺翻译 → 补 "记住此对话"（幂等：已存在则跳过）
docker exec $C sh -c "cd $APP && grep -q '记住此对话' l10n/zh_CN.json || sed -i 's/{ \"translations\": {/&\n    \"Remember this\" : \"记住此对话\",/' l10n/zh_CN.json"
docker exec $C sh -c "cd $APP && grep -q '记住此对话' l10n/zh_CN.js || sed -i '0,/^[[:space:]]*{[[:space:]]*$/s//&\n    \"Remember this\" : \"记住此对话\",/' l10n/zh_CN.js"
# ③ 大陆用语：人工智慧 → 人工智能（UIUX-R1，zh_TW 包不动）
docker exec $C sh -c "cd $APP && sed -i 's/人工智慧/人工智能/g' l10n/zh_CN.json l10n/zh_CN.js"

echo "== UIUX-R1 追加：notifications / settings / theming（同纪律，升级后重打）=="
NC=/var/www/html
# ④ 通知设置去掉 NC Talk 提示（未装 Talk）：zh 译文 + en 源串（编译产物内）+ zh 键名同步
docker exec $C sh -c "sed -i 's/通话开始时播放提示音（需要Nextcloud通话应用）/通话开始时播放提示音/g' $NC/apps/notifications/l10n/zh_CN.js $NC/apps/notifications/l10n/zh_CN.json"
docker exec $C sh -c "sed -i 's/Play sound when a call started (requires Nextcloud Talk)/Play sound when a call starts/g' $NC/apps/notifications/js/notifications-settings.mjs $NC/apps/notifications/js/notifications-admin-settings.mjs"
docker exec $C sh -c "sed -i 's/\"Play sound when a call started (requires Nextcloud Talk)\" :/\"Play sound when a call starts\" :/' $NC/apps/notifications/l10n/zh_CN.js $NC/apps/notifications/l10n/zh_CN.json"
# ⑤ theming productName 正确键名（camelCase）：联合云等 {productName} 占位符全局生效
docker exec -u www-data $C php $NC/occ config:app:set theming productName --value="SSI Cloud"
# ⑦ UIUX-R9：行菜单"AI Assistant"品牌化（bundle 源串 + zh 缺译补"SSI 助手"，幂等）
docker exec $C sh -c "sed -i 's/AI Assistant/SSI Assistant/g' $NC/custom_apps/assistant/js/assistant-fileActions.mjs 2>/dev/null || true"
docker exec $C sh -c "grep -q 'AI Assistant' $NC/custom_apps/assistant/l10n/zh_CN.json 2>/dev/null || sed -i 's/{ \"translations\": {/&\n    \"AI Assistant\" : \"SSI 助手\",/' $NC/custom_apps/assistant/l10n/zh_CN.json"
docker exec $C sh -c "grep -q 'AI Assistant' $NC/custom_apps/assistant/l10n/zh_CN.js 2>/dev/null || sed -i '0,/^[[:space:]]*{[[:space:]]*$/s//&\n    \"AI Assistant\" : \"SSI 助手\",/' $NC/custom_apps/assistant/l10n/zh_CN.js"
# ⑥ 联合云 en 冠词语法："a {productName}" → "an {productName}"（新建 en l10n，不影响其他语言；UIUX-R5）
docker exec $C sh -c 'F=/var/www/html/apps/federatedfilesharing/l10n; [ -f $F/en.js ] || cat > $F/en.js <<'"'"'EOF'"'"'
OC.L10N.register(
    "federatedfilesharing",
    {
    "You can share with anyone who uses a {productName} server or other Open Cloud Mesh (OCM) compatible servers and services! Just put their Federated Cloud ID in the share dialog. It looks like person@cloud.example.com" : "You can share with anyone who uses an {productName} server or other Open Cloud Mesh (OCM) compatible servers and services! Just put their Federated Cloud ID in the share dialog. It looks like person@cloud.example.com",
    "Share with me via {productName}" : "Share with me via {productName}"
},
"nplurals=2; plural=(n != 1);");
EOF'
docker exec $C sh -c 'F=/var/www/html/apps/federatedfilesharing/l10n; [ -f $F/en.json ] || cat > $F/en.json <<'"'"'EOF'"'"'
{ "translations": {
    "You can share with anyone who uses a {productName} server or other Open Cloud Mesh (OCM) compatible servers and services! Just put their Federated Cloud ID in the share dialog. It looks like person@cloud.example.com" : "You can share with anyone who uses an {productName} server or other Open Cloud Mesh (OCM) compatible servers and services! Just put their Federated Cloud ID in the share dialog. It looks like person@cloud.example.com",
    "Share with me via {productName}" : "Share with me via {productName}"
}, "pluralForm": "nplurals=2; plural=(n != 1);" }
EOF'
docker exec $C sh -c 'chown www-data:www-data /var/www/html/apps/federatedfilesharing/l10n/en.js /var/www/html/apps/federatedfilesharing/l10n/en.json 2>/dev/null || true'

# ⑨ UIUX-R9：files 侧栏搜索占位符改名（与顶栏统一搜索职责区分）；「自由文本提示」误译修正（lib 域）
docker exec $C sh -c "python3 - <<'PYEOF'
import io
pairs = [
    ('/var/www/html/apps/files/l10n/zh_CN.json', None),
    ('/var/www/html/apps/files/l10n/zh_CN.js', None),
    ('/var/www/html/lib/l10n/zh_CN.json', None),
    ('/var/www/html/lib/l10n/zh_CN.js', None),
]
for path, _ in pairs:
    try:
        t = io.open(path, encoding='utf-8').read()
    except FileNotFoundError:
        continue
    for a, b in [('"在此搜索 …"', '"筛选当前列表 …"'), ('"在此搜索"', '"筛选当前列表"'), ('免费文本转文本提示', '自由文本提示')]:
        t = t.replace(a, b)
    io.open(path, 'w', encoding='utf-8').write(t)
print('r9 string fixes applied')
PYEOF"

# ⑧ l10n .json/.js 改动需清 APCu（l10n 解析缓存按进程驻留）：graceful 重启
docker exec $C apachectl graceful || true

echo "DONE（opcache validate_timestamps=On + apachectl graceful 已清 APCu）"
