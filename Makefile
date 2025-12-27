# Makefile for Lighten‑Up project
# Provides convenient shortcuts for Rust and TypeScript checks.

.PHONY: lint clippy fmt ts-check ts-lint ts-build rust-check rust-fmt rust-build build test

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

# Build the Rust backend.
rust-build:
	@echo "Building Rust backend..."
	@cd src-tauri && cargo build

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

# Build the frontend (catches Vite/PostCSS errors).
ts-build:
	@echo "Running frontend build..."
	@pnpm run build

# Run both TypeScript checks and linting.
ts-all: ts-check ts-lint

# ------------------------------------------------------------
# Aggregate target
# ------------------------------------------------------------

# Full build (Rust + TypeScript).
build: rust-build ts-build
	@echo "Full build completed."

# Run linting (fast checks without building).
lint: rust-check ts-all
	@echo "All checks passed."

# Full test suite (linting + building).
test: lint build
	@echo "All tests passed."
