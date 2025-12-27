# Makefile for Lighten‑Up project
# Provides convenient shortcuts for Rust and TypeScript checks.

.PHONY: lint clippy fmt ts-check ts-lint rust-check rust-fmt

# ------------------------------------------------------------
# Rust targets
# ------------------------------------------------------------

# Run Clippy with warnings treated as errors (in src-tauri).
clippy:
	@echo "Running cargo clippy in src-tauri..."
	@cd src-tauri && cargo clippy -- -D warnings

# Format the Rust code using rustfmt (in src-tauri).
fmt:
	@echo "Running cargo fmt in src-tauri..."
	@cd src-tauri && cargo fmt

# Run both clippy and fmt.
rust-check: clippy fmt

# ------------------------------------------------------------
# TypeScript / JavaScript targets
# ------------------------------------------------------------

# Run the project's TypeScript type‑checking and Svelte checks.
ts-check:
	@echo "Running npm script 'check'..."
	@pnpm run check

# Run linting (ESLint + Prettier).
ts-lint:
	@echo "Running npm script 'lint'..."
	@pnpm run lint

# Run both TypeScript checks and linting.
ts-all: ts-check ts-lint

# ------------------------------------------------------------
# Aggregate target
# ------------------------------------------------------------

lint: rust-check ts-all
	@echo "All checks passed."
