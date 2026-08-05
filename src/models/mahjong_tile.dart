import 'package:flutter/material.dart';

enum TileSuit { man, pin, sou, honor }

enum HonorType { east, south, west, north, haku, hatsu, chun }

class MahjongTile {
  final TileSuit suit;
  final int? number;
  final HonorType? honorType;
  final bool isAkaDora; // 아카 도라 (빨간 5)

  const MahjongTile({
    required this.suit,
    this.number,
    this.honorType,
    this.isAkaDora = false,
  });

  String get displayName {
    final aka = isAkaDora ? '(적)' : '';
    switch (suit) {
      case TileSuit.man:
        return '$number만$aka';
      case TileSuit.pin:
        return '$number통$aka';
      case TileSuit.sou:
        return '$number삭$aka';
      case TileSuit.honor:
        switch (honorType!) {
          case HonorType.east:  return '동';
          case HonorType.south: return '남';
          case HonorType.west:  return '서';
          case HonorType.north: return '북';
          case HonorType.haku:  return '백';
          case HonorType.hatsu: return '발';
          case HonorType.chun:  return '중';
        }
    }
  }

  /// assets/tiles/ 아래 이미지 파일 경로
  String get imagePath {
    switch (suit) {
      case TileSuit.man:
        if (isAkaDora) return 'assets/tiles/man5r.png';
        return 'assets/tiles/man$number.png';
      case TileSuit.pin:
        if (isAkaDora) return 'assets/tiles/pin5r.png';
        return 'assets/tiles/pin$number.png';
      case TileSuit.sou:
        if (isAkaDora) return 'assets/tiles/sou5r.png';
        return 'assets/tiles/sou$number.png';
      case TileSuit.honor:
        switch (honorType!) {
          case HonorType.east:  return 'assets/tiles/wind_east.png';
          case HonorType.south: return 'assets/tiles/wind_south.png';
          case HonorType.west:  return 'assets/tiles/wind_west.png';
          case HonorType.north: return 'assets/tiles/wind_north.png';
          case HonorType.haku:  return 'assets/tiles/dragon_haku.png';
          case HonorType.hatsu: return 'assets/tiles/dragon_hatsu.png';
          case HonorType.chun:  return 'assets/tiles/dragon_chun.png';
        }
    }
  }

  Color get suitColor {
    if (isAkaDora) return const Color(0xFFFF1744); // 아카는 항상 빨간색
    switch (suit) {
      case TileSuit.man:
        return const Color(0xFFE53935);
      case TileSuit.pin:
        return const Color(0xFF1565C0);
      case TileSuit.sou:
        return const Color(0xFF2E7D32);
      case TileSuit.honor:
        if (honorType == HonorType.haku)  return const Color(0xFF757575);
        if (honorType == HonorType.hatsu) return const Color(0xFF2E7D32);
        if (honorType == HonorType.chun)  return const Color(0xFFE53935);
        return const Color(0xFF6A1B9A);
    }
  }

  Map<String, dynamic> toJson() => {
        'suit': suit.index,
        'number': number,
        'honorType': honorType?.index,
        'isAkaDora': isAkaDora,
      };

  factory MahjongTile.fromJson(Map<String, dynamic> json) {
    return MahjongTile(
      suit: TileSuit.values[json['suit'] as int],
      number: json['number'] as int?,
      honorType: json['honorType'] != null
          ? HonorType.values[json['honorType'] as int]
          : null,
      isAkaDora: json['isAkaDora'] as bool? ?? false,
    );
  }

  @override
  String toString() => displayName;
}

class MahjongDeck {
  /// 실제 마작 전체 덱: 136장 + 아카도라 3장 = 139장
  ///
  /// - 만·통·삭 각 9종 × 4장 = 108장
  /// - 자패 7종 × 4장 = 28장
  /// - 아카도라: 5만·5통·5삭 각 1장 (일반 5 중 1장을 교체)
  ///   → 일반 5: 각 3장, 아카 5: 각 1장
  static List<MahjongTile> get fullDeck {
    final deck = <MahjongTile>[];

    for (final suit in [TileSuit.man, TileSuit.pin, TileSuit.sou]) {
      for (int n = 1; n <= 9; n++) {
        final copies = n == 5 ? 3 : 4; // 5는 일반 3장 + 아카 1장
        for (int c = 0; c < copies; c++) {
          deck.add(MahjongTile(suit: suit, number: n));
        }
        if (n == 5) {
          deck.add(MahjongTile(suit: suit, number: 5, isAkaDora: true));
        }
      }
    }

    // 자패: 각 4장
    for (final honor in HonorType.values) {
      for (int c = 0; c < 4; c++) {
        deck.add(MahjongTile(suit: TileSuit.honor, honorType: honor));
      }
    }

    return deck; // 총 139장
  }
}
