import 'package:uuid/uuid.dart';
import 'mahjong_tile.dart';

class DrawSession {
  final String id;
  final DateTime createdAt;
  final List<MahjongTile> drawnTiles; // in order of draw
  final bool isComplete; // true if 13 tiles drawn

  DrawSession({
    String? id,
    DateTime? createdAt,
    required this.drawnTiles,
    required this.isComplete,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  int get tileCount => drawnTiles.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'drawnTiles': drawnTiles.map((t) => t.toJson()).toList(),
      'isComplete': isComplete,
    };
  }

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

  String get sessionLabel {
    final time =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    final date =
        '${createdAt.month}/${createdAt.day}';
    return '$date $time';
  }

  String get statusLabel {
    if (isComplete) return '완료 (13패)';
    return '중단 (${tileCount}패)';
  }
}
