import type { LightConfig } from '$lib/generated/types';

export const DEFAULT_COLORS = [
  '#3b82f6', // blue
  '#ef4444', // red
  '#10b981', // green
  '#f59e0b', // amber
  '#8b5cf6', // purple
  '#ec4899', // pink
  '#14b8a6', // teal
  '#f97316', // orange
  '#6366f1', // indigo
  '#84cc16', // lime
];

export function findUnusedColor(existingLights: LightConfig[]): string {
  const usedColors = new Set(existingLights.map((l) => l.color.toLowerCase()));

  // Try default colors first
  for (const color of DEFAULT_COLORS) {
    if (!usedColors.has(color.toLowerCase())) {
      return color;
    }
  }

  // Generate random unique color if all defaults are used
  return generateRandomUniqueColor(usedColors);
}

function generateRandomUniqueColor(usedColors: Set<string>, maxAttempts = 100): string {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const color = generateRandomBrightColor();
    if (!usedColors.has(color.toLowerCase())) {
      return color;
    }
  }
  // Fallback to first default color if we can't find unique
  return DEFAULT_COLORS[0];
}

function generateRandomBrightColor(): string {
  const hue = Math.floor(Math.random() * 360);
  const saturation = 70 + Math.floor(Math.random() * 20); // 70-90%
  const lightness = 50 + Math.floor(Math.random() * 10); // 50-60%

  return hslToHex(hue, saturation, lightness);
}

function hslToHex(hue: number, saturation: number, lightness: number): string {
  const h = hue / 360;
  const s = saturation / 100;
  const l = lightness / 100;
  const a = s * Math.min(l, 1 - l);

  const f = (n: number) => {
    const k = (n + h * 12) % 12;
    const color = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
    return Math.round(255 * color)
      .toString(16)
      .padStart(2, '0');
  };

  return `#${f(0)}${f(8)}${f(4)}`;
}

export function validateUniqueColor(
  light: LightConfig,
  allLights: LightConfig[]
): { isValid: boolean; duplicateLight?: LightConfig } {
  const duplicate = allLights.find((l) => l.id !== light.id && l.color === light.color);

  return {
    isValid: !duplicate,
    duplicateLight: duplicate,
  };
}
