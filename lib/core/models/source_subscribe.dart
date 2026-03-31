import 'dart:convert';

/// 订阅源记录，参考原版 SourceSubscribe 的精简字段。
class SourceSubscribe {
  const SourceSubscribe({
    required this.name,
    required this.url,
    required this.enabled,
    required this.lastUpdateTime,
    this.group,
    this.order,
    this.failCount = 0,
  });

  final String name;
  final String url;
  final bool enabled;
  final int lastUpdateTime;
  final String? group;
  final int? order;
  final int failCount;

  SourceSubscribe copyWith({
    String? name,
    String? url,
    bool? enabled,
    int? lastUpdateTime,
    String? group,
    int? order,
    int? failCount,
  }) {
    return SourceSubscribe(
      name: name ?? this.name,
      url: url ?? this.url,
      enabled: enabled ?? this.enabled,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      group: group ?? this.group,
      order: order ?? this.order,
      failCount: failCount ?? this.failCount,
    );
  }

  factory SourceSubscribe.fromJson(Map<String, dynamic> j) {
    return SourceSubscribe(
      name: j['name'] as String? ?? '',
      url: j['url'] as String? ?? '',
      enabled: (j['enabled'] as bool?) ?? true,
      lastUpdateTime: (j['lastUpdateTime'] as num?)?.toInt() ?? 0,
      group: j['group'] as String?,
      order: (j['order'] as num?)?.toInt(),
      failCount: (j['failCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'enabled': enabled,
        'lastUpdateTime': lastUpdateTime,
        if (group != null) 'group': group,
        if (order != null) 'order': order,
        'failCount': failCount,
      };

  static List<SourceSubscribe> listFromJsonString(String s) {
    final raw = json.decode(s);
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(SourceSubscribe.fromJson)
          .toList();
    }
    return <SourceSubscribe>[];
  }

  static String listToJsonString(List<SourceSubscribe> items) {
    final raw = items.map((e) => e.toJson()).toList();
    return json.encode(raw);
  }
}

