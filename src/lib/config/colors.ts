import type { LightColor } from '$lib/types';

/**
 * Simplified color configuration - just maps light colors to hex colors and Tailwind classes.
 */

export interface ColorConfig {
  /** Hex color value */
  hex: string;
  /** Tailwind color class for dots/indicators */
  colorClass: string;
  /** Tailwind border color class */
  borderClass: string;
}

/**
 * Complete color configuration for all LightColor variants.
 * TypeScript will enforce that all colors have configuration.
 */
export const COLOR_CONFIG: Record<LightColor, ColorConfig> = {
  Black: {
    hex: '#000000',
    colorClass: 'bg-black',
    borderClass: 'border-black',
  },
  Red: {
    hex: '#ef4444',
    colorClass: 'bg-red-500',
    borderClass: 'border-red-500',
  },
  Green: {
    hex: '#22c55e',
    colorClass: 'bg-green-500',
    borderClass: 'border-green-500',
  },
  Yellow: {
    hex: '#eab308',
    colorClass: 'bg-yellow-500',
    borderClass: 'border-yellow-500',
  },
  Blue: {
    hex: '#3b82f6',
    colorClass: 'bg-blue-500',
    borderClass: 'border-blue-500',
  },
  Magenta: {
    hex: '#d946ef',
    colorClass: 'bg-fuchsia-500',
    borderClass: 'border-fuchsia-500',
  },
  Cyan: {
    hex: '#06b6d4',
    colorClass: 'bg-cyan-500',
    borderClass: 'border-cyan-500',
  },
  White: {
    hex: '#ffffff',
    colorClass: 'bg-white dark:bg-slate-200',
    borderClass: 'border-slate-300',
  },
  Off: {
    hex: '#9ca3af',
    colorClass: 'bg-gray-400',
    borderClass: 'border-slate-200',
  },
};

/**
 * Type guard to ensure exhaustive checking.
 * This will cause a compile error if a LightColor variant is missing from COLOR_CONFIG.
 */
type ExhaustiveColorCheck = {
  [K in LightColor]: ColorConfig;
};
const _exhaustiveCheck: ExhaustiveColorCheck = COLOR_CONFIG;

/**
 * Helper function to get color config safely.
 * Returns default "Off" config if color is not found (shouldn't happen with proper typing).
 */
export function getColorConfig(color: LightColor): ColorConfig {
  return COLOR_CONFIG[color] ?? COLOR_CONFIG.Off;
}
