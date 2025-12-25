import type { LightColor } from '$lib/types';

/**
 * Centralized color configuration for the entire application.
 * This ensures consistency and prevents type mismatches between Rust and TypeScript.
 */

export interface ColorConfig {
  /** Semantic label for the color/status */
  label: string;
  /** Main color class for dots/indicators */
  colorClass: string;
  /** Border color class */
  borderClass: string;
  /** Button background color class */
  buttonBg: string;
  /** Button background hover color class */
  buttonBgHover: string;
  /** Button border color class */
  buttonBorder: string;
  /** Dark mode button border color class */
  buttonBorderDark: string;
  /** Dark mode button background color class */
  buttonBgDark: string;
  /** Dark mode button background hover color class */
  buttonBgHoverDark: string;
  /** Label text color class */
  labelColor: string;
  /** Dark mode label text color class */
  labelColorDark: string;
  /** Time badge background classes */
  timeBgClass: string;
}

/**
 * Complete color configuration for all LightColor variants.
 * TypeScript will enforce that all colors have configuration.
 */
export const COLOR_CONFIG: Record<LightColor, ColorConfig> = {
  Black: {
    label: 'System',
    colorClass: 'bg-black',
    borderClass: 'border-black',
    buttonBg: 'bg-slate-50',
    buttonBgHover: 'hover:bg-slate-100',
    buttonBorder: 'border-slate-300',
    buttonBorderDark: 'dark:border-slate-600',
    buttonBgDark: 'dark:bg-slate-900/30',
    buttonBgHoverDark: 'dark:hover:bg-slate-900/50',
    labelColor: 'text-slate-900',
    labelColorDark: 'dark:text-slate-100',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  Red: {
    label: 'Doctor Needed',
    colorClass: 'bg-red-500',
    borderClass: 'border-red-500',
    buttonBg: 'bg-red-50',
    buttonBgHover: 'hover:bg-red-100',
    buttonBorder: 'border-red-200',
    buttonBorderDark: 'dark:border-red-800',
    buttonBgDark: 'dark:bg-red-900/20',
    buttonBgHoverDark: 'dark:hover:bg-red-900/40',
    labelColor: 'text-red-900',
    labelColorDark: 'dark:text-red-100',
    timeBgClass: 'bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 font-bold',
  },
  Green: {
    label: 'Patient Ready',
    colorClass: 'bg-green-500',
    borderClass: 'border-green-500',
    buttonBg: 'bg-green-50',
    buttonBgHover: 'hover:bg-green-100',
    buttonBorder: 'border-green-200',
    buttonBorderDark: 'dark:border-green-800',
    buttonBgDark: 'dark:bg-green-900/20',
    buttonBgHoverDark: 'dark:hover:bg-green-900/40',
    labelColor: 'text-green-900',
    labelColorDark: 'dark:text-green-100',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  Yellow: {
    label: 'Cleaning Required',
    colorClass: 'bg-yellow-500',
    borderClass: 'border-yellow-500',
    buttonBg: 'bg-yellow-50',
    buttonBgHover: 'hover:bg-yellow-100',
    buttonBorder: 'border-yellow-200',
    buttonBorderDark: 'dark:border-yellow-800',
    buttonBgDark: 'dark:bg-yellow-900/20',
    buttonBgHoverDark: 'dark:hover:bg-yellow-900/40',
    labelColor: 'text-yellow-900',
    labelColorDark: 'dark:text-yellow-100',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  Blue: {
    label: 'Assistance',
    colorClass: 'bg-blue-500',
    borderClass: 'border-blue-500',
    buttonBg: 'bg-blue-50',
    buttonBgHover: 'hover:bg-blue-100',
    buttonBorder: 'border-blue-200',
    buttonBorderDark: 'dark:border-blue-800',
    buttonBgDark: 'dark:bg-blue-900/20',
    buttonBgHoverDark: 'dark:hover:bg-blue-900/40',
    labelColor: 'text-blue-900',
    labelColorDark: 'dark:text-blue-100',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  Magenta: {
    label: 'Vitals Taken',
    colorClass: 'bg-fuchsia-500',
    borderClass: 'border-fuchsia-500',
    buttonBg: 'bg-fuchsia-50',
    buttonBgHover: 'hover:bg-fuchsia-100',
    buttonBorder: 'border-fuchsia-200',
    buttonBorderDark: 'dark:border-fuchsia-800',
    buttonBgDark: 'dark:bg-fuchsia-900/20',
    buttonBgHoverDark: 'dark:hover:bg-fuchsia-900/40',
    labelColor: 'text-fuchsia-900',
    labelColorDark: 'dark:text-fuchsia-100',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  Cyan: {
    label: 'Transport',
    colorClass: 'bg-cyan-500',
    borderClass: 'border-cyan-500',
    buttonBg: 'bg-cyan-50',
    buttonBgHover: 'hover:bg-cyan-100',
    buttonBorder: 'border-cyan-200',
    buttonBorderDark: 'dark:border-cyan-800',
    buttonBgDark: 'dark:bg-cyan-900/20',
    buttonBgHoverDark: 'dark:hover:bg-cyan-900/40',
    labelColor: 'text-cyan-900',
    labelColorDark: 'dark:text-cyan-100',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  White: {
    label: 'Available',
    colorClass: 'bg-white dark:bg-slate-200',
    borderClass: 'border-slate-300',
    buttonBg: 'bg-white',
    buttonBgHover: 'hover:bg-slate-50',
    buttonBorder: 'border-slate-300',
    buttonBorderDark: 'dark:border-slate-500',
    buttonBgDark: 'dark:bg-slate-700',
    buttonBgHoverDark: 'dark:hover:bg-slate-600',
    labelColor: 'text-slate-700',
    labelColorDark: 'dark:text-slate-200',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
  },
  Off: {
    label: 'OFF',
    colorClass: 'bg-gray-400',
    borderClass: 'border-slate-200',
    buttonBg: 'bg-white',
    buttonBgHover: 'hover:bg-slate-50',
    buttonBorder: 'border-slate-200',
    buttonBorderDark: 'dark:border-slate-600',
    buttonBgDark: 'dark:bg-slate-800',
    buttonBgHoverDark: 'dark:hover:bg-slate-700',
    labelColor: 'text-slate-600',
    labelColorDark: 'dark:text-slate-300',
    timeBgClass: 'bg-slate-100 dark:bg-slate-700 text-slate-500 font-medium',
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
