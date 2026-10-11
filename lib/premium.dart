import 'package:flutter/material.dart';

const premiumAccent = Color(0xFFB7F56B);
const premiumSurface = Color(0xFF151F2D);

class PremiumHero extends StatelessWidget {
  final String name;
  final String goal;
  final VoidCallback onStart;
  const PremiumHero({super.key, required this.name, required this.goal, required this.onStart});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(colors: [Color(0xFF31523D), Color(0xFF17333C)])),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.auto_awesome, color: premiumAccent, size: 18),
        SizedBox(width: 9),
        Text('YOUR TRAINING SPACE', style: TextStyle(color: premiumAccent, letterSpacing: 2, fontSize: 11)),
      ]),
      const SizedBox(height: 28),
      Text('Make today count, $name.', style: const TextStyle(
        fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
      const SizedBox(height: 12),
      Text(goal, style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 25),
      FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: premiumAccent, foregroundColor: Colors.black),
        onPressed: onStart, icon: const Icon(Icons.arrow_forward),
        label: const Text('Start training')),
    ]),
  );
}

class PremiumMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const PremiumMetric({super.key, required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: premiumSurface, borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: premiumAccent),
      const SizedBox(height: 16),
      FittedBox(child: Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]),
  );
}

class PremiumAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  const PremiumAction({super.key, required this.title, required this.subtitle,
    required this.icon, this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(color: premiumSurface, borderRadius: BorderRadius.circular(19),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(19),
        child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
          CircleAvatar(backgroundColor: premiumAccent.withValues(alpha: .12),
            child: Icon(icon, color: premiumAccent)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white70),
        ]))),
    ),
  );
}
