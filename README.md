# Lighten Up - P2P Status Light System

A peer-to-peer status light system built with Tauri, SvelteKit, and TypeScript.

## Type-Safe Color System

This project uses automatic TypeScript type generation from Rust to prevent type mismatches.

### How it Works

1. **Rust Definition** (`src-tauri/src/domain/light_color.rs`):
   - Single source of truth for all colors
   - Uses `ts-rs` to automatically export TypeScript types
2. **Generated Types** (`src/lib/generated/LightColor.ts`):
   - Auto-generated from Rust enum
   - **Not tracked in git** (regenerated on build)
3. **Centralized Config** (`src/lib/config/colors.ts`):
   - Maps each color to styling configuration
   - TypeScript enforces all colors have config
4. **Regression Tests** (`src-tauri/src/domain/color_regression_tests.rs`):
   - Verifies all colors serialize/deserialize correctly
   - Prevents runtime errors from type mismatches

### Adding New Colors

1. Add to Rust enum in `src-tauri/src/domain/light_color.rs`
2. Run `pnpm run generate:types` to regenerate TypeScript types
3. Add styling entry to `COLOR_CONFIG` in `src/lib/config/colors.ts`
4. Run `cargo test color_regression` to verify

TypeScript will enforce that you add configuration for the new color.

## Development

```bash
# Install dependencies
pnpm install

# Generate TypeScript types from Rust
pnpm run generate:types

# Start dev server
pnpm tauri dev

# Run tests
cargo test                  # Rust tests
pnpm check                  # TypeScript checks
```

## Recommended IDE Setup

[VS Code](https://code.visualstudio.com/) + [Svelte](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode) + [Tauri](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode) + [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer).
