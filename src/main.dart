import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MahjongApp());
}

class MahjongApp extends StatelessWidget {
  const MahjongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: '운명의 마작패',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: kAccent,
            surface: kBgBlack,
            background: kBgBlack,
          ),
          scaffoldBackgroundColor: kBgBlack,
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}
