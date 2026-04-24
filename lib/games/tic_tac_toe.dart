import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';
import 'sea_battle.dart';
import 'checkers.dart';
import 'chess_game.dart';

// --- SHARED OS DESIGN TOKENS ---
const Color kBg = Color(0xFF0D1117);
const Color kGlassBase = Color(0x1AFFFFFF);
const Color kGlassBorder = Color(0x33FFFFFF);
const Color kNeonCyan = Color(0xFF00FBFF);
const Color kNeonPink = Color(0xFFFF006E);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GameHubApp());
}

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Orbitron',
      ),
      home: const HomeScreen(),
    );
  }
}

// --- HOME SCREEN (GAME HUB) remains largely the same ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kNeonCyan.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text("GAME HUB",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8.0)),
                const Text("ELITE CHALLENGE SERIES",
                    style: TextStyle(
                        color: Colors.white24,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2)),
                const SizedBox(height: 50),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 25,
                    children: [
                      _gameCard(context, "TIC TAC TOE", Icons.grid_3x3_rounded,
                          kNeonCyan, () => _showStartDialog(context)),
                      _gameCard(context, "SEA BATTLE",
                          Icons.directions_boat_rounded, kNeonPink, () => _showSeaBattleDialog(context)),
                      _gameCard(context, "CHECKERS", Icons.grid_on_rounded,
                          Colors.amberAccent, () => _showCheckersDialog(context)),
                      _gameCard(context, "CHESS", Icons.psychology_alt_rounded,
                          Colors.white, () => _showChessDialog(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameCard(
      BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: kGlassBase,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: kGlassBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color, shadows: [
                  Shadow(color: color.withValues(alpha: 0.5), blurRadius: 15)
                ]),
                const SizedBox(height: 15),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStartDialog(BuildContext context) {
    final p1 = TextEditingController(text: "Commander 1");
    final p2 = TextEditingController(text: "Commander 2");
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: kBg.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: kGlassBorder)),
          title: const Text("INITIALIZE GAME",
              style: TextStyle(
                  color: kNeonCyan, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassInput(p1, "Player 1", kNeonCyan),
              const SizedBox(height: 15),
              _glassInput(p2, "Player 2", kNeonPink),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TicTacToeScreen(p1: p1.text, p2: p2.text)));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: kNeonCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: kNeonCyan),
                  ),
                  child: const Center(
                      child: Text("LAUNCH OS",
                          style: TextStyle(
                              color: kNeonCyan, fontWeight: FontWeight.bold))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSeaBattleDialog(BuildContext context) {
    final p1 = TextEditingController(text: "Commander 1");
    final p2 = TextEditingController(text: "Commander 2");
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: kBg.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: kGlassBorder)),
          title: const Text("INITIALIZE SEA BATTLE",
              style: TextStyle(
                  color: kNeonPink, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassInput(p1, "Fleet A", kNeonCyan),
              const SizedBox(height: 15),
              _glassInput(p2, "Fleet B", kNeonPink),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              SeaBattlePage(p1: p1.text, p2: p2.text)));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: kNeonPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: kNeonPink),
                  ),
                  child: const Center(
                      child: Text("LAUNCH OS",
                          style: TextStyle(
                              color: kNeonPink, fontWeight: FontWeight.bold))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckersDialog(BuildContext context) {
    final p1 = TextEditingController(text: "Commander 1");
    final p2 = TextEditingController(text: "Commander 2");
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: kBg.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: kGlassBorder)),
          title: const Text("INITIALIZE CHECKERS",
              style: TextStyle(
                  color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassInput(p1, "Player 1", kNeonCyan),
              const SizedBox(height: 15),
              _glassInput(p2, "Player 2", kNeonPink),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CheckersPage(p1: p1.text, p2: p2.text)));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amberAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amberAccent),
                  ),
                  child: const Center(
                      child: Text("LAUNCH OS",
                          style: TextStyle(
                              color: Colors.amberAccent, fontWeight: FontWeight.bold))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showChessDialog(BuildContext context) {
    final p1 = TextEditingController(text: "Commander 1");
    final p2 = TextEditingController(text: "Commander 2");
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: kBg.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: kGlassBorder)),
          title: const Text("INITIALIZE CHESS",
              style: TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassInput(p1, "Player White", Colors.white),
              const SizedBox(height: 15),
              _glassInput(p2, "Player Black", Colors.white54),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ChessGame(p1: p1.text, p2: p2.text)));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white),
                  ),
                  child: const Center(
                      child: Text("LAUNCH OS",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassInput(TextEditingController ctrl, String hint, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: kGlassBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGlassBorder),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.person, color: color, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}

// --- TIC TAC TOE GAME SCREEN (UPDATED WITH SCORES) ---
class TicTacToeScreen extends StatefulWidget {
  final String p1, p2;
  const TicTacToeScreen({required this.p1, required this.p2, super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  late List<List<String>> _board;
  String _current = "X";
  bool _gameOver = false;
  final DatabaseService _db = DatabaseService();

  int xWins = 0;
  int oWins = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    _reset();
    _initPlayers();
  }

  Future<void> _initPlayers() async {
    await _db.updateOrCreatePlayer(widget.p1);
    await _db.updateOrCreatePlayer(widget.p2);
  }

  void _reset() {
    setState(() {
      _board = List.generate(3, (_) => List.generate(3, (_) => ""));
      _current = "X";
      _gameOver = false;
    });
  }

  void _handleTap(int r, int c) {
    if (_board[r][c] != "" || _gameOver) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _board[r][c] = _current;
      if (_checkWinner(r, c)) {
        _gameOver = true;
        if (_current == "X") {
          xWins++;
          _saveResult(widget.p1, widget.p2);
        } else {
          oWins++;
          _saveResult(widget.p2, widget.p1);
        }
        _showWinnerDialog();
      } else if (!_board.any((row) => row.any((cell) => cell == ""))) {
        _gameOver = true;
        draws++;
        _saveDraw();
        _showTieDialog();
      } else {
        _current = _current == "X" ? "O" : "X";
      }
    });
  }

  Future<void> _saveResult(String winner, String loser) async {
    final game = Game(type: GameType.ticTacToe, player1Name: widget.p1, player2Name: widget.p2, winner: winner);
    await _db.saveGame(game);
    await _db.saveGameScore(_createScore(widget.p1, winner == widget.p1, false));
    await _db.saveGameScore(_createScore(widget.p2, winner == widget.p2, false));
  }

  Future<void> _saveDraw() async {
    final game = Game(type: GameType.ticTacToe, player1Name: widget.p1, player2Name: widget.p2, isDraw: true);
    await _db.saveGame(game);
    await _db.saveGameScore(_createScore(widget.p1, false, true));
    await _db.saveGameScore(_createScore(widget.p2, false, true));
  }

  _createScore(String playerName, bool isWinner, bool isDraw) {
    return GameScore(playerName: playerName, gameId: GameType.ticTacToe.index,
        wins: isWinner ? 1 : 0, losses: isWinner ? 0 : 1, draws: isDraw ? 1 : 0,
        totalPoints: isWinner ? 3 : (isDraw ? 1 : 0));
  }

  bool _checkWinner(int r, int c) {
    if (_board[r].every((e) => e == _current)) return true;
    if (_board.every((row) => row[c] == _current)) return true;
    if (r == c &&
        _board[0][0] == _current &&
        _board[1][1] == _current &&
        _board[2][2] == _current) return true;
    if (r + c == 2 &&
        _board[0][2] == _current &&
        _board[1][1] == _current &&
        _board[2][0] == _current) return true;
    return false;
  }

  void _showWinnerDialog() {
    String winnerName = _current == "X" ? widget.p1 : widget.p2;
    Color color = _current == "X" ? kNeonCyan : kNeonPink;
    _showOSDialog("VICTORY", "$winnerName DOMINATED THE GRID", color);
  }

  void _showTieDialog() {
    _showOSDialog("DRAW", "A PERFECT STALEMATE", Colors.white54);
  }

  void _showOSDialog(String title, String msg, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: kBg.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: color)),
          title: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, letterSpacing: 4)),
          content: Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _reset();
                },
                child: Text("RE-INITIALIZE",
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color turnColor = _current == "X" ? kNeonCyan : kNeonPink;
    return Scaffold(
      backgroundColor: kBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [turnColor.withValues(alpha: 0.05), kBg],
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 20),
              _buildScoreDashboard(), // Added Score Dashboard
              const SizedBox(height: 30),
              _buildTurnIndicator(turnColor),
              const Spacer(),
              _buildBoard(),
              const Spacer(),
              const Text("SYSTEM STATUS: ACTIVE",
                  style: TextStyle(
                      color: Colors.white10, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context)),
          const Spacer(),
          const Text("TIC TAC TOE OS",
              style: TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white24),
              onPressed: _reset),
        ],
      ),
    );
  }

  // --- NEW SCORE DASHBOARD WIDGET ---
  Widget _buildScoreDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: kGlassBase,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGlassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _scoreStat("PLAYER X", xWins, kNeonCyan),
                _scoreStat("DRAWS", draws, Colors.white38),
                _scoreStat("PLAYER O", oWins, kNeonPink),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreStat(String label, int val, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        Text("$val",
            style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                shadows: [if (val > 0) Shadow(color: color, blurRadius: 10)])),
      ],
    );
  }

  Widget _buildTurnIndicator(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        "${_current == "X" ? widget.p1 : widget.p2}'S TURN",
        style: TextStyle(
            color: color, fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kGlassBase,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGlassBorder),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: 9,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          int r = i ~/ 3, c = i % 3;
          String val = _board[r][c];
          Color cellColor = val == "X" ? kNeonCyan : kNeonPink;
          return GestureDetector(
            onTap: () => _handleTap(r, c),
            child: Container(
              decoration: BoxDecoration(
                color: kBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: val == ""
                        ? kGlassBorder
                        : cellColor.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text(val,
                    style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: cellColor,
                        shadows: [
                          if (val != "")
                            Shadow(color: cellColor, blurRadius: 15)
                        ])),
              ),
            ),
          );
        },
      ),
    );
  }
}
