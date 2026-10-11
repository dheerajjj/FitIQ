import 'package:flutter/material.dart';

const _ink = Color(0xFF0B111C);
const _lime = Color(0xFFB4F36A);

/// Device-local profile entry, not a remote account or security boundary.
class WelcomeScreen extends StatefulWidget {
  final String savedName;
  final bool returning;
  final ValueChanged<String> onContinue;
  const WelcomeScreen({super.key, required this.savedName,
    required this.returning, required this.onContinue});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _name;
  late final AnimationController _animation;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: widget.savedName == 'Athlete' ? '' : widget.savedName);
    _animation = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 650))..forward();
  }
  @override
  void dispose() { _name.dispose(); _animation.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final entrance = CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic);
    return Scaffold(
      backgroundColor: _ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: FadeTransition(
            opacity: entrance,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.bolt_rounded, color: _lime, size: 30),
                  SizedBox(width: 8),
                  Text('FITIQ', style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w900, letterSpacing: 4, color: _lime)),
                ]),
                const SizedBox(height: 52),
                Center(child: Container(
                  width: 200, height: 200,
                  decoration: const BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Color(0xFF365640), Color(0xFF172D2D), _ink,
                    ])),
                  child: const Icon(Icons.monitor_heart_outlined,
                    color: _lime, size: 100),
                )),
                const SizedBox(height: 40),
                Text(widget.returning ? 'WELCOME BACK' : 'WELCOME TO YOUR NEXT LEVEL',
                  style: const TextStyle(color: _lime, fontSize: 12,
                    letterSpacing: 2.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(widget.returning ? 'Ready for another\\nstrong day?' :
                  'Make every\\nrep count.',
                  style: const TextStyle(fontSize: 42, height: 1.08,
                    fontWeight: FontWeight.w900, letterSpacing: -1.6)),
                const SizedBox(height: 16),
                const Text('A focused training space for strength, recovery, '
                  'nutrition and progress. Built to work offline.',
                  style: TextStyle(color: Color(0xFFABB6C5), height: 1.5)),
                const SizedBox(height: 28),
                TextField(key: const Key('profileName'), controller: _name,
                  maxLength: 30, textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Your name', prefixIcon: const Icon(Icons.person_outline),
                    filled: true, fillColor: const Color(0xFF1A2636),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none))),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, height: 56,
                  child: FilledButton.icon(
                    key: const Key('enterFitIQ'),
                    style: FilledButton.styleFrom(backgroundColor: _lime,
                      foregroundColor: _ink, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18))),
                    onPressed: () {
                      final name = _name.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter your name to continue')));
                        return;
                      }
                      widget.onContinue(name);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(widget.returning ? 'Enter FitIQ' : 'Create local profile',
                      style: const TextStyle(fontWeight: FontWeight.w800)))),
                const SizedBox(height: 18),
                const Center(child: Text('Device-local profile • No cloud account or password',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8291A2), fontSize: 12))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog owns and disposes its controller after the route is removed.
class EntryDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initial;
  final bool numeric;
  const EntryDialog({super.key, required this.title, required this.label,
    this.initial = '', this.numeric = false});
  @override State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  late final TextEditingController _controller;
  @override void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  void _save() {
    final value = _controller.text.trim();
    if (widget.numeric) {
      final n = int.tryParse(value);
      if (n == null || n <= 0 || n > 100000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a positive number up to 100000')));
        return;
      }
    } else if (value.isEmpty) {
      return;
    }
    Navigator.of(context).pop(value);
  }
  @override Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(controller: _controller,
      autofocus: true, maxLength: widget.numeric ? null : 30,
      keyboardType: widget.numeric ? TextInputType.number : TextInputType.text,
      onSubmitted: (_) => _save(),
      decoration: InputDecoration(labelText: widget.label)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ]);
}
