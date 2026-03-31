/// WebDAV layout relative to configured root URL (trailing slash).
/// Source: `legado-master/app/src/main/java/io/legado/app/help/AppWebDav.kt`
class WebDavPaths {
  WebDavPaths._();

  static const defaultRootUrl = 'https://dav.jianguoyun.com/dav/';

  static const progressDir = 'bookProgress/';
  static const booksDir = 'books/';
  static const backgroundDir = 'background/';

  /// Preference keys (Android SharedPreferences / backup `config.xml`).
  /// Source: `legado-master/.../constant/PreferKey.kt`
  static const prefWebDavUrl = 'web_dav_url';
  static const prefWebDavAccount = 'web_dav_account';
  static const prefWebDavPassword = 'web_dav_password';
  static const prefWebDavDir = 'webDavDir';
}
