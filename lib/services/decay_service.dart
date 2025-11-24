import 'dart:math';
import '../models/habit.dart';

class DecayService {
  // N(t) = N0 * (1/2)^(t/T)
  // t: time elapsed since last performance
  // T: half-life period
  static double calculateCurrentStrength(Habit habit) {
    final lastPerformed = habit.lastPerformed ?? habit.createdAt;
    final now = DateTime.now();
    final elapsedSeconds = now.difference(lastPerformed).inSeconds;
    
    // Avoid division by zero
    if (habit.halfLifeSeconds <= 0) return 0.0;

    final double decayFactor = pow(0.5, elapsedSeconds / habit.halfLifeSeconds).toDouble();
    final double currentStrength = habit.currentStrength * decayFactor;

    // Clamp between 0 and 100
    return currentStrength.clamp(0.0, 100.0);
  }

  static double calculateProjectedStrength(Habit habit, DateTime futureTime) {
    final lastPerformed = habit.lastPerformed ?? habit.createdAt;
    final elapsedSeconds = futureTime.difference(lastPerformed).inSeconds;
    
    if (habit.halfLifeSeconds <= 0) return 0.0;

    final double decayFactor = pow(0.5, elapsedSeconds / habit.halfLifeSeconds).toDouble();
    // We use the stored currentStrength as the base, assuming it was accurate at lastPerformed?
    // Actually, the stored currentStrength is the strength *at the time of last update*. 
    // Wait, if we update continuously, we need a reference point.
    // 
    // Let's refine: 
    // When a habit is performed, we calculate the new strength (e.g. boost it) and store that as currentStrength.
    // The decay should be calculated from that point forward.
    // So if we just performed it 1 hour ago, strength was set to 100%. Now it decays from 100%.
    // If we performed it 2 days ago, and strength was 80% then, it decays from 80%.
    
    // So the formula is: Strength(now) = Strength(at_last_update) * (1/2)^(time_since_last_update / half_life)
    
    // In our model:
    // lastPerformed is when the action happened.
    // currentStrength is the value SAVED.
    // However, if we only update currentStrength when the app opens, we need to be careful.
    // Ideally, currentStrength in the DB should represent the strength at the moment of 'lastPerformed' (or last calculation).
    // BUT, to make it stateless between opens, let's assume:
    // currentStrength in DB is the strength at the moment of 'lastPerformed' (or creation).
    // So every time we read it, we apply decay from 'lastPerformed' to 'now'.
    
    // CORRECTION:
    // If we update the DB just for viewing, we might drift.
    // Best approach: 
    // - 'currentStrength' field in DB represents the strength value *at the time of* 'lastPerformed' (or 'createdAt' if never performed).
    // - When we display, we calculate decay dynamically based on (now - lastPerformed).
    // - When we perform a habit, we:
    //    1. Calculate decayed strength up to this moment.
    //    2. Add boost (recovery).
    //    3. Save this new value as 'currentStrength' and update 'lastPerformed' to now.
    
    return habit.currentStrength * decayFactor;
  }
}

