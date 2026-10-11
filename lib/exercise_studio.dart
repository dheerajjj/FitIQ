import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const workoutInk = Color(0xFF0B111C);
const workoutCard = Color(0xFF192536);
const workoutLime = Color(0xFFB4F36A);

class Exercise {
  final String name;
  final String muscle;
  final String equipment;
  final String instruction;
  final int sets;
  final int reps;
  const Exercise(this.name, this.muscle, this.equipment, this.instruction,
      {this.sets = 3, this.reps = 12});
}

const exerciseCatalog = <Exercise>[
  Exercise('Dumbbell bench press', 'Chest', 'Dumbbells', 'Keep shoulder blades set, lower under control, and press without bouncing.'),
  Exercise('Incline dumbbell press', 'Chest', 'Dumbbells', 'Set the bench to a moderate incline; keep wrists stacked above elbows.'),
  Exercise('Push-ups', 'Chest', 'Bodyweight', 'Keep your body straight and lower until elbows reach a comfortable depth.'),
  Exercise('Lat pulldown', 'Back', 'Cable machine', 'Pull elbows toward your ribs; avoid swinging your torso.'),
  Exercise('Seated cable row', 'Back', 'Cable machine', 'Pull to your lower ribs and return slowly without rounding.'),
  Exercise('One-arm dumbbell row', 'Back', 'Dumbbell', 'Support your torso and drive your elbow toward your hip.'),
  Exercise('Goblet squat', 'Legs', 'Dumbbell', 'Keep your heels grounded and squat to a comfortable depth.'),
  Exercise('Romanian deadlift', 'Legs', 'Dumbbells', 'Hinge at the hips with a neutral back and soft knees.'),
  Exercise('Walking lunges', 'Legs', 'Bodyweight', 'Step forward with control and keep your front knee aligned.'),
  Exercise('Dumbbell shoulder press', 'Shoulders', 'Dumbbells', 'Brace your core and press in a comfortable shoulder range.'),
  Exercise('Lateral raise', 'Shoulders', 'Dumbbells', 'Use a light load, soft elbows, and controlled movement.'),
  Exercise('Rear delt fly', 'Shoulders', 'Dumbbells', 'Hinge forward and raise arms out without shrugging.'),
  Exercise('Dumbbell curl', 'Arms', 'Dumbbells', 'Keep elbows by your sides and avoid momentum.'),
  Exercise('Hammer curl', 'Arms', 'Dumbbells', 'Maintain neutral wrists and control the lowering phase.'),
  Exercise('Triceps pushdown', 'Arms', 'Cable machine', 'Keep upper arms still and extend at the elbows.'),
  Exercise('Plank', 'Core', 'Bodyweight', 'Brace your abdomen and keep your hips aligned.', reps: 30),
  Exercise('Dead bug', 'Core', 'Bodyweight', 'Keep your lower back stable as opposite limbs extend.'),
  Exercise('Reverse crunch', 'Core', 'Bodyweight', 'Curl your pelvis upward gently without swinging.'),
];

const muscleGroups = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

class ExerciseStudio extends StatefulWidget {
  final void Function(String exercise, int reps) onLog;
  const ExerciseStudio({super.key, required this.onLog});
  @override State<ExerciseStudio> createState() => _ExerciseStudioState();
}

class _ExerciseStudioState extends State<ExerciseStudio> {
  String group = 'All';
  String query = '';
  final search = TextEditingController();
  @override void dispose() { search.dispose(); super.dispose(); }

  Future<void> _openVideo(Exercise exercise) async {
    final uri = Uri.https('www.youtube.com', '/results',
      {'search_query': '${exercise.name} exercise proper form tutorial'});
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open video search on this device')));
    }
  }

  void _showExercise(Exercise exercise) {
    var completed = 0;
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      backgroundColor: workoutCard,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => SafeArea(
        child: Padding(padding: EdgeInsets.fromLTRB(24, 12, 24,
          24 + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.muscle.toUpperCase(), style: const TextStyle(
              color: workoutLime, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(exercise.name, style: const TextStyle(fontSize: 27,
              fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('${exercise.sets} sets · ${exercise.reps} reps · ${exercise.equipment}',
              style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            Text(exercise.instruction),
            const SizedBox(height: 20),
            OutlinedButton.icon(onPressed: () => _openVideo(exercise),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Find demonstration videos')),
            const SizedBox(height: 18),
            Text('Completed sets: $completed / ${exercise.sets}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: completed / exercise.sets,
              minHeight: 8, color: workoutLime,
              backgroundColor: Colors.white12),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: completed >= exercise.sets ? null : () {
                widget.onLog(exercise.name, exercise.reps);
                update(() => completed++);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: Text(completed >= exercise.sets
                ? 'Session complete' : 'Complete set · ${exercise.reps} reps'))),
          ]))),
      )),
    );
  }

  @override Widget build(BuildContext context) {
    final filtered = exerciseCatalog.where((e) =>
      (group == 'All' || e.muscle == group) &&
      ('${e.name} ${e.muscle} ${e.equipment}'.toLowerCase()
        .contains(query.toLowerCase()))).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(23),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF264837), Color(0xFF142D32)]),
          borderRadius: BorderRadius.circular(25)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FITIQ TRAINING STUDIO', style: TextStyle(color: workoutLime,
            fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
          SizedBox(height: 12),
          Text('Train every muscle.\nTrack every rep.',
            style: TextStyle(fontSize: 28, height: 1.1,
              fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text('Choose a body area, explore technique and log each set.',
            style: TextStyle(color: Colors.white70)),
        ])),
      const SizedBox(height: 20),
      TextField(controller: search, onChanged: (v) => setState(() => query = v),
        decoration: InputDecoration(
          hintText: 'Search exercises or equipment',
          prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: workoutCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none))),
      const SizedBox(height: 15),
      SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final muscle in muscleGroups) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(label: Text(muscle), selected: group == muscle,
              onSelected: (_) => setState(() => group = muscle),
              selectedColor: workoutLime, labelStyle: TextStyle(
                color: group == muscle ? workoutInk : Colors.white))),
        ])),
      const SizedBox(height: 23),
      Text('${filtered.length} EXERCISES', style: const TextStyle(
        color: workoutLime, letterSpacing: 2,
        fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      for (final exercise in filtered) Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Material(color: workoutCard, borderRadius: BorderRadius.circular(19),
          child: InkWell(onTap: () => _showExercise(exercise),
            borderRadius: BorderRadius.circular(19),
            child: Padding(padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: workoutLime.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.fitness_center, color: workoutLime)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 5),
                    Text('${exercise.muscle} · ${exercise.sets} × ${exercise.reps} · ${exercise.equipment}',
                      style: const TextStyle(color: Colors.white70,
                        fontSize: 11)),
                  ])),
                const Icon(Icons.play_circle_outline, color: workoutLime),
              ]))))),
      const SizedBox(height: 15),
      const Text('Video links open external YouTube search results; they are not vetted or hosted by FitIQ.',
        style: TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }
}
