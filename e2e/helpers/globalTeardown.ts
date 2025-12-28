import { execSync } from 'child_process';

/**
 * Global teardown for Playwright tests
 * Ensures all dev servers and related processes are killed
 */
async function globalTeardown() {
  console.log('Running global teardown...');

  try {
    // Kill any vite dev server processes
    execSync('pkill -f "vite dev" || true', { stdio: 'inherit' });

    // Kill any node processes running on port 5173 or 1420
    execSync('lsof -ti:5173 | xargs kill -9 2>/dev/null || true', { stdio: 'inherit' });
    execSync('lsof -ti:1420 | xargs kill -9 2>/dev/null || true', { stdio: 'inherit' });

    console.log('Cleanup complete');
  } catch (error) {
    console.error('Error during cleanup:', error);
  }
}

export default globalTeardown;
