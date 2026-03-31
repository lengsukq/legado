# Legado 备份与 WebDAV 兼容说明（Flutter 侧）

Kotlin 对照仓库（只读，勿改）：`legado-master/`。

## 备份 ZIP

生成逻辑：`legado-master/app/src/main/java/io/legado/app/help/storage/Backup.kt`（`backupFileNames` + `writeListToJson`）。

ZIP 内约定文件名（省略「无数据则可能不存在」说明，与官方一致即可）：

| 文件 | 含义 |
|------|------|
| bookshelf.json | 书架书籍列表 |
| bookmark.json | 书签 |
| bookGroup.json | 分组 |
| bookSource.json | 书源 |
| rssSources.json / rssStar.json | 订阅与收藏 |
| replaceRule.json | 替换规则 |
| readRecord.json | 阅读记录 |
| searchHistory.json | 搜索历史 |
| sourceSub.json | 订阅上传书源 |
| txtTocRule.json | TXT 目录规则 |
| httpTTS.json | 在线朗读引擎 |
| keyboardAssists.json | 键盘辅助 |
| dictRule.json | 字典规则 |
| servers.json | 朗读等服务（可能 Base64 AES，见 `BackupAES`） |
| directLinkUploadRule.json | 直链上传（`DirectLinkUpload.ruleFileName`） |
| readConfig.json / shareReadConfig.json | 阅读排版（`ReadBookConfig`） |
| themeConfig.json | 主题 |
| coverRule.json | 封面规则 |
| config.xml | 偏好备份（非 JSON） |

JSON 字段名需与 Kotlin `@Entity` / `data class` 的 Gson 默认命名一致（一般为 camelCase）。

## WebDAV 根 URL

实现：`legado-master/app/src/main/java/io/legado/app/help/AppWebDav.kt`。

拼接规则：

1. `PreferKey.web_dav_url`（`web_dav_url`）：为空则默认 `https://dav.jianguoyun.com/dav/`。
2. 保证以 `/` 结尾。
3. 若配置 `webDavDir`（`PreferKey.webDavDir`），再追加该相对路径并以 `/` 结尾。

相对于该根 URL 的固定子路径：

| 相对路径 | 用途 |
|----------|------|
| `bookProgress/` | 每本书阅读进度 JSON |
| `books/` | 书籍导出等 |
| `background/` | 阅读背景图上传 |

根目录下列表 `backup*.zip` 为备份包；最新备份选择逻辑见 `lastBackUp()`（按 `lastModify`）。

## 阅读进度 JSON

类型：`legado-master/app/src/main/java/io/legado/app/data/entities/BookProgress.kt`。

字段（JSON key 须一致）：

- `name`, `author`, `durChapterIndex`, `durChapterPos`, `durChapterTime`, `durChapterTitle`

远程文件名：`bookProgress/` + 对 `"{name}_{author}"` 做规范化与保留字替换（`normalizeFileName`、`UrlUtil.replaceReservedChar`）+ `.json`。

## SharedPreferences 键（WebDAV）

来自 `legado-master/.../constant/PreferKey.kt`：

- `web_dav_url`, `web_dav_account`, `web_dav_password`, `webDavDir`
- 同步开关等见 `AppConfig` / 恢复的 `config.xml` 流程（`Restore.kt`）

Flutter 实现备份恢复时，应对齐上述文件名与路径语义，以便与官方 Legado Android 互导。
