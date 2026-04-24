import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';

abstract class BaseGameWidget extends StatefulWidget {
  final String p1;
  final String p2;
  final GameType gameType;

  const BaseGameWidget({
    super.key,
    required this.p1,
    required this.p2,
    required this.gameType,
  });
}

abstract class BaseGameState<T extends BaseGameWidget> extends State<T> {
  final DatabaseService _db = DatabaseService();

  Color get p1Color => const Color(0xFF00FBFF);
  Color get p2Color => const Color(0xFFFF006E);
  Color get bgColor => const Color(0xFF0D1117);
  Color get glassBase => const Color(0x1AFFFFFF);
  Color get glassBorder => const Color(0x33FFFFFF);

  int p1Wins = 0;
  int p2Wins = 0;
  int draws = 0;

  Future<void> _saveGameResult(String winner, {bool isDraw = false, int p1Score = 0, int p2Score = 0}) async {
    final game = Game(
      type: widget.gameType,
      player1Name: widget.p1,
      player2Name: widget.p2,
      winner: isDraw ? null : winner,
      isDraw: isDraw,
      player1Score: p1Score,
      player2Score: p2Score,
    );
    await _db.saveGame(game);
    await _db.updateOrCreatePlayer(widget.p1);
    await _db.updateOrCreatePlayer(widget.p2);

    await _db.saveGameScore(GameScore(
      playerName: widget.p1,
      gameId: widget.gameType.index,
      wins: p1Score > p2Score ? 1 : 0,
      losses: p1Score < p2Score ? 1 : 0,
      draws: isDraw ? 1 : 0,
      totalPoints: isDraw ? 1 : (p1Score > p2Score ? 3 : 0),
    ));

    await _db.saveGameScore(GameScore(
      playerName: widget.p2,
      gameId: widget.gameType.index,
      wins: p2Score > p1Score ? 1 : 0,
      losses: p2Score < p1Score ? 1 : 0,
      draws: isDraw ? 1 : 0,
      totalPoints: isDraw ? 1 : (p2Score > p1Score ? 3 : 0),
    ));
  }

  Future<void> saveP1Win({int p1Score = 1, int p2Score = 0}) async {
    p1Wins++;
    await _saveGameResult(widget.p1, p1Score: p1Score, p2Score: p2Score);
  }

  Future<void> saveP2Win({int p1Score = 0, int p2Score = 1}) async {
    p2Wins++;
    await _saveGameResult(widget.p2, p1Score: p1Score, p2Score: p2Score);
  }

  Future<void> saveDraw() async {
    draws++;
    await _saveGameResult('', isDraw: true);
  }

  Widget buildScoreDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: glassBase.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _scoreStat(widget.p1, p1Wins, p1Color),
              _scoreStat('DRAWS', draws, Colors.white38),
              _scoreStat(widget.p2, p2Wins, p2Color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreStat(String label, int val, Color color) {
    String displayLabel = label.length > 8 ? label.substring(0, 8) : label;
    return Column(
      children: [
        Text(displayLabel,
            style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        Text('$val',
            style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                shadows: [if (val > 0) Shadow(color: color, blurRadius: 10)])),
      ],
    );
  }
}