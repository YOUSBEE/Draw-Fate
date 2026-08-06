import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'mahjong_tile.dart';

class DrawSession {
  final String id;
  final DateTime createdAt;
  final List<MahjongTile> drawnTiles;
  final bool isComplete;

  DrawSession({
    String? id,
    DateTime? createdAt,
    required this.drawnTiles,
    required this.isComplete,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get tileCount => drawnTiles.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'drawnTiles': drawnTiles.map((t) => t.toJson()).toList(),
        'isComplete': isComplete,
      };

  factory DrawSession.fromJson(Map<String, dynamic> json) {
    return DrawSession(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      drawnTiles: (json['drawnTiles'] as List)
          .map((t) => MahjongTile.fromJson(t as Map<String, dynamic>))
          .toList(),
      isComplete: json['isComplete'] as bool,
    );
  }

  // 2026.08.05 Wed 08:55
  String get sessionLabel {
    final fmt = DateFormat('yyyy.MM.dd EEE HH:mm', 'ko');
    return fmt.format(createdAt);
  }

  String get statusLabel {
    if (isComplete) return '완료 (13패)';
    return '중단 (${tileCount}패)';
  }
}
