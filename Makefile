# Makefile for Lighten‑Up project
# Provides convenient shortcuts for Rust and TypeScript checks.

.PHONY: lint clippy fmt ts-check ts-lint ts-build ts-test ts-test-watch e2e e2e-headed e2e-debug rust-check rust-fmt rust-build rust-test build test

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
	@echo "Running Rust build..."
	@cd src-tauri && cargo build

# Run Rust tests.
rust-test:
	@echo "Running Rust tests..."
	@cd src-tauri && cargo test --lib

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

# Run frontend tests.
ts-test:
	@echo "Running frontend tests..."
	@pnpm test

# Run frontend tests in watch mode.
ts-test-watch:
	@echo "Running frontend tests in watch mode..."
	@pnpm test:watch

# Run E2E tests with Playwright.
e2e:
	@echo "Running E2E tests..."
	@pnpm run test:e2e

# Run E2E tests in headed mode (visible browser).
e2e-headed:
	@echo "Running E2E tests in headed mode..."
	@pnpm run test:e2e:headed

# Run E2E tests in debug mode.
e2e-debug:
	@echo "Running E2E tests in debug mode..."
	@pnpm run test:e2e:debug

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

# Full test suite (linting + testing + building).
test: lint rust-test ts-test build
	@echo "All tests passed."
