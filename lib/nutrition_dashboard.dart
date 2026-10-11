import 'package:flutter/material.dart';

const nutritionLime = Color(0xFFB4F36A);
const nutritionCard = Color(0xFF192536);

class NutritionDashboard extends StatelessWidget {
  final int calories;
  final int protein;
  final int water;
  final VoidCallback onCalories;
  final VoidCallback onProtein;
  final VoidCallback onWater;
  const NutritionDashboard({super.key, required this.calories,
    required this.protein, required this.water, required this.onCalories,
    required this.onProtein, required this.onWater});

  @override Widget build(BuildContext context) {
    const calorieGoal = 2200;
    const proteinGoal = 140;
    const waterGoal = 2500;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF273D34), Color(0xFF182838)]),
          borderRadius: BorderRadius.circular(25)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('DAILY FUEL', style: TextStyle(color: nutritionLime,
            letterSpacing: 2, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$calories', style: const TextStyle(
                  fontSize: 44, fontWeight: FontWeight.w900)),
                const Text('CALORIES LOGGED', style: TextStyle(
                  color: Colors.white70, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 12),
                Text('${(calorieGoal - calories).clamp(0, calorieGoal)} kcal remaining',
                  style: const TextStyle(color: nutritionLime)),
              ])),
            SizedBox(width: 120, height: 120,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (calories / calorieGoal).clamp(0.0, 1.0).toDouble()),
                duration: const Duration(milliseconds: 850),
                builder: (context, value, _) => Stack(
                  alignment: Alignment.center, children: [
                  SizedBox.expand(child: CircularProgressIndicator(
                    value: value, strokeWidth: 12, strokeCap: StrokeCap.round,
                    backgroundColor: Colors.white12, color: nutritionLime)),
                  Text('${(value * 100).round()}%',
                    style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w900)),
                ]))),
          ]),
        ])),
      const SizedBox(height: 20),
      _nutritionBar('Protein', protein, proteinGoal, 'g', onProtein),
      const SizedBox(height: 12),
      _nutritionBar('Hydration', water, waterGoal, 'ml', onWater),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity,
        child: FilledButton.icon(onPressed: onCalories,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Log calories'))),
      const SizedBox(height: 16),
      const Text('Goals shown are illustrative defaults, not personalized nutrition targets.',
        style: TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }

  Widget _nutritionBar(String title, int value, int target, String unit,
      VoidCallback onTap) => Material(color: nutritionCard,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Padding(padding: const EdgeInsets.all(19),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800))),
            Text('$value / $target $unit', style: const TextStyle(
              color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 8),
            const Icon(Icons.add_circle_outline, color: nutritionLime),
          ]),
          const SizedBox(height: 15),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (value / target).clamp(0.0, 1.0).toDouble()),
            duration: const Duration(milliseconds: 700),
            builder: (context, progress, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 10,
                backgroundColor: Colors.white12, color: nutritionLime))),
        ])))));
}
