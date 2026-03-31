/// File names inside Legado backup ZIP (must match Gson field names in JSON bodies).
/// Source: `legado-master/app/src/main/java/io/legado/app/help/storage/Backup.kt` → `backupFileNames`
class BackupConstants {
  BackupConstants._();

  static const zipEntryNames = <String>[
    'bookshelf.json',
    'bookmark.json',
    'bookGroup.json',
    'bookSource.json',
    'rssSources.json',
    'rssStar.json',
    'replaceRule.json',
    'readRecord.json',
    'searchHistory.json',
    'sourceSub.json',
    'txtTocRule.json',
    'httpTTS.json',
    'keyboardAssists.json',
    'dictRule.json',
    'servers.json',
    'directLinkUploadRule.json',
    'readConfig.json',
    'shareReadConfig.json',
    'themeConfig.json',
    'coverRule.json',
    'config.xml',
  ];
}
