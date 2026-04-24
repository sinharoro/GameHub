import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';
import '../core/app_widgets.dart';
import '../core/page_transitions.dart';
import '../models/base_game.dart';
import '../models/game.dart';

enum PieceType { player1, player2, p1King, p2King }

class CheckersPage extends BaseGameWidget {
  const CheckersPage({super.key, required super.p1, required super.p2})
      : super(gameType: GameType.checkers);

  @override
  State<CheckersPage> createState() => _CheckersPageState();
}

class _CheckersPageState extends BaseGameState<CheckersPage> {
  late List<PieceType?> board;
  int? selectedIndex;
  bool isPlayer1Turn = true;
  List<int> validMoves = [];
  bool multiJumpActive = false;
  int p1Pieces = 12;
  int p2Pieces = 12;

  int _movesWithoutCapture = 0;
  bool _showKingOverlay = false;
  String? _kingOverlayMessage;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      board = List.generate(64, (index) {
        int row = index ~/ 8;
        int col = index % 8;
        if ((row + col) % 2 != 0) {
          if (row < 3) return PieceType.player2;
          if (row > 4) return PieceType.player1;
        }
        return null;
      });
      selectedIndex = null;
      validMoves = [];
      isPlayer1Turn = true;
      multiJumpActive = false;
      _movesWithoutCapture = 0;
      _updatePieceCounts();
      p1Wins = 0;
      p2Wins = 0;
      draws = 0;
    });
  }

  void _updatePieceCounts() {
    int p1 = 0;
    int p2 = 0;
    for (var piece in board) {
      if (piece == PieceType.player1 || piece == PieceType.p1King) p1++;
      if (piece == PieceType.player2 || piece == PieceType.p2King) p2++;
    }
    p1Pieces = p1;
    p2Pieces = p2;
  }

  void _onTap(int index) {
    if (p1Pieces == 0 || p2Pieces == 0) return;

    if (multiJumpActive) {
      if (validMoves.contains(index)) {
        _movePiece(selectedIndex!, index);
      }
      return;
    }

    bool globalJumpAvailable = _canAnyPieceJump();

    if (board[index] != null && _isOwnPiece(board[index]!)) {
      List<int> moves = _getValidMoves(index);
      if (globalJumpAvailable && !moves.any((m) => _isJumpMove(index, m))) {
        return;
      }
      setState(() {
        selectedIndex = index;
        validMoves = moves;
      });
    } else if (selectedIndex != null && validMoves.contains(index)) {
      _movePiece(selectedIndex!, index);
    }
  }

  bool _isOwnPiece(PieceType piece) {
    if (isPlayer1Turn) return piece == PieceType.player1 || piece == PieceType.p1King;
    return piece == PieceType.player2 || piece == PieceType.p2King;
  }

  bool _isJumpMove(int from, int to) {
    return (to - from).abs() > 10;
  }

  List<int> _getValidMoves(int index) {
    List<int> jumpMoves = [];
    List<int> simpleMoves = [];
    PieceType? piece = board[index];
    if (piece == null) return [];

    bool isKing = piece == PieceType.p1King || piece == PieceType.p2King;
    List<int> rowDirs = isKing ? [-1, 1] : (piece == PieceType.player1 ? [-1] : [1]);

    for (int rd in rowDirs) {
      for (int cd in [-1, 1]) {
        int tRow = (index ~/ 8) + rd;
        int tCol = (index % 8) + cd;
        if (_inBounds(tRow, tCol)) {
          int tIdx = tRow * 8 + tCol;
          if (board[tIdx] == null) {
            simpleMoves.add(tIdx);
          } else if (!_isOwnPiece(board[tIdx]!)) {
            int jRow = tRow + rd;
            int jCol = tCol + cd;
            if (_inBounds(jRow, jCol)) {
              int jIdx = jRow * 8 + jCol;
              if (board[jIdx] == null) jumpMoves.add(jIdx);
            }
          }
        }
      }
    }

    if (multiJumpActive) return jumpMoves;
    return jumpMoves.isNotEmpty ? jumpMoves : simpleMoves;
  }

  bool _canAnyPieceJump() {
    for (int i = 0; i < 64; i++) {
      if (board[i] != null && _isOwnPiece(board[i]!)) {
        if (_calculatePotentialJumps(i).isNotEmpty) return true;
      }
    }
    return false;
  }

  List<int> _calculatePotentialJumps(int index) {
    List<int> jumps = [];
    PieceType? p = board[index];
    if (p == null) return [];

    bool isK = p == PieceType.p1King || p == PieceType.p2King;
    List<int> dirs = isK ? [-1, 1] : (p == PieceType.player1 ? [-1] : [1]);

    for (int rd in dirs) {
      for (int cd in [-1, 1]) {
        int tRow = (index ~/ 8) + rd, tCol = (index % 8) + cd;
        int jRow = tRow + rd, jCol = tCol + cd;
        if (_inBounds(jRow, jCol)) {
          int tIdx = tRow * 8 + tCol, jIdx = jRow * 8 + jCol;
          if (board[tIdx] != null && !_isOwnPiece(board[tIdx]!) && board[jIdx] == null) {
            jumps.add(jIdx);
          }
        }
      }
    }
    return jumps;
  }

  bool _inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

  void _movePiece(int from, int to) {
    setState(() {
      bool captured = (to - from).abs() > 10;
      board[to] = board[from];
      board[from] = null;

      if (captured) {
        board[(from + to) ~/ 2] = null;
        _updatePieceCounts();
        _movesWithoutCapture = 0;
      } else {
        _movesWithoutCapture++;
      }

      bool justKinged = false;
      if (to ~/ 8 == 0 && board[to] == PieceType.player1) {
        board[to] = PieceType.p1King;
        justKinged = true;
      }
      if (to ~/ 8 == 7 && board[to] == PieceType.player2) {
        board[to] = PieceType.p2King;
        justKinged = true;
      }

      if (justKinged) {
        HapticFeedback.mediumImpact();
        _showKingPromotionOverlay();
      }

      if (captured) {
        List<int> nextJumps = _calculatePotentialJumps(to);
        if (nextJumps.isNotEmpty) {
          selectedIndex = to;
          validMoves = nextJumps;
          multiJumpActive = true;
          return;
        }
      }

      selectedIndex = null;
      validMoves = [];
      multiJumpActive = false;
      isPlayer1Turn = !isPlayer1Turn;

      _checkGameEnd();
    });
  }

  void _showKingPromotionOverlay() {
    setState(() {
      _showKingOverlay = true;
      _kingOverlayMessage = "KING!";
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showKingOverlay = false);
    });
  }

  void _checkGameEnd() {
    bool p1HasLegalMoves = _hasAnyLegalMove(forPlayer1: true);
    bool p2HasLegalMoves = _hasAnyLegalMove(forPlayer1: false);

    if (p1Pieces == 0 || !p2HasLegalMoves) {
      p2Wins++;
      _saveAndShowEnd(true);
    } else if (p2Pieces == 0 || !p1HasLegalMoves) {
      p1Wins++;
      _saveAndShowEnd(false);
    } else if (_movesWithoutCapture >= 80) {
      draws++;
      _saveAndShowDraw();
    }
  }

  bool _hasAnyLegalMove({required bool forPlayer1}) {
    for (int i = 0; i < 64; i++) {
      if (board[i] != null) {
        bool isP1 = board[i] == PieceType.player1 || board[i] == PieceType.p1King;
        if (isP1 != forPlayer1) continue;
        if (_getValidMoves(i).isNotEmpty) return true;
      }
    }
    return false;
  }

  Future<void> _saveAndShowEnd(bool p2Won) async {
    try {
      await saveP2Win();
    } catch (_) {}
    if (mounted) {
      String winner = p2Won ? widget.p2 : widget.p1;
      Color winColor = p2Won ? AppColors.pink : AppColors.cyan;
      showResultDialog(
        title: "VICTORY",
        message: "$winner VICTORIOUS",
        color: winColor,
      );
    }
  }

  Future<void> _saveAndShowDraw() async {
    try {
      await saveDraw();
    } catch (_) {}
    if (mounted) {
      showResultDialog(
        title: "DRAW",
        message: "40-move rule reached",
        color: AppColors.amber,
        isDraw: true,
      );
    }
  }

  @override
  void onRematch() {
    _resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              isPlayer1Turn ? AppColors.cyan.withValues(alpha: 0.05) : AppColors.pink.withValues(alpha: 0.05),
              AppColors.bg,
            ],
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 10),
                  buildScoreDashboard(),
                  const SizedBox(height: 20),
                  _buildTurnIndicator(),
                  Expanded(child: Center(child: _buildBoard())),
                  const SizedBox(height: 40),
                ],
              ),
              if (_showKingOverlay)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: AppColors.amber.withValues(alpha: 0.5), blurRadius: 30),
                      ],
                    ),
                    child: Text(
                      _kingOverlayMessage ?? "KING!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ).then().fadeOut(delay: 800.ms),
                ),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text("CHECKERS OS", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white38),
            onPressed: _resetGame,
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator() {
    Color activeColor = isPlayer1Turn ? AppColors.cyan : AppColors.pink;
    String playerName = isPlayer1Turn ? widget.p1 : widget.p2;
    bool globalJumpAvailable = _canAnyPieceJump();
    String subtext = multiJumpActive
        ? "CHAIN ATTACK"
        : (globalJumpAvailable ? "MUST CAPTURE" : "YOUR MOVE");

    return Column(
      children: [
        Text(
          playerName.length > 12 ? '${playerName.substring(0, 12)}..' : playerName,
          style: TextStyle(
            color: activeColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            shadows: [Shadow(color: activeColor, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: globalJumpAvailable ? AppColors.checkRed.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: globalJumpAvailable ? Border.all(color: AppColors.checkRed) : null,
          ),
          child: Text(
            subtext,
            style: TextStyle(
              color: globalJumpAvailable ? AppColors.checkRed : Colors.white24,
              fontSize: 8,
              letterSpacing: 2,
              fontWeight: globalJumpAvailable ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoard() {
    double size = MediaQuery.of(context).size.width - 40;
    bool globalJumpAvailable = _canAnyPieceJump();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemCount: 64,
        itemBuilder: (context, index) {
          int row = index ~/ 8, col = index % 8;
          bool isDark = (row + col) % 2 != 0;
          bool isSelected = selectedIndex == index;
          bool isValid = validMoves.contains(index);
          bool isJumpAvailablePiece = false;

          if (globalJumpAvailable && !multiJumpActive) {
            if (board[index] != null && _isOwnPiece(board[index]!) && _calculatePotentialJumps(index).isNotEmpty) {
              isJumpAvailablePiece = true;
            }
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _onTap(index);
            },
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cyan.withValues(alpha: 0.2)
                    : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.transparent),
                borderRadius: BorderRadius.circular(4),
                border: isJumpAvailablePiece
                    ? Border.all(color: AppColors.checkRed, width: 2)
                    : (isValid ? Border.all(color: Colors.white54, width: 1) : (isSelected ? Border.all(color: AppColors.cyan, width: 1) : null)),
              ),
              child: Stack(
                children: [
                  if (isJumpAvailablePiece)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.checkRed, width: 2),
                        ),
                      ).animate(
                        onComplete: (c) => c.repeat(),
                      ).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                        duration: 500.ms,
                      ),
                    ),
                  Center(child: _buildPiece(board[index], index)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPiece(PieceType? type, int index) {
    if (type == null) {
      return validMoves.contains(index)
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            )
          : const SizedBox();
    }
    bool isP1 = type == PieceType.player1 || type == PieceType.p1King;
    bool isKing = type == PieceType.p1King || type == PieceType.p2King;
    Color pColor = isP1 ? AppColors.cyan : AppColors.pink;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pColor.withValues(alpha: 0.2),
        border: Border.all(color: pColor, width: 2),
        boxShadow: [BoxShadow(color: pColor.withValues(alpha: 0.3), blurRadius: 8)],
      ),
      child: isKing
          ? Icon(Icons.star, color: pColor, size: 16)
          : (isP1 ? null : null),
    );
  }
}

class CheckersLaunchDialog extends StatefulWidget {
  const CheckersLaunchDialog({super.key});

  @override
  State<CheckersLaunchDialog> createState() => _CheckersLaunchDialogState();
}

class _CheckersLaunchDialogState extends State<CheckersLaunchDialog> {
  final p1Controller = TextEditingController(text: "Player 1");
  final p2Controller = TextEditingController(text: "Player 2");

  @override
  void dispose() {
    p1Controller.dispose();
    p2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: AlertDialog(
        backgroundColor: AppColors.bg.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const NeonText(text: "INITIALIZE CHECKERS", color: AppColors.green, fontSize: 14),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassInput(controller: p1Controller, hint: "Player 1", accentColor: AppColors.cyan),
            const SizedBox(height: 15),
            GlassInput(controller: p2Controller, hint: "Player 2", accentColor: AppColors.pink),
            const SizedBox(height: 25),
            GlassButton(
              label: "LAUNCH",
              color: AppColors.green,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, slideUpRoute(page: CheckersPage(p1: p1Controller.text, p2: p2Controller.text)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showCheckersDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const CheckersLaunchDialog());
}