export function calculateEstimated1RM(weightKg: number, reps: number): number {
  if (reps === 1) return weightKg;
  if (reps <= 0 || weightKg <= 0) return 0;
  if (reps > 15) return Math.round(weightKg * (1 + reps / 30) * 10) / 10;
  const epley = weightKg * (1 + reps / 30);
  const brzycki = weightKg * (36 / (37 - reps));
  return Math.round(((epley + brzycki) / 2) * 10) / 10;
}

export interface PlateCount {
  plateWeight: number;
  countEachSide: number;
}

export interface PlateResult {
  targetWeight: number;
  barWeight: number;
  weightPerSide: number;
  plates: PlateCount[];
  remainder: number;
}

export function calculatePlates(
  targetWeight: number,
  barWeight: number = 20,
  availablePlates: number[] = [25, 20, 15, 10, 5, 2.5, 1.25]
): PlateResult {
  if (targetWeight <= barWeight) {
    return { targetWeight, barWeight, weightPerSide: 0, plates: [], remainder: 0 };
  }
  let weightPerSide = (targetWeight - barWeight) / 2;
  let currentRemainder = weightPerSide;
  const plates: PlateCount[] = [];
  const sortedPlates = [...availablePlates].sort((a, b) => b - a);
  for (const plate of sortedPlates) {
    if (currentRemainder >= plate) {
      const count = Math.floor(currentRemainder / plate);
      plates.push({ plateWeight: plate, countEachSide: count });
      currentRemainder = Math.round((currentRemainder - count * plate) * 100) / 100;
    }
  }
  return { targetWeight, barWeight, weightPerSide, plates, remainder: currentRemainder * 2 };
}

export interface WarmupSet {
  setNumber: number;
  weightKg: number;
  reps: number;
  percentOfWorkingWeight: number;
  description: string;
}

export function calculateWarmupSets(workingWeightKg: number, barWeightKg: number = 20): WarmupSet[] {
  if (workingWeightKg <= barWeightKg) {
    return [{ setNumber: 1, weightKg: barWeightKg, reps: 10, percentOfWorkingWeight: 100, description: 'Khởi động đòn không' }];
  }
  return [
    { setNumber: 1, weightKg: barWeightKg, reps: 10, percentOfWorkingWeight: Math.round((barWeightKg / workingWeightKg) * 100), description: 'Làm quen đòn không' },
    { setNumber: 2, weightKg: Math.round((workingWeightKg * 0.5) / 2.5) * 2.5, reps: 5, percentOfWorkingWeight: 50, description: '50% tạ chính' },
    { setNumber: 3, weightKg: Math.round((workingWeightKg * 0.7) / 2.5) * 2.5, reps: 3, percentOfWorkingWeight: 70, description: '70% tạ chính' },
    { setNumber: 4, weightKg: Math.round((workingWeightKg * 0.85) / 2.5) * 2.5, reps: 1, percentOfWorkingWeight: 85, description: '85% tạ chính' },
  ];
}

export interface ProgressionRecommendation {
  nextWeightKg: number;
  nextRepsMin: number;
  nextRepsMax: number;
  shouldIncreaseWeight: boolean;
  message: string;
}

export function recommendDoubleProgression(
  lastWeightKg: number,
  completedSetsReps: number[],
  targetMinReps: number = 8,
  targetMaxReps: number = 12,
  weightIncrementKg: number = 2.5
): ProgressionRecommendation {
  if (completedSetsReps.length === 0) {
    return { nextWeightKg: lastWeightKg, nextRepsMin: targetMinReps, nextRepsMax: targetMaxReps, shouldIncreaseWeight: false, message: 'Chưa có dữ liệu.' };
  }
  const isMaxedOut = completedSetsReps.every((reps) => reps >= targetMaxReps);
  if (isMaxedOut) {
    return {
      nextWeightKg: lastWeightKg + weightIncrementKg,
      nextRepsMin: targetMinReps,
      nextRepsMax: targetMaxReps,
      shouldIncreaseWeight: true,
      message: `Đạt ${targetMaxReps} reps toàn bộ set! Hãy tăng lên ${lastWeightKg + weightIncrementKg}kg ở buổi sau.`,
    };
  }
  return {
    nextWeightKg: lastWeightKg,
    nextRepsMin: targetMinReps,
    nextRepsMax: targetMaxReps,
    shouldIncreaseWeight: false,
    message: `Duy trì ${lastWeightKg}kg và tiếp tục tăng số reps lên ${targetMaxReps}.`,
  };
}
