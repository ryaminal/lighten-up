import { render, screen } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { currentView } from '../stores';
import NavigationBar from './NavigationBar.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('NavigationBar', () => {
  let onOpenSettings: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    vi.clearAllMocks();
    currentView.set('dashboard');
    onOpenSettings = vi.fn();
  });

  describe('Button Rendering', () => {
    it('should render all navigation buttons', () => {
      render(NavigationBar, { props: { onOpenSettings } });

      expect(screen.getByLabelText('Dashboard')).toBeInTheDocument();
      expect(screen.getByLabelText('Tasks')).toBeInTheDocument();
      expect(screen.getByLabelText('People')).toBeInTheDocument();
      expect(screen.getByLabelText('Chat')).toBeInTheDocument();
      expect(screen.getByLabelText('Settings')).toBeInTheDocument();
    });

    it('should render logo with L text', () => {
      const { container } = render(NavigationBar, { props: { onOpenSettings } });

      const logo = container.querySelector('.bg-\\[\\#3b82f6\\]');
      expect(logo).toBeInTheDocument();
      expect(logo?.textContent).toBe('L');
    });
  });

  describe('Navigation Functionality', () => {
    it('should set currentView to dashboard when dashboard button clicked', async () => {
      const user = userEvent.setup();
      currentView.set('config');

      render(NavigationBar, { props: { onOpenSettings } });

      const dashboardButton = screen.getByLabelText('Dashboard');
      await user.click(dashboardButton);

      let view: string = '';
      currentView.subscribe((v) => (view = v))();
      expect(view).toBe('dashboard');
    });

    it('should set currentView to chat when chat button clicked', async () => {
      const user = userEvent.setup();
      currentView.set('dashboard');

      render(NavigationBar, { props: { onOpenSettings } });

      const chatButton = screen.getByLabelText('Chat');
      await user.click(chatButton);

      let view: string = '';
      currentView.subscribe((v) => (view = v))();
      expect(view).toBe('chat');
    });

    it('should call onOpenSettings when settings button clicked', async () => {
      const user = userEvent.setup();

      render(NavigationBar, { props: { onOpenSettings } });

      const settingsButton = screen.getByLabelText('Settings');
      await user.click(settingsButton);

      expect(onOpenSettings).toHaveBeenCalledTimes(1);
    });
  });

  describe('Non-functional Buttons', () => {
    it('should not change view when tasks button clicked', async () => {
      const user = userEvent.setup();
      currentView.set('dashboard');

      render(NavigationBar, { props: { onOpenSettings } });

      const tasksButton = screen.getByLabelText('Tasks');
      await user.click(tasksButton);

      let view: string = '';
      currentView.subscribe((v) => (view = v))();
      expect(view).toBe('dashboard'); // Should remain unchanged
    });

    it('should not change view when people button clicked', async () => {
      const user = userEvent.setup();
      currentView.set('dashboard');

      render(NavigationBar, { props: { onOpenSettings } });

      const peopleButton = screen.getByLabelText('People');
      await user.click(peopleButton);

      let view: string = '';
      currentView.subscribe((v) => (view = v))();
      expect(view).toBe('dashboard'); // Should remain unchanged
    });
  });

  describe('Styling', () => {
    it('should have active/highlighted styling on tasks button', () => {
      render(NavigationBar, { props: { onOpenSettings } });

      const tasksButton = screen.getByLabelText('Tasks');
      expect(tasksButton.className).toContain('bg-[#3b82f6]/10');
      expect(tasksButton.className).toContain('text-[#3b82f6]');
    });

    it('should have inactive styling on dashboard button', () => {
      render(NavigationBar, { props: { onOpenSettings } });

      const dashboardButton = screen.getByLabelText('Dashboard');
      expect(dashboardButton.className).toContain('text-gray-500');
      expect(dashboardButton.className).toContain('hover:bg-gray-100');
    });

    it('should position settings button at bottom', () => {
      const { container } = render(NavigationBar, { props: { onOpenSettings } });

      const settingsButton = screen.getByLabelText('Settings');
      const settingsContainer = settingsButton.closest('.mt-auto');
      expect(settingsContainer).toBeInTheDocument();
    });
  });
});
