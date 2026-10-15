# SSI Cloud 服务端定制（对应源码 / Corresponding Source）

本仓库是 **生生国际事业部（SSI）** 在自建 Nextcloud 服务端（实例名 "SSI Cloud"）上所做修改的**对应源码**（AGPL-3.0 §13 网络交互条款），供使用该服务的用户获取。

This repository contains the corresponding source of the customizations made by Shengsheng International Business Division (SSI) to its self-hosted Nextcloud server instance ("SSI Cloud"), offered to its users per AGPL-3.0 section 13.

## 基线与许可

- 上游程序：**Nextcloud Server 34.0.4**（AGPL-3.0-or-later，源码：https://github.com/nextcloud/server ）。本仓库 **不含** 上游源码——上游本体未做代码级修改，官方源码即可获得。
- 本仓库内容许可：**AGPL-3.0-or-later**（与上游一致）。
- 安装的第三方应用（均取自官方发布、未修改，除下述第 4 条外）：groupfolders、assistant、integration_openai、ak_language_switcher。

## 修改清单（本仓库内容 = 修改的对应源码）

| # | 修改 | 对应文件/命令 |
|---|------|--------------|
| 1 | 自定义主题（l10n 覆盖：版权行、帮助入口、助手文案等） | `theme/ssicloud/`（路径与上游镜像：`apps/settings/l10n/*`、`custom_apps/assistant/l10n/*`）；启用=`occ config:system:set theme --value=ssicloud` |
| 2 | 界面定制 CSS（品牌色/去 NC 引导入口/首页瘦身样式/深色模式修复） | `css/ssicloud.css`；下发=`scripts/apply-css.sh`（写入 `theming_customcss` 并同步 bump cachebuster） |
| 3 | assistant 应用产物去 NC 化（JS bundle / l10n / PHP 常量中的品牌字样） | `scripts/debrand-assistant-js.sh` |
| 4 | 系统配置项 | 见下方"系统配置"小节 |

## 系统配置（occ）

```bash
occ config:system:set theme --value=ssicloud
occ config:system:set default_language --value=en
occ config:system:set defaultapp --value=files
occ config:system:set skeleton_directory --value=/var/www/html/data/skeleton-ssi   # 自定义骨架目录
occ app:disable firstrunwizard dashboard photos activity office
occ config:app:set theming_customcss customcss --value="$(cat css/ssicloud.css)"
occ config:app:set theming_customcss cachebuster --value="$(date +%s000)"
```

## 目录

```
theme/ssicloud/   # 自定义主题（l10n 覆盖文件）
css/ssicloud.css  # 定制 CSS（customcss 应用内容）
scripts/          # apply-css.sh（下发 CSS+bump cachebuster）、debrand-assistant-js.sh
```

## 备注

- 品牌字样（SSI Cloud / 生生国际事业部）仅用于事业部内部部署，不主张对 Nextcloud 项目任何权利。
- 本仓库随线上修改同步更新；升级上游/应用后部分改动需按 `scripts/` 重打。
