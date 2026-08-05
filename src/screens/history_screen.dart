import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'session_detail_screen.dart';
import 'game_screen.dart' show kAccent, kBgBlack, kSurfaceBlack, kCardBlack;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgBlack,
      appBar: AppBar(
        backgroundColor: kBgBlack,
        foregroundColor: kAccent,
        title: const Text(
          '운명 기록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kAccent,
            letterSpacing: 1.0,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kAccent.withOpacity(0.3)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Consumer<GameProvider>(
        builder: (context, provider, _) {
          if (provider.sessions.isEmpty) {
            return const SizedBox.shrink();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: provider.sessions.length,
            itemBuilder: (context, index) {
              final session = provider.sessions[index];
              return Dismissible(
                key: Key(session.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => provider.deleteSession(session.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: kCardBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SessionDetailScreen(session: session),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.sessionLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.statusLabel,
                                  style: TextStyle(
                                    color: session.isComplete
                                        ? kAccent.withOpacity(0.8)
                                        : Colors.orange[300],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // 패 미리보기
                                Row(
                                  children: [
                                    ...session.drawnTiles.take(5).map((t) =>
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(
                                            t.displayName,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: t.suitColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )),
                                    if (session.drawnTiles.length > 5)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Text(
                                          '+${session.drawnTiles.length - 5}',
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: kAccent.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}
