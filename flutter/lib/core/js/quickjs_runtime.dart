import 'dart:convert';

import 'package:quickjs/quickjs.dart';

/// Thin wrapper around quickjs-dart sync engine.
///
/// 目标：提供一个简单的 `eval` 入口，后续再逐步填充与 Rhino 等价的上下文注入。
class QuickJsRuntime {
  QuickJsRuntime._() {
    _nativeManager = NativeEngineManager();
    _nativeEngine = NativeJsEngine(name: 'legado');
  }

  static final QuickJsRuntime instance = QuickJsRuntime._();

  late final NativeEngineManager _nativeManager;
  late final NativeJsEngine _nativeEngine;

  /// Evaluate JS code synchronously and return `result.value` as Dart value.
  ///
  /// 当前仅支持通过 JSON 注入简单参数：
  /// - 在 JS 中通过 `__args` 访问参数对象。
  /// 后续再逐步扩展为与 Rhino 一致的多对象注入。
  dynamic eval(String code, {Map<String, Object?> args = const {}}) {
    final argsJson = jsonEncode(args);
    final wrapped = StringBuffer()
      ..writeln('const __args = JSON.parse(${jsonEncode(argsJson)});')
      ..writeln(code);
    final result = _nativeEngine.eval(wrapped.toString());
    return result.value;
  }

  void dispose() {
    _nativeEngine.dispose();
    _nativeManager.dispose();
  }
}

