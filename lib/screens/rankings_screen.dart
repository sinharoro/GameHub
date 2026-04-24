import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/game_score.dart';
import '../services/database_service.dart';

const Color kBg = Color(0xFF0D1117);
const Color kGlassBase = Color(0x1AFFFFFF);
const Color kGlassBorder = Color(0x33FFFFFF);
const Color kNeonCyan = Color(0xFF00FBFF);
const Color kNeonPink = Color(0xFFFF006E);

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('RANKINGS', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: kGlassBase.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGlassBorder),
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search player...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildRankingsList()),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    return FutureBuilder<List<GameScore>>(
      future: _getCombinedRankings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: kNeonCyan),
          );
        }
        List<GameScore> rankings = snapshot.data!;

        if (_searchQuery.isNotEmpty) {
          rankings = rankings.where((p) =>
              p.playerName.toLowerCase().contains(_searchQuery)
          ).toList();
        }

        if (rankings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard_outlined, color: Colors.white24, size: 60),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No rankings yet' : 'No results found',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: rankings.length,
          itemBuilder: (context, index) {
            final player = rankings[index];
            final isTop3 = index < 3;
            final rankBadge = isTop3 ? _getRankBadge(index) : null;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTop3
                      ? [kNeonCyan.withValues(alpha: 0.1), kNeonPink.withValues(alpha: 0.1)]
                      : [kGlassBase.withValues(alpha: 0.3), kGlassBase.withValues(alpha: 0.2)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTop3 ? (rankBadge ?? kNeonCyan) : kGlassBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isTop3
                          ? (rankBadge ?? kNeonCyan).withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTop3 ? (rankBadge ?? kNeonCyan) : Colors.white24,
                      ),
                    ),
                    child: Center(
                      child: Text('#${index + 1}',
                          style: TextStyle(
                              color: isTop3 ? rankBadge ?? kNeonCyan : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(player.playerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _statChip('W', player.wins, kNeonCyan),
                            const SizedBox(width: 8),
                            _statChip('D', player.draws, Colors.white54),
                            const SizedBox(width: 8),
                            _statChip('L', player.losses, kNeonPink),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text('${player.totalPoints}',
                          style: const TextStyle(
                              color: kNeonCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),
                      const Text('PTS',
                          style: TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label:$value', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color? _getRankBadge(int index) {
    const kMedalGold = Color(0xFFFFD700);
    const kMedalSilver = Color(0xFFA9A9A9);
    const kMedalBronze = Color(0xFFCD7F32);
    final badges = [kMedalGold, kMedalSilver, kMedalBronze];
    return index < badges.length ? badges[index] : null;
  }

  Future<List<GameScore>> _getCombinedRankings() async {
    Map<String, GameScore> combined = {};
    for (var type in GameType.values) {
      final scores = await _db.getTopScores(type, limit: 20);
      for (var score in scores) {
        if (combined.containsKey(score.playerName)) {
          final existing = combined[score.playerName]!;
          combined[score.playerName] = existing.copyWith(
            wins: existing.wins + score.wins,
            losses: existing.losses + score.losses,
            draws: existing.draws + score.draws,
            totalPoints: existing.totalPoints + score.totalPoints,
          );
        } else {
          combined[score.playerName] = score;
        }
      }
    }
    final list = combined.values.toList();
    list.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return list;
  }
}