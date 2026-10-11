"""Conservative, deterministic training suggestions; not medical advice."""
from dataclasses import dataclass

@dataclass(frozen=True)
class Session:
    completed_reps: int
    target_reps: int
    effort: int
    soreness: int
    weight_kg: float

def next_session(s: Session) -> dict:
    if not (0 <= s.completed_reps <= 1000 and 1 <= s.target_reps <= 1000
            and 1 <= s.effort <= 10 and 0 <= s.soreness <= 10
            and 0 <= s.weight_kg <= 1000):
        raise ValueError("Invalid session metrics")
    if s.soreness >= 7:
        return {"action": "recover", "weight_kg": s.weight_kg, "reason": "High soreness: prioritize recovery"}
    if s.effort >= 9 or s.completed_reps < s.target_reps:
        return {"action": "reduce", "weight_kg": round(s.weight_kg * 0.95, 2), "reason": "Reduce load to improve quality"}
    if s.completed_reps >= s.target_reps and s.effort <= 7 and s.soreness <= 4:
        return {"action": "progress", "weight_kg": round(s.weight_kg * 1.025, 2), "reason": "Small progressive overload"}
    return {"action": "maintain", "weight_kg": s.weight_kg, "reason": "Repeat and consolidate"}
