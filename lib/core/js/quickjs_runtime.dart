/// QuickJS runtime shim.
///
/// 为了先让桌面端（如 Windows）可以顺利编译运行，这里暂时提供一个空实现。
/// 后续如果需要在桌面端启用 JS 解析，再替换为 `quickjs` 的真实绑定实现。
class QuickJsRuntime {
  QuickJsRuntime._();

  static final QuickJsRuntime instance = QuickJsRuntime._();

  dynamic eval(String code, {Map<String, Object?> args = const {}}) {
    throw UnimplementedError('QuickJsRuntime is not available on this platform yet.');
  }

  void dispose() {}
}

