import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FitIQ());
const bg = Color(0xFF0A101B);
const surface = Color(0xFF172131);
const accent = Color(0xFFB4F36A);

class FitIQ extends StatelessWidget {
  const FitIQ({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FitIQ', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: accent, brightness: Brightness.dark)),
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
      goal = prefs.getString('goal') ?? 'Build strength'; loading = false; });
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
    final controller = TextEditingController();
    final value = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: Text('Log $title'),
      content: TextField(controller: controller, autofocus: true,
        keyboardType: TextInputType.number, decoration: InputDecoration(labelText: unit)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final n = int.tryParse(controller.text);
          if (n != null && n > 0 && n <= 100000) Navigator.pop(ctx, n);
        }, child: const Text('Save')),
      ],
    ));
    controller.dispose();
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
    _tile('Total repetitions', '${_total('workout')} recorded', Icons.fitness_center),
    _tile('Water logged', '${_total('water')} ml', Icons.water_drop,
      onTap: () => _log('water', 'Water', 'Millilitres')),
  ]);

  Widget _train() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _heading('Train smarter', 'Track every set. Build consistency.'),
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
      final controller = TextEditingController(text: name);
      final result = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(controller: controller, maxLength: 30),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save')),
        ]));
      controller.dispose();
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

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FITIQ',
      style: TextStyle(color: accent, letterSpacing: 3, fontWeight: FontWeight.w900))),
    body: loading ? const Center(child: CircularProgressIndicator())
      : SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        switch (tab) { 0 => _today(), 1 => _train(), 2 => _nutrition(),
          3 => _progress(), _ => _profile() }
      ])),
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
