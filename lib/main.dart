import 'dart:convert';
import 'coach.dart';
import 'welcome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FitIQ());
const bg = Color(0xFF0B111C);
const surface = Color(0xFF192536);
const accent = Color(0xFFB4F36A);

class FitIQ extends StatelessWidget {
  const FitIQ({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FitIQ', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      })),
    home: const FitShell(),
  );
}

class FitShell extends StatefulWidget {
  const FitShell({super.key});
  @override State<FitShell> createState() => _FitShellState();
}

class _FitShellState extends State<FitShell> {
  int tab = 0;
  bool loading = true;
  bool entered = false;
  bool onboarded = false;
  String name = 'Athlete';
  String goal = 'Build strength';
  List<Map<String, dynamic>> logs = [];

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> restored = [];
    try {
      restored = (jsonDecode(prefs.getString('logs') ?? '[]') as List)
          .map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) { restored = []; }
    if (!mounted) return;
    setState(() { logs = restored; name = prefs.getString('name') ?? 'Athlete';
      goal = prefs.getString('goal') ?? 'Build strength';
      onboarded = prefs.getBool('onboarded') ?? false;
      loading = false; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logs', jsonEncode(logs));
    await prefs.setString('name', name);
    await prefs.setString('goal', goal);
  }

  int _total(String type) => logs.where((e) => e['type'] == type)
      .fold<int>(0, (sum, e) => sum + (e['amount'] as int));

  Future<void> _log(String type, String title, String unit) async {
    final raw = await showDialog<String>(context: context,
      builder: (_) => EntryDialog(title: 'Log $title', label: unit, numeric: true));
    final value = raw == null ? null : int.tryParse(raw);
    if (value == null || !mounted) return;
    setState(() => logs.insert(0, {'type': type, 'title': title,
      'amount': value, 'date': DateTime.now().toIso8601String()}));
    await _save();
  }

  Widget _tile(String title, String subtitle, IconData icon, {VoidCallback? onTap, Widget? trailing}) =>
    Card(color: surface, child: ListTile(
      leading: CircleAvatar(backgroundColor: accent.withValues(alpha: 0.13),
        child: Icon(icon, color: accent)),
      title: Text(title), subtitle: Text(subtitle), onTap: onTap,
      trailing: trailing ?? const Icon(Icons.chevron_right)));

  Widget _heading(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w800)),
      Text(subtitle, style: const TextStyle(color: Colors.white70)),
    ]));

  Widget _metric(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: accent, size: 23),
      const SizedBox(height: 14),
      Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.white60,
        fontSize: 11, letterSpacing: 1.5)),
    ]));
  
  Widget _today() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Hello, $name', 'A stronger you starts today.'),
    Container(width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF314C34), Color(0xFF172B36)])),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('YOUR FOCUS', style: TextStyle(color: accent, letterSpacing: 2)),
        const SizedBox(height: 12),
        Text(goal, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => setState(() => tab = 1),
          child: const Text('Start training')),
      ])),
    const SizedBox(height: 20),
    Row(children: [
      Expanded(child: _metric('REPS', '${_total('workout')}', Icons.fitness_center)),
      const SizedBox(width: 10),
      Expanded(child: _metric('WATER', '${_total('water')} ml', Icons.water_drop)),
    ]),
    const SizedBox(height: 14),
    _tile('Total repetitions', '${_total('workout')} recorded', Icons.fitness_center),
    _tile('Water logged', '${_total('water')} ml', Icons.water_drop,
      onTap: () => _log('water', 'Water', 'Millilitres')),
  ]);

  Widget _train() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Train smarter', 'Track every set. Build consistency.'),
    const CoachPanel(),
    const SizedBox(height: 18),
    for (final exercise in ['Squats', 'Push-ups', 'Lunges', 'Dumbbell rows', 'Shoulder press'])
      _tile(exercise, 'Record completed repetitions', Icons.fitness_center,
        onTap: () => _log('workout', exercise, 'Repetitions')),
  ]);

  Widget _nutrition() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Fuel your body', 'Simple, manual nutrition tracking.'),
    _tile('Calories', '${_total('calories')} kcal logged', Icons.restaurant,
      onTap: () => _log('calories', 'Calories', 'kcal')),
    _tile('Protein', '${_total('protein')} g logged', Icons.egg,
      onTap: () => _log('protein', 'Protein', 'Grams')),
  ]);

  Widget _progress() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Your journey', 'Your latest logged activities.'),
    if (logs.isEmpty) _tile('No entries yet', 'Log a workout or meal to begin', Icons.insights),
    for (final entry in logs)
      _tile(entry['title'] as String,
        '${entry['amount']} • ${(entry['date'] as String).substring(0, 10)}',
        Icons.check_circle_outline,
        trailing: IconButton(tooltip: 'Delete entry', icon: const Icon(Icons.delete_outline),
          onPressed: () { setState(() => logs.remove(entry)); _save(); })),
  ]);

  Widget _profile() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Your space', 'Make FitIQ yours.'),
    _tile('Name', name, Icons.person, onTap: () async {
      final result = await showDialog<String>(context: context,
        builder: (_) => EntryDialog(title: 'Display name',
          label: 'Your name', initial: name));
      if (result != null && result.isNotEmpty && mounted) {
        setState(() => name = result); await _save();
      }
    }),
    _tile('Fitness goal', goal, Icons.flag, onTap: () async {
      final result = await showDialog<String>(context: context,
        builder: (ctx) => SimpleDialog(title: const Text('Choose your goal'),
          children: [for (final item in ['Build strength', 'Lose fat',
            'Build muscle', 'Improve endurance', 'General wellness'])
            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, item), child: Text(item))]));
      if (result != null && mounted) { setState(() => goal = result); await _save(); }
    }),
    _tile('Switch profile', 'Return to your local welcome screen', Icons.logout,
      onTap: () => setState(() => entered = false)),
    _tile('Clear activity', 'Delete all logged entries', Icons.delete_forever, onTap: () async {
      final confirmed = await showDialog<bool>(context: context,
        builder: (ctx) => AlertDialog(title: const Text('Delete all activity?'),
          content: const Text('This cannot be undone.'), actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ]));
      if (confirmed == true && mounted) { setState(() => logs.clear()); await _save(); }
    }),
  ]);

  @override Widget build(BuildContext context) => loading
    ? const Scaffold(body: Center(child: CircularProgressIndicator()))
    : !entered ? WelcomeScreen(savedName: name, returning: onboarded,
        onContinue: (value) async {
          setState(() { name = value; entered = true; onboarded = true; });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarded', true);
          await _save();
        })
    : Scaffold(
    appBar: AppBar(backgroundColor: bg, surfaceTintColor: Colors.transparent,
      title: const Row(children: [Icon(Icons.bolt_rounded, color: accent),
        SizedBox(width: 6), Text('FITIQ', style: TextStyle(
          color: accent, letterSpacing: 3, fontWeight: FontWeight.w900))]),
      actions: [IconButton(tooltip: 'Profile', icon: const Icon(Icons.account_circle_outlined),
        onPressed: () => setState(() => tab = 4))]),
    body: loading ? const Center(child: CircularProgressIndicator())
      : SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation,
          child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.03, 0),
            end: Offset.zero).animate(animation), child: child)),
        child: ListView(key: ValueKey(tab), padding: const EdgeInsets.all(18), children: [
          switch (tab) { 0 => _today(), 1 => _train(), 2 => _nutrition(),
            3 => _progress(), _ => _profile() }
        ]))),
    bottomNavigationBar: NavigationBar(selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Today'),
        NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Train'),
        NavigationDestination(icon: Icon(Icons.restaurant_outlined), label: 'Nutrition'),
        NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Progress'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ]),
  );
}

/// Private-by-default guidance. Python is contacted only if an HTTPS endpoint
/// was explicitly provided at build time; otherwise it works fully offline.
class CoachPanel extends StatefulWidget {
  const CoachPanel({super.key});
  @override
  State<CoachPanel> createState() => _CoachPanelState();
}

class _CoachPanelState extends State<CoachPanel> {
  final reps = TextEditingController(text: '12');
  final target = TextEditingController(text: '12');
  final weight = TextEditingController(text: '10');
  double effort = 6;
  double soreness = 2;
  CoachAdvice? advice;
  bool busy = false;

  @override
  void dispose() {
    reps.dispose();
    target.dispose();
    weight.dispose();
    super.dispose();
  }

  Future<void> _recommend() async {
    final completed = int.tryParse(reps.text);
    final planned = int.tryParse(target.text);
    final kg = double.tryParse(weight.text);
    if (completed == null || planned == null || kg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid numbers for reps and weight')));
      return;
    }
    final input = CoachInput(completed, planned, effort.round(),
      soreness.round(), kg);
    try {
      input.validate();
    } on ArgumentError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check session values and try again')));
      return;
    }
    setState(() => busy = true);
    final result = await CoachService.recommend(input);
    if (!mounted) return;
    setState(() { advice = result; busy = false; });
  }

  @override
  Widget build(BuildContext context) => Card(
    color: surface,
    child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FITIQ COACH', style: TextStyle(color: accent,
          letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Plan your next set', style: TextStyle(
          fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: reps,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Completed reps'))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: target,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Target reps'))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight kg'))),
        ]),
        const SizedBox(height: 12),
        Text('Effort: ${effort.round()} / 10'),
        Slider(value: effort, min: 1, max: 10, divisions: 9,
          label: '${effort.round()}', onChanged: (v) => setState(() => effort = v)),
        Text('Soreness: ${soreness.round()} / 10'),
        Slider(value: soreness, min: 0, max: 10, divisions: 10,
          label: '${soreness.round()}',
          onChanged: (v) => setState(() => soreness = v)),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: busy ? null : _recommend,
          icon: const Icon(Icons.auto_awesome),
          label: Text(busy ? 'Checking...' : 'Get next-set guidance'))),
        if (advice != null) ...[
          const SizedBox(height: 12),
          Text(advice!.action.toUpperCase(), style: const TextStyle(
            color: accent, fontWeight: FontWeight.bold)),
          Text('Suggested load: ${advice!.weightKg} kg'),
          Text(advice!.reason),
          Text(advice!.fromPython ? 'Python coach (HTTPS)' : 'Private offline coach',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
        const SizedBox(height: 8),
        const Text('General fitness guidance only; stop if you feel pain.',
          style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    )),
  );
}
