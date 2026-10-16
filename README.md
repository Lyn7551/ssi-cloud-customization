# SSI Cloud 服务端定制（对应源码 / Corresponding Source）

本仓库是 **生生国际事业部（SSI）** 在自建 Nextcloud 服务端（实例名 "SSI Cloud"）上所做修改的**对应源码**（AGPL-3.0 §13 网络交互条款），供使用该服务的用户获取。

This repository contains the corresponding source of the customizations made by Shengsheng International Business Division (SSI) to its self-hosted Nextcloud server instance ("SSI Cloud"), offered to its users per AGPL-3.0 section 13.

## 基线与许可

- 上游程序：**Nextcloud Server 34.0.4**（AGPL-3.0-or-later，源码：https://github.com/nextcloud/server ）。本仓库 **不含** 上游源码——上游本体未做代码级修改，官方源码即可获得。
- 本仓库内容许可：**AGPL-3.0-or-later**（与上游一致）。
- 安装的第三方应用（均取自官方发布、未修改，除下述修改 3 外）：groupfolders、assistant、integration_openai、ak_language_switcher。

## 修改清单（本仓库内容 = 修改的对应源码）

| # | 修改 | 对应文件/命令 |
|---|------|--------------|
| 1 | 自定义主题（l10n 覆盖：版权行、帮助入口、助手文案等） | `theme/ssicloud/`（路径与上游镜像：`apps/settings/l10n/*`、`custom_apps/assistant/l10n/*`）；启用=`occ config:system:set theme --value=ssicloud` |
| 2 | 界面定制 CSS（品牌色/去 NC 引导入口/首页瘦身/深色模式修复/助手弹窗精修） | `css/ssicloud.css`；下发=`scripts/apply-css.sh`（写入 `theming_customcss` 并同步 bump cachebuster） |
| 3 | assistant 应用产物修改：品牌字样替换（JS bundle / l10n / PHP 常量）＋ l10n 数据级修复（占位符大小写、缺译补全） | `scripts/debrand-assistant-js.sh` |
| 4 | 新用户首登骨架（家目录模板文件） | `skeleton-ssi/`；启用=`occ config:system:set skeleton_directory --value=/var/www/html/data/skeleton-ssi` |
| 5 | 品牌资产（实例 Logo） | `assets/logo.png`（theming 上传源） |
| 6 | 系统配置项 | 见下方"系统配置"小节 |

## 系统配置（occ）

```bash
occ config:system:set theme --value=ssicloud
occ config:system:set default_language --value=en
occ config:system:set defaultapp --value=files
occ config:system:set skeleton_directory --value=/var/www/html/data/skeleton-ssi
occ app:disable firstrunwizard dashboard photos activity office
occ theming:config name "SSI Cloud"
occ theming:config primary_color "#0F766E"
occ theming:config background_color "#E6F4F2"
occ theming:config disable-user-theming true
occ config:app:set theming_customcss customcss --value="$(cat css/ssicloud.css)"
occ config:app:set theming_customcss cachebuster --value="$(date +%s000)"
```

> - Logo：管理界面「主题」上传 `assets/logo.png`（PNG，长条比例）。
> - 改 CSS 后必须走 `scripts/apply-css.sh`——命令行改 `customcss` **不会**自动 bump cachebuster，浏览器最长 24h 看不到变化。
> - 若部署容器名与脚本缺省（`nextcloud-app-1`）不同，运行时用 `NC_CONTAINER=<容器名>` 指定。

## 目录

```
theme/ssicloud/     # 自定义主题（l10n 覆盖文件）
css/ssicloud.css    # 定制 CSS（theming_customcss 内容）
scripts/            # apply-css.sh（下发 CSS+bump cachebuster）、debrand-assistant-js.sh（应用产物品牌替换+l10n 修复）
skeleton-ssi/       # 新用户骨架（首登家目录模板，含用户手册 PDF）
assets/             # 品牌资产（logo 等）
```

## 更新记录

- 2026-10-15：初版（theme / custom CSS / 脚本）。
- 2026-10-16：CSS 同步至线上最终版（深色模式修复 + 助手弹窗精修 v2）；debrand 脚本增补 l10n 数据级修复（改动与线上逐字核对通过、幂等）；新增 `skeleton-ssi/`（用户手册）与 `assets/logo.png`；补全 theming 配置命令。
- 2026-10-16（UIUX-R1）：CSS 增补——补回「隐 工作时间/流程」（v2 覆盖丢失）、隐共享页社交分享行、隐设置分组英文 caption（NC34 脚本时序问题）；theming 增补正确键名 `productName=SSI Cloud`（camelCase，修复联合云等 {productName} 占位符全局渲染 "Nextcloud"）；debrand 脚本增补：assistant 人工智慧→人工智能、通知设置去 NC Talk 提示（zh 译文+en 编译产物+zh 键名）。线上已验证：通知/共享页 0 残留、7 页 audit 0 命中。

## 备注

- 品牌字样（SSI Cloud / 生生国际事业部）仅用于事业部内部部署，不主张对 Nextcloud 项目任何权利。
- 本仓库随线上修改同步更新；升级上游/应用后部分改动需按 `scripts/` 重打。
- 敏感信息（服务器地址、凭据等）不进入本仓库。
