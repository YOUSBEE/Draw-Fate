import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/tile_widget.dart';
import 'history_screen.dart';

// 네온 그린 (눈에 덜 부담스러운 톤)
const kAccent = Color(0xFF00E676);
const kAccentDim = Color(0xFF00C853);
const kBgBlack = Color(0xFF0A0A0A);
const kSurfaceBlack = Color(0xFF111111);
const kCardBlack = Color(0xFF1A1A1A);

// 패 넘버링 & 테두리 공용 컬러
const kTileAccent = Color(0xFF00E676);

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlack,
      appBar: AppBar(
        backgroundColor: kBgBlack,
        foregroundColor: kAccent,
        title: const Text(
          '운명의 마작패',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: kAccent,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: kAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: '뽑기 기록',
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kAccent.withOpacity(0.25)),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildCounterBar(provider),
              Expanded(child: _buildTileArea(provider)),
              _buildButtons(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterBar(GameProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: kBgBlack,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '남은 패: ${provider.remainingCount}',
            style: TextStyle(
              color: provider.remainingCount == 0 ? kAccent : Colors.white54,
              fontSize: 14,
              fontWeight: provider.remainingCount == 0
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 2-4-4-2-1 행 패턴 (13장 기준, 부족하면 마지막 행까지만)
  static const _rowPattern = [2, 4, 4, 2, 1];

  Widget _buildTileArea(GameProvider provider) {
    if (!provider.hasTilesDrawn) {
      return const SizedBox.shrink();
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildRowPattern(provider.drawnTiles),
        ),
      ),
    );
  }

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

  Widget _buildButtons(BuildContext context, GameProvider provider) {
    final bool canDraw = provider.canDraw;
    final bool hasTiles = provider.hasTilesDrawn;
    final bool isPartial = hasTiles && !provider.isComplete;
    final bool isComplete = provider.isComplete;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: kSurfaceBlack,
          border: Border(
            top: BorderSide(color: kAccent.withOpacity(0.2), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isComplete) ...[
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '1개 뽑기',
                      icon: Icons.add_circle_outline,
                      color: kAccent,
                      onPressed: canDraw ? provider.drawOne : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: hasTiles ? '나머지 전부 뽑기' : '13개 뽑기',
                      icon: Icons.casino,
                      color: kAccent,
                      onPressed: canDraw ? provider.drawRemaining : null,
                    ),
                  ),
                ],
              ),
            ],
            if (isComplete) ...[
              _ActionButton(
                label: '저장',
                icon: Icons.save_alt,
                color: kAccent,
                onPressed: provider.saveAndReset,
                fullWidth: true,
              ),
            ],
            if (isPartial) ...[
              const SizedBox(height: 10),
              _ActionButton(
                label: '뽑기 중단',
                icon: Icons.stop_circle_outlined,
                color: kAccent,
                onPressed: () => _confirmStop(context, provider),
                fullWidth: true,
                outlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmStop(
      BuildContext context, GameProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: kAccent.withOpacity(0.3), width: 1),
        ),
        title: const Text(
          '뽑기 중단',
          style: TextStyle(color: kAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '현재까지 뽑은 ${provider.drawnCount}개의 패를 저장하시겠습니까?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: kBgBlack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('저장',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.saveAndReset();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
    this.outlined = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    Widget button;

    if (outlined) {
      button = OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: kAccent,
          side: BorderSide(
            color: isDisabled ? Colors.white24 : kAccent.withOpacity(0.7),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label:
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    } else {
      button = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.white12 : kAccent,
          foregroundColor: isDisabled ? Colors.white38 : kBgBlack,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          elevation: isDisabled ? 0 : 4,
          shadowColor: kAccent.withOpacity(0.4),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label:
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    if (fullWidth) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
