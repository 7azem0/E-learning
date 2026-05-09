import 'package:flutter/material.dart';
import '../services/study_planner_service.dart';
import '../widgets/menu.dart';

class SmartStudyPlannerScreen extends StatefulWidget {
  const SmartStudyPlannerScreen({super.key});

  @override
  State<SmartStudyPlannerScreen> createState() => _SmartStudyPlannerScreenState();
}

class _SmartStudyPlannerScreenState extends State<SmartStudyPlannerScreen> {
  final StudyPlannerService _plannerService = StudyPlannerService();
  
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _currentPlan;
  String? _statusMessage;

  int _daysPerWeek = 5;
  int _hoursPerDay = 2;

  @override
  void initState() {
    super.initState();
    _loadSavedPlan();
  }

  Future<void> _loadSavedPlan() async {
    final plan = await _plannerService.getSavedStudyPlan();
    if (mounted) {
      setState(() {
        _currentPlan = plan;
        _isLoading = false;
      });
    }
  }

  void _showConfigurationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Configure Study Plan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How many days a week can you study?', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _daysPerWeek.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: '$_daysPerWeek days',
                    onChanged: (val) => setDialogState(() => _daysPerWeek = val.toInt()),
                  ),
                  const SizedBox(height: 16),
                  Text('How many hours per day?', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _hoursPerDay.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '$_hoursPerDay hours',
                    onChanged: (val) => setDialogState(() => _hoursPerDay = val.toInt()),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _generatePlan();
                  },
                  child: const Text('Generate Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isGenerating = true;
      _statusMessage = 'Initializing...';
    });

    final result = await _plannerService.generateStudyPlan(
      daysPerWeek: _daysPerWeek,
      hoursPerDay: _hoursPerDay,
      onStatus: (status) {
        if (mounted) {
          setState(() => _statusMessage = status);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isGenerating = false;
        if (!result.startsWith('Error') && !result.startsWith('Failed') && !result.startsWith('An error') && !result.startsWith('You are not enrolled')) {
          _currentPlan = result;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result), backgroundColor: Colors.red.shade400),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Study Planner'),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: const Menu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isGenerating
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text(
                        _statusMessage ?? 'Working...',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : _currentPlan == null
                  ? _buildEmptyState()
                  : _buildPlanView(),
      floatingActionButton: (!_isLoading && !_isGenerating && _currentPlan != null)
          ? FloatingActionButton.extended(
              onPressed: _showConfigurationDialog,
              icon: const Icon(Icons.refresh),
              label: const Text('New Plan'),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'No Study Plan Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Let Gemini analyze your enrolled courses and generate a personalized weekly schedule for you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showConfigurationDialog,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Smart Plan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your personalized weekly schedule generated by Gemini based on $_daysPerWeek days/week, $_hoursPerDay hours/day.',
                  style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            _currentPlan!,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }
}
