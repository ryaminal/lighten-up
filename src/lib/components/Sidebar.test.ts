import { render, screen } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { currentView } from '../stores';
import Sidebar from './Sidebar.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('Sidebar', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    currentView.set('dashboard');
  });

  describe('Navigation Buttons', () => {
    it('should render dashboard navigation button', () => {
      render(Sidebar);

      const dashboardButton = screen.getByTitle('Active Lights');
      expect(dashboardButton).toBeInTheDocument();
    });

    it('should render config navigation button', () => {
      render(Sidebar);

      const configButton = screen.getByTitle('Light Configuration');
      expect(configButton).toBeInTheDocument();
    });

    it('should render settings button', () => {
      render(Sidebar);

      const settingsButton = screen.getByTitle('Settings');
      expect(settingsButton).toBeInTheDocument();
      expect(settingsButton.textContent).toContain('ME');
    });

    it('should navigate to dashboard when dashboard button clicked', async () => {
      const user = userEvent.setup();
      currentView.set('config');

      render(Sidebar);

      const dashboardButton = screen.getByTitle('Active Lights');
      await user.click(dashboardButton);

      // Check that currentView was updated
      let view: string = '';
      currentView.subscribe((v) => (view = v))();
      expect(view).toBe('dashboard');
    });

    it('should navigate to config when config button clicked', async () => {
      const user = userEvent.setup();
      currentView.set('dashboard');

      render(Sidebar);

      const configButton = screen.getByTitle('Light Configuration');
      await user.click(configButton);

      // Check that currentView was updated
      let view: string = '';
      currentView.subscribe((v) => (view = v))();
      expect(view).toBe('config');
    });
  });

  describe('Active State Styling', () => {
    it('should highlight dashboard button when on dashboard view', () => {
      currentView.set('dashboard');

      render(Sidebar);

      const dashboardButton = screen.getByTitle('Active Lights');
      expect(dashboardButton.className).toContain('bg-primary');
      expect(dashboardButton.className).toContain('text-white');
    });

    it('should not highlight dashboard button when on config view', () => {
      currentView.set('config');

      render(Sidebar);

      const dashboardButton = screen.getByTitle('Active Lights');
      expect(dashboardButton.className).toContain('bg-slate-800');
      expect(dashboardButton.className).toContain('text-slate-400');
    });

    it('should highlight config button when on config view', () => {
      currentView.set('config');

      render(Sidebar);

      const configButton = screen.getByTitle('Light Configuration');
      expect(configButton.className).toContain('bg-primary');
      expect(configButton.className).toContain('text-white');
    });

    it('should not highlight config button when on dashboard view', () => {
      currentView.set('dashboard');

      render(Sidebar);

      const configButton = screen.getByTitle('Light Configuration');
      expect(configButton.className).toContain('bg-slate-800');
      expect(configButton.className).toContain('text-slate-400');
    });
  });

  describe('Settings Modal', () => {
    it('should not show settings modal initially', () => {
      render(Sidebar);

      // Settings modal has a heading "Settings"
      expect(screen.queryByRole('heading', { name: 'Settings' })).not.toBeInTheDocument();
    });

    it('should open settings modal when settings button clicked', async () => {
      const user = userEvent.setup();

      render(Sidebar);

      const settingsButton = screen.getByTitle('Settings');
      await user.click(settingsButton);

      // Modal should now be visible
      expect(screen.getByRole('heading', { name: 'Settings' })).toBeInTheDocument();
    });

    it('should close settings modal when close button clicked', async () => {
      const user = userEvent.setup();

      render(Sidebar);

      // Open modal
      const settingsButton = screen.getByTitle('Settings');
      await user.click(settingsButton);

      // Verify modal is open
      expect(screen.getByRole('heading', { name: 'Settings' })).toBeInTheDocument();

      // Close modal using the close button (X)
      const closeButton = screen.getByLabelText('Close');
      await user.click(closeButton);

      // Modal should be closed
      expect(screen.queryByRole('heading', { name: 'Settings' })).not.toBeInTheDocument();
    });
  });
});
