import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/game.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';

enum GameState { p1Hiding, p1ToP2Transition, p2Hiding, battle }

class SeaBattlePage extends StatefulWidget {
  final String p1;
  final String p2;

  const SeaBattlePage({super.key, required this.p1, required this.p2});

  @override
  State<SeaBattlePage> createState() => _SeaBattlePageState();
}

class _SeaBattlePageState extends State<SeaBattlePage> {
  static const Color bgColor = Color(0xFF0D1117);
  static const Color glassBase = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color neonCyan = Color(0xFF00FBFF);
  static const Color neonPink = Color(0xFFFF006E);

  final DatabaseService _db = DatabaseService();

  GameState currentState = GameState.p1Hiding;
  Set<int> p1Ships = {};
  Set<int> p2Ships = {};
  Set<int> p1Guesses = {};
  Set<int> p2Guesses = {};
  bool isPlayer1Turn = true;
  bool isProcessing = false;
  final int maxShips = 5;
  int p1Wins = 0;
  int p2Wins = 0;

  void _handleTap(int index, bool isTopGrid) {
    if (isProcessing) return;

    setState(() {
      if (currentState == GameState.p1Hiding && isTopGrid) {
        _toggleShip(index, p1Ships);
      } else if (currentState == GameState.p2Hiding && !isTopGrid) {
        _toggleShip(index, p2Ships);
      } else if (currentState == GameState.battle) {
        if (isPlayer1Turn && !isTopGrid) {
          _attack(index, p1Guesses, p2Ships);
        } else if (!isPlayer1Turn && isTopGrid) {
          _attack(index, p2Guesses, p1Ships);
        }
      }
    });
  }

  void _toggleShip(int index, Set<int> shipSet) {
    if (shipSet.contains(index)) {
      shipSet.remove(index);
    } else if (shipSet.length < maxShips) {
      shipSet.add(index);
    }
  }

  void _attack(int index, Set<int> guessSet, Set<int> enemyShips) async {
    if (guessSet.contains(index)) return;

    setState(() {
      isProcessing = true;
      guessSet.add(index);
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      isProcessing = false;
      if (!enemyShips.contains(index)) {
        isPlayer1Turn = !isPlayer1Turn;
      } else {
        if (guessSet.intersection(enemyShips).length == maxShips) {
          if (isPlayer1Turn) {
            p1Wins++;
            _saveResult("Player 1");
          } else {
            p2Wins++;
            _saveResult("Player 2");
          }
          _showWinDialog();
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      p1Ships.clear();
      p2Ships.clear();
      p1Guesses.clear();
      p2Guesses.clear();
      currentState = GameState.p1Hiding;
      isPlayer1Turn = true;
      isProcessing = false;
    });
  }

  Future<void> _saveResult(String winner) async {
    final game = Game(type: GameType.seaBattle, player1Name: widget.p1, player2Name: widget.p2, winner: winner);
    await _db.saveGame(game);
    await _db.updateOrCreatePlayer(widget.p1);
    await _db.updateOrCreatePlayer(widget.p2);
    await _db.saveGameScore(GameScore(playerName: widget.p1, gameId: GameType.seaBattle.index,
        wins: winner == widget.p1 ? 1 : 0, losses: winner == widget.p2 ? 1 : 0, totalPoints: winner == widget.p1 ? 3 : 0));
    await _db.saveGameScore(GameScore(playerName: widget.p2, gameId: GameType.seaBattle.index,
        wins: winner == widget.p2 ? 1 : 0, losses: winner == widget.p1 ? 1 : 0, totalPoints: winner == widget.p2 ? 3 : 0));
  }

  // ignore: unused_element
  Future<void> _saveDraw() async {
    final game = Game(type: GameType.seaBattle, player1Name: widget.p1, player2Name: widget.p2, isDraw: true);
    await _db.saveGame(game);
    await _db.saveGameScore(GameScore(playerName: widget.p1, gameId: GameType.seaBattle.index,
        draws: 1, totalPoints: 1));
    await _db.saveGameScore(GameScore(playerName: widget.p2, gameId: GameType.seaBattle.index,
        draws: 1, totalPoints: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              (isPlayer1Turn ? neonCyan : neonPink).withValues(alpha: 0.05),
              bgColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 10),
                  _buildScoreBoard(),
                  const SizedBox(height: 10),
                  _buildPlayerHeader("FLEET COMMAND A", neonCyan,
                      isPlayer1Turn || currentState == GameState.p1Hiding),
                  Expanded(child: _buildGrid(isTopGrid: true)),
                  _buildCenterConsole(),
                  Expanded(child: _buildGrid(isTopGrid: false)),
                  _buildPlayerHeader("FLEET COMMAND B", neonPink,
                      !isPlayer1Turn || currentState == GameState.p2Hiding),
                  const SizedBox(height: 10),
                ],
              ),
              if (currentState == GameState.p1ToP2Transition)
                _buildTransitionOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text("SEA BATTLE OS",
              style: TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white38),
            onPressed: _resetGame,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
                color: glassBase,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glassBorder)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _scoreItem("P1 SHIPS", p1Ships.length, neonCyan),
                _scoreItem("P1 WINS", p1Wins, neonCyan, isSmall: true),
                Container(width: 1, height: 30, color: glassBorder),
                _scoreItem("P2 WINS", p2Wins, neonPink, isSmall: true),
                _scoreItem("P2 SHIPS", p2Ships.length, neonPink),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreItem(String label, int count, Color color,
      {bool isSmall = false}) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.5),
                fontSize: isSmall ? 8 : 10,
                fontWeight: FontWeight.bold)),
        Text("$count",
            style: TextStyle(
                color: color,
                fontSize: isSmall ? 14 : 20,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: color, blurRadius: 10)])),
      ],
    );
  }

  Widget _buildGrid({required bool isTopGrid}) {
    bool isVisible = (currentState == GameState.p1Hiding && isTopGrid) ||
        (currentState == GameState.p2Hiding && !isTopGrid) ||
        (currentState == GameState.battle);

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isVisible ? 1.0 : 0.05,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 64,
            itemBuilder: (context, index) {
              bool hasShip =
                  isTopGrid ? p1Ships.contains(index) : p2Ships.contains(index);
              Set<int> enemyGuesses = isTopGrid ? p2Guesses : p1Guesses;
              bool wasHit = hasShip && enemyGuesses.contains(index);
              bool wasMiss = !hasShip && enemyGuesses.contains(index);

              bool isScanning = isProcessing &&
                  ((isPlayer1Turn && !isTopGrid && p1Guesses.last == index) ||
                      (!isPlayer1Turn && isTopGrid && p2Guesses.last == index));

              return GestureDetector(
                onTap: () => _handleTap(index, isTopGrid),
                child: Container(
                  decoration: BoxDecoration(
                    color: wasHit
                        ? neonCyan.withValues(alpha: 0.1)
                        : (wasMiss
                            ? neonPink.withValues(alpha: 0.1)
                            : glassBase),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: wasHit
                            ? neonCyan
                            : (wasMiss ? neonPink : glassBorder),
                        width: 1),
                  ),
                  child: Center(
                    child: isScanning
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : (wasHit
                            ? const Icon(Icons.close, color: neonCyan, size: 16)
                            : (wasMiss
                                ? Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                        color: neonPink,
                                        shape: BoxShape.circle))
                                : (hasShip &&
                                        (currentState != GameState.battle ||
                                            wasHit)
                                    ? Icon(Icons.shield,
                                        size: 12,
                                        color:
                                            Colors.white.withValues(alpha: 0.4))
                                    : null))),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.vpn_key_outlined, color: neonCyan, size: 80),
            const SizedBox(height: 30),
            const Text("ENCRYPTED HANDOVER",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4)),
            const SizedBox(height: 60),
            _actionButton("INITIATE COMMAND B", true, neonPink, () {
              setState(() => currentState = GameState.p2Hiding);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeader(String name, Color color, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1.0 : 0.15,
        child: Text(name,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 4,
                shadows: [if (isActive) Shadow(color: color, blurRadius: 10)])),
      ),
    );
  }

  Widget _buildCenterConsole() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: glassBase,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: glassBorder),
          ),
          child: Center(child: _getConsoleContent()),
        ),
      ),
    );
  }

  Widget _getConsoleContent() {
    if (currentState == GameState.p1Hiding) {
      return _actionButton(
          "CONFIRM FORMATION", p1Ships.length == maxShips, neonCyan, () {
        setState(() => currentState = GameState.p1ToP2Transition);
      });
    } else if (currentState == GameState.p2Hiding) {
      return _actionButton("ENGAGE ENEMY", p2Ships.length == maxShips, neonPink,
          () {
        setState(() => currentState = GameState.battle);
      });
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isPlayer1Turn ? "PLAYER 1" : "PLAYER 2",
              style: TextStyle(
                  color: isPlayer1Turn ? neonCyan : neonPink,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2)),
          const Text("SELECT TARGET",
              style: TextStyle(
                  color: Colors.white38, fontSize: 9, letterSpacing: 2)),
        ],
      );
    }
  }

  Widget _actionButton(
      String label, bool enabled, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.1) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: enabled ? color : Colors.white10, width: 1),
          boxShadow: [
            if (enabled)
              BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)
          ],
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: enabled ? color : Colors.white24,
                letterSpacing: 1.5,
                fontSize: 11)),
      ),
    );
  }

  void _showWinDialog() {
    String winner = isPlayer1Turn ? "PLAYER 1" : "PLAYER 2";
    Color winColor = isPlayer1Turn ? neonCyan : neonPink;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: winColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: winColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5)
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined, color: winColor, size: 50),
                  const SizedBox(height: 16),
                  Text("$winner VICTORIOUS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: winColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                  const SizedBox(height: 12),
                  const Text(
                      "Enemy fleet neutralized. Naval supremacy achieved.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _resetGame();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: winColor),
                      ),
                      child: Text("REDEPLOY",
                          style: TextStyle(
                              color: winColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
