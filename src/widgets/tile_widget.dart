import 'package:flutter/material.dart';
import '../models/mahjong_tile.dart';

class TileWidget extends StatelessWidget {
  final MahjongTile tile;
  final int? orderNumber;
  final double size;

  const TileWidget({
    super.key,
    required this.tile,
    this.orderNumber,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        tile.imagePath,
        width: size,
        height: size * 1.4,
        fit: BoxFit.fill, // 흰 여백 없이 꽉 채움
        errorBuilder: (_, __, ___) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          tile.displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size * 0.18,
            fontWeight: FontWeight.bold,
            color: tile.suitColor,
          ),
        ),
      ),
    );
  }
}

class BackTileWidget extends StatelessWidget {
  final double size;

  const BackTileWidget({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: size,
        height: size * 1.4,
        color: const Color(0xFF111111),
        child: Center(
          child: Text('🀫', style: TextStyle(fontSize: size * 0.45)),
        ),
      ),
    );
  }
}
