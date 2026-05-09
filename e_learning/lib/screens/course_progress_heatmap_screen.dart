import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../widgets/menu.dart';

class CourseProgressHeatmapScreen extends StatefulWidget {
  const CourseProgressHeatmapScreen({super.key});

  @override
  State<CourseProgressHeatmapScreen> createState() =>
      _CourseProgressHeatmapScreenState();
}

class _CourseProgressHeatmapScreenState
    extends State<CourseProgressHeatmapScreen> {
  bool _isLoading = true;
  Map<String, int> _activityMap = {};
  int _totalActivities = 0;
  int _activeDays = 0;
  int _currentStreak = 0;

  // 13 past weeks + 4 future weeks = 17 total columns (GitHub style)
  static const int _pastWeeks = 13;
  static const int _futureWeeks = 4;
  static const int _totalWeeks = _pastWeeks + _futureWeeks;
  static const int _days = _pastWeeks * 7; // only fetch past data

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final map = await ActivityService().getActivityMap(days: _days);

    int total = 0;
    int active = 0;
    int streak = 0;

    // Calculate current streak (consecutive days from today backwards)
    final today = DateTime.now();
    for (int i = 0; i <= 365; i++) {
      final d = today.subtract(Duration(days: i));
      final key = _fmtDate(d);
      if ((map[key] ?? 0) > 0) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    for (var count in map.values) {
      total += count;
      active++;
    }

    if (mounted) {
      setState(() {
        _activityMap = map;
        _totalActivities = total;
        _activeDays = active;
        _currentStreak = streak;
        _isLoading = false;
      });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _cellColor(int count) {
    if (count == 0) return const Color(0xFFEBEDF0);
    if (count == 1) return const Color(0xFF9BE9A8);
    if (count == 2) return const Color(0xFF40C463);
    if (count <= 4) return const Color(0xFF30A14E);
    return const Color(0xFF216E39);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Activity'),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      drawer: const Menu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatsRow(),
                const SizedBox(height: 28),
                Text(
                  'Study Heatmap',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last 13 weeks + upcoming 4 weeks',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                _buildHeatmap(),
                const SizedBox(height: 12),
                _buildLegend(),
                const SizedBox(height: 32),
                _buildInfoCard(),
              ],
            ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          label: 'Total Activities',
          value: '$_totalActivities',
          icon: Icons.bolt,
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Active Days',
          value: '$_activeDays',
          icon: Icons.calendar_today,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Day Streak 🔥',
          value: '$_currentStreak',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildHeatmap() {
    final today = DateTime.now();
    final todayDow = (today.weekday - 1) % 7; // Mon=0 … Sun=6
    final thisMonday = today.subtract(Duration(days: todayDow));
    const cellSize = 14.0;
    const spacing = 3.0;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day-of-week labels
          Column(
            children: List.generate(7, (dow) {
              return SizedBox(
                height: cellSize + spacing,
                width: 28,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    labels[dow],
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          // All week columns: _pastWeeks behind + _futureWeeks ahead
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_totalWeeks, (weekIndex) {
              // weekIndex 0 = oldest, _pastWeeks-1 = current week, _totalWeeks-1 = furthest future
              final weeksFromCurrent = weekIndex - (_pastWeeks - 1);
              final weekMonday = thisMonday
                  .add(Duration(days: weeksFromCurrent * 7));
              return Padding(
                padding: EdgeInsets.only(
                    right: weekIndex < _totalWeeks - 1 ? spacing : 0),
                child: Column(
                  children: List.generate(7, (dow) {
                    final date = weekMonday.add(Duration(days: dow));
                    final isFuture = date.isAfter(today);
                    final key = _fmtDate(date);
                    final count = isFuture ? 0 : (_activityMap[key] ?? 0);
                    return Tooltip(
                      message: isFuture
                          ? _displayDate(date)
                          : count == 0
                              ? 'No activity · ${_displayDate(date)}'
                              : '$count ${count == 1 ? 'activity' : 'activities'} · ${_displayDate(date)}',
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        margin: EdgeInsets.only(
                            bottom: dow < 6 ? spacing : 0),
                        decoration: BoxDecoration(
                          color: isFuture
                              ? const Color(0xFFF0F0F0)
                              : _cellColor(count),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _displayDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';

  Widget _buildLegend() {
    return Row(
      children: [
        Text('Less',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(width: 6),
        _HeatCell(color: _cellColor(0), tooltip: ''),
        _HeatCell(color: _cellColor(1), tooltip: ''),
        _HeatCell(color: _cellColor(2), tooltip: ''),
        _HeatCell(color: _cellColor(3), tooltip: ''),
        _HeatCell(color: _cellColor(5), tooltip: ''),
        const SizedBox(width: 6),
        Text('More',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: const Color(0xFF6366F1).withOpacity(0.07),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.2)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 18),
                SizedBox(width: 8),
                Text(
                  'What counts as activity?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _BulletPoint('Opening a lesson (PDF or video)'),
            _BulletPoint('Completing a quiz'),
            _BulletPoint('Logging your learning mood'),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final Color color;
  final String tooltip;

  const _HeatCell({required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    if (tooltip.isEmpty) return cell;
    return Tooltip(message: tooltip, child: cell);
  }
}

class _EmptyCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 36, height: 36, margin: const EdgeInsets.all(3));
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF6366F1))),
          Expanded(
            child: Text(
              text,
              style:
                  TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
