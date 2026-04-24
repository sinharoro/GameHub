import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project_app3/games/tic_tac_toe.dart';
import 'package:project_app3/games/sea_battle.dart';
import 'package:project_app3/games/chess_game.dart';
import 'package:project_app3/games/checkers.dart';
import 'package:project_app3/screens/scores_screen.dart';
import 'package:project_app3/screens/rankings_screen.dart';

const Color kBg = Color(0xFF0D1117);
const Color kGlassBase = Color(0x1AFFFFFF);
const Color kGlassBorder = Color(0x33FFFFFF);
const Color kNeonCyan = Color(0xFF00FBFF);
const Color kNeonPink = Color(0xFFFF006E);
const Color kNeonGreen = Color(0xFF39FF14);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      drawer: _buildNeonDrawer(),
      body: Stack(
        children: [
          _buildBackgroundGlows(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 30),
                Expanded(child: _buildGameGrid()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(
            top: -100,
            right: -50,
            child: _glowCircle(kNeonCyan.withValues(alpha: 0.1), 250)),
        Positioned(
            bottom: -50,
            left: -50,
            child: _glowCircle(kNeonPink.withValues(alpha: 0.1), 300)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text("GAME HUB",
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 8.0, color: Colors.white)),
        const SizedBox(height: 12),
        _glassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: const Text("SELECT MISSION",
              style: TextStyle(
                  color: kNeonCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 3)),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Builder(builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white70),
            onPressed: () => Scaffold.of(context).openDrawer(),
          )),
          const Spacer(),
          const Text("OS v1.0", style: TextStyle(color: Colors.white24, fontSize: 10)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _gameCard("SEA BATTLE", Icons.directions_boat_rounded,
            kNeonCyan, () => _showSeaBattleDialog(context)),
        _gameCard("TIC TAC TOE", Icons.close_rounded, kNeonPink,
            () => _showStartDialog(context)),
        _gameCard("CHESS PRO", Icons.castle_rounded, Colors.amber,
            () => _showChessDialog(context)),
        _gameCard("CHECKERS", Icons.grid_view_rounded, kNeonGreen,
            () => _showCheckersDialog(context)),
      ],
    );
  }

  void _nav(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));

  void _showDialogFor(String game, Color color, String p1Hint, String p2Hint, 
      Widget Function(String p1, String p2) builder) {
    final p1 = TextEditingController(text: p1Hint);
    final p2 = TextEditingController(text: p2Hint);
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: kBg.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: kGlassBorder)),
          title: Text("INITIALIZE $game",
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassInput(p1, "Player 1", color),
              const SizedBox(height: 15),
              _glassInput(p2, "Player 2", color),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _nav(builder(p1.text, p2.text));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: color),
                  ),
                  child: Center(
                      child: Text("LAUNCH",
                          style: TextStyle(color: color, fontWeight: FontWeight.bold))),
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

  void _showSeaBattleDialog(BuildContext context) {
    _showDialogFor("SEA BATTLE", kNeonCyan, "Fleet A", "Fleet B",
        (p1, p2) => SeaBattlePage(p1: p1, p2: p2));
  }

  void _showStartDialog(BuildContext context) {
    _showDialogFor("TIC TAC TOE", kNeonPink, "Player X", "Player O",
        (p1, p2) => TicTacToeScreen(p1: p1, p2: p2));
  }

  void _showChessDialog(BuildContext context) {
    _showDialogFor("CHESS", Colors.amber, "Player White", "Player Black",
        (p1, p2) => ChessGame(p1: p1, p2: p2));
  }

  void _showCheckersDialog(BuildContext context) {
    _showDialogFor("CHECKERS", kNeonGreen, "Player 1", "Player 2",
        (p1, p2) => CheckersPage(p1: p1, p2: p2));
  }

  Widget _gameCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: color, blurRadius: 100, spreadRadius: size / 2)
      ]),
    );
  }

  Widget _glassContainer(
      {required Widget child,
      double borderRadius = 20,
      EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kGlassBase,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: kGlassBorder, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNeonDrawer() {
    return Drawer(
      backgroundColor: kBg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              child: const Column(
                children: [
                  Text("GAME HUB",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  Text("v1.0.0",
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            const Divider(color: kGlassBorder),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: kNeonCyan),
              title: const Text("SCORES", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScoresScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: kNeonPink),
              title: const Text("RANKINGS", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingsScreen()));
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text("SYSTEM ACTIVE",
                  style: TextStyle(color: Colors.white24, letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }
}
