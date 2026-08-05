import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mahjong_tile.dart';
import '../models/draw_session.dart';

class GameProvider extends ChangeNotifier {
  static const int maxTiles = 13;
  static const String _sessionsKey = 'draw_sessions';

  List<MahjongTile> _remainingDeck = [];
  List<MahjongTile> _drawnTiles = [];
  List<DrawSession> _sessions = [];

  bool _isDrawing = false;

  List<MahjongTile> get drawnTiles => List.unmodifiable(_drawnTiles);
  List<DrawSession> get sessions => List.unmodifiable(_sessions);
  bool get isDrawing => _isDrawing;
  bool get canDraw => _drawnTiles.length < maxTiles && !_isDrawing;
  bool get hasTilesDrawn => _drawnTiles.isNotEmpty;
  bool get isComplete => _drawnTiles.length == maxTiles;
  int get drawnCount => _drawnTiles.length;
  int get remainingCount => maxTiles - _drawnTiles.length;

  GameProvider() {
    _loadSessions();
    _resetDeck();
  }

  void _resetDeck() {
    final deck = MahjongDeck.fullDeck;
    deck.shuffle(Random());
    _remainingDeck = deck;
  }

  // Draw one tile
  void drawOne() {
    if (!canDraw || _remainingDeck.isEmpty) return;
    final tile = _remainingDeck.removeLast();
    _drawnTiles.add(tile);
    notifyListeners();
  }

  // Draw all 13 at once
  void drawAll() {
    if (!canDraw) return;
    final needed = maxTiles - _drawnTiles.length;
    for (int i = 0; i < needed && _remainingDeck.isNotEmpty; i++) {
      _drawnTiles.add(_remainingDeck.removeLast());
    }
    notifyListeners();
  }

  // Draw remaining tiles (when mid-draw)
  void drawRemaining() {
    if (!canDraw) return;
    drawAll();
  }

  // Save current session and start a new one
  Future<void> saveAndReset() async {
    if (_drawnTiles.isEmpty) {
      _resetDeck();
      notifyListeners();
      return;
    }

    final session = DrawSession(
      drawnTiles: List.from(_drawnTiles),
      isComplete: isComplete,
    );
    _sessions.insert(0, session);
    await _saveSessions();

    _drawnTiles = [];
    _resetDeck();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(data));
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _sessions = list
          .map((e) => DrawSession.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }
}
