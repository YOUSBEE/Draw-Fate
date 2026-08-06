import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:media_scanner/media_scanner.dart';
import '../models/draw_session.dart';
import '../models/mahjong_tile.dart';
import '../widgets/tile_widget.dart';
import 'game_screen.dart' show kAccent, kBgBlack, kCardBlack;

class SharePreviewScreen extends StatefulWidget {
  final DrawSession session;

  const SharePreviewScreen({super.key, required this.session});

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _saving = false;

  // 4-5-4 배치
  static const _rowPattern = [4, 5, 4];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlack,
      appBar: AppBar(
        backgroundColor: kBgBlack,
        foregroundColor: kAccent,
        title: const Text(
          '이미지 미리보기',
          style: TextStyle(
            color: kAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kAccent.withOpacity(0.25)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Screenshot(
                  controller: _screenshotController,
                  child: _buildShareCard(),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      width: 720, // 가로로 넓게
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 타이틀
          Text(
            '운명 상세',
            style: TextStyle(
              color: kAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),

          // 날짜
          Text(
            widget.session.sessionLabel,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 10),

          const SizedBox(height: 20),

          // 패 — 4/5/4 배치
          ..._buildTileRows(),
          const SizedBox(height: 20),

          // 결과 요약
          _buildSummary(),
        ],
      ),
    );
  }

  List<Widget> _buildTileRows() {
    final tiles = widget.session.drawnTiles;
    final rows = <Widget>[];
    int cursor = 0;

    for (final count in _rowPattern) {
      if (cursor >= tiles.length) break;
      final end = (cursor + count).clamp(0, tiles.length);
      final rowTiles = tiles.sublist(cursor, end);
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rowTiles.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 순서 번호
                    Text(
                      '${cursor + i + 1}',
                      style: TextStyle(
                        color: kAccent.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TileWidget(tile: rowTiles[i], size: 52),
                  ],
                ),
              );
            }),
          ),
        ),
      );
      cursor += count;
    }
    return rows;
  }

  Widget _buildSummary() {
    final counts = <String, int>{
      '만수': 0, '통수': 0, '삭수': 0, '자패': 0, '적도라': 0,
    };
    for (final tile in widget.session.drawnTiles) {
      if (tile.isAkaDora) counts['적도라'] = counts['적도라']! + 1;
      switch (tile.suit) {
        case TileSuit.man: counts['만수'] = counts['만수']! + 1; break;
        case TileSuit.pin: counts['통수'] = counts['통수']! + 1; break;
        case TileSuit.sou: counts['삭수'] = counts['삭수']! + 1; break;
        case TileSuit.honor: counts['자패'] = counts['자패']! + 1; break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kAccent.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: counts.entries.map((e) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${e.value}',
              style: TextStyle(
                color: e.key == '적도라' ? const Color(0xFFFF1744) : kAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              e.key,
              style: TextStyle(
                color: e.key == '적도라'
                    ? const Color(0xFFFF8A80)
                    : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border(
            top: BorderSide(color: kAccent.withOpacity(0.2), width: 1),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: kBgBlack,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              shadowColor: kAccent.withOpacity(0.4),
            ),
            onPressed: _saving ? null : _saveImage,
            icon: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.download),
            label: Text(
              _saving ? '저장 중...' : '이미지 저장',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    setState(() => _saving = true);

    try {
      // 권한 요청
      final storageStatus = await Permission.storage.request();
      final photosStatus = await Permission.photos.request();
      debugPrint('storage: $storageStatus / photos: $photosStatus');

      final granted = storageStatus.isGranted || photosStatus.isGranted;
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('저장 권한이 필요합니다. 설정에서 허용해주세요.'),
              action: SnackBarAction(
                label: '설정',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        setState(() => _saving = false);
        return;
      }

      // 스크린샷 캡처
      final Uint8List? image = await _screenshotController.capture(
        pixelRatio: 3.0,
      );
      if (image == null) throw Exception('캡처 실패');

      // 저장 경로 — getExternalStorageDirectory 사용
      final extDir = await getExternalStorageDirectory();
      final picturesPath = extDir != null
          ? extDir.path.replaceAll('Android/data/com.example.mahjong_draw/files', 'Pictures/DrawFate')
          : '/storage/emulated/0/Pictures/DrawFate';

      final dir = Directory(picturesPath);
      if (!await dir.exists()) await dir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/draw_fate_$timestamp.png');
      await file.writeAsBytes(image);

      debugPrint('저장 경로: ${file.path}');
      // 갤러리에 등록
      await MediaScanner.loadMedia(path: file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 완료!'),
            backgroundColor: kAccent.withOpacity(0.85),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
