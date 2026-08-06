import 'package:flutter/material.dart';
import '../models/draw_session.dart';
import '../models/mahjong_tile.dart';
import '../widgets/tile_widget.dart';
import 'game_screen.dart' show kAccent, kBgBlack, kSurfaceBlack, kCardBlack;

class SessionDetailScreen extends StatelessWidget {
  final DrawSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlack,
      appBar: AppBar(
        backgroundColor: kBgBlack,
        foregroundColor: kAccent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '운명 상세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kAccent,
              ),
            ),
            Text(
              session.sessionLabel,
              style: const TextStyle(fontSize: 12, color: Colors.white38),
            ),
          ],
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kAccent.withOpacity(0.3)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 배지
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: session.isComplete
                            ? kAccent
                            : Colors.orange[400]!,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      session.statusLabel,
                      style: TextStyle(
                        color: session.isComplete
                            ? kAccent
                            : Colors.orange[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '뽑기 순서대로 표시',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 패 — 2/4/4/2/1 행 패턴 (가운데 정렬)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildRowPattern(session.drawnTiles),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              _buildSummary(),
            ],
          ),
        ),
      ),
    );
  }

  static const _rowPattern = [2, 4, 4, 2, 1];

  List<Widget> _buildRowPattern(List tiles) {
    final rows = <Widget>[];
    int cursor = 0;
    for (final count in _rowPattern) {
      if (cursor >= tiles.length) break;
      final end = (cursor + count).clamp(0, tiles.length);
      final rowTiles = tiles.sublist(cursor, end);
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rowTiles.map<Widget>((tile) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: TileWidget(tile: tile, size: 56),
            )).toList(),
          ),
        ),
      );
      cursor += count;
    }
    return rows;
  }

  Widget _buildSummary() {
    final counts = <String, int>{
      '만수': 0,
      '통수': 0,
      '삭수': 0,
      '자패': 0,
      '적도라': 0,
    };
    for (final tile in session.drawnTiles) {
      if (tile.isAkaDora) counts['적도라'] = counts['적도라']! + 1;
      switch (tile.suit) {
        case TileSuit.man:
          counts['만수'] = counts['만수']! + 1;
          break;
        case TileSuit.pin:
          counts['통수'] = counts['통수']! + 1;
          break;
        case TileSuit.sou:
          counts['삭수'] = counts['삭수']! + 1;
          break;
        case TileSuit.honor:
          counts['자패'] = counts['자패']! + 1;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccent.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: counts.entries
            .map((e) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${e.value}',
                      style: TextStyle(
                        color: e.key == '적도라'
                            ? const Color(0xFFFF1744)
                            : kAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      e.key,
                      style: TextStyle(
                        color: e.key == '적도라'
                            ? const Color(0xFFFF8A80)
                            : Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
