import { render, screen, waitFor } from '@testing-library/svelte';
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { lights } from '../stores';
import { mockIPC, clearMocks } from '@tauri-apps/api/mocks';
import LightPickerModal from './LightPickerModal.svelte';

// Mock the event listener API
vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
}));

describe('LightPickerModal', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    lights.set([]);

    mockIPC(() => null);
  });

  afterEach(() => {
    clearMocks();
  });

  describe('Modal Visibility', () => {
    it('should render modal when isOpen is true', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      expect(screen.getByRole('dialog')).toBeInTheDocument();
      expect(screen.getByText('Select Light')).toBeInTheDocument();
    });

    it('should not render modal when isOpen is false', () => {
      render(LightPickerModal, {
        isOpen: false,
        onClose: () => {},
        onSelect: async () => {},
      });

      expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    });

    it('should show custom title', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        title: 'Choose Status',
      });

      expect(screen.getByText('Choose Status')).toBeInTheDocument();
    });

    it('should show subtitle when provided', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        subtitle: 'Select your availability',
      });

      expect(screen.getByText('Select your availability')).toBeInTheDocument();
    });

    it('should not show subtitle when null', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        subtitle: null,
      });

      expect(screen.queryByText('Select your availability')).not.toBeInTheDocument();
    });
  });

  describe('Light Grid Display', () => {
    it('should display enabled lights in grid', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      expect(screen.getByTitle('Urgent')).toBeInTheDocument();
      expect(screen.getByTitle('Available')).toBeInTheDocument();
    });

    it('should filter out disabled lights', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Disabled',
          color: '#0000ff',
          enabled: false,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      expect(screen.getByTitle('Urgent')).toBeInTheDocument();
      expect(screen.queryByTitle('Disabled')).not.toBeInTheDocument();
    });

    it('should filter out black lights', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Off',
          color: '#000000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Available',
          color: '#00ff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      expect(screen.queryByTitle('Off')).not.toBeInTheDocument();
      expect(screen.getByTitle('Available')).toBeInTheDocument();
    });

    it('should sort lights by priority', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Low',
          color: '#00ff00',
          enabled: true,
          priority: 2,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'High',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-3',
          name: 'Medium',
          color: '#ffff00',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      const buttons = container.querySelectorAll('button[title]');
      const titles = Array.from(buttons).map((btn) => btn.getAttribute('title'));

      // Should be in priority order: High (0), Medium (1), Low (2)
      expect(titles[0]).toBe('High');
      expect(titles[1]).toBe('Medium');
      expect(titles[2]).toBe('Low');
    });

    it('should show priority badges', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Red',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-2',
          name: 'Orange',
          color: '#ff8800',
          enabled: true,
          priority: 1,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-3',
          name: 'Yellow',
          color: '#ffff00',
          enabled: true,
          priority: 2,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-4',
          name: 'Blue',
          color: '#0000ff',
          enabled: true,
          priority: 3,
          updated_at: now,
          updated_by: 'peer-1',
        },
        {
          id: 'light-5',
          name: 'Green',
          color: '#00ff00',
          enabled: true,
          priority: 4,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      // Check for priority badges by class
      expect(container.querySelector('.bg-red-100')).toBeInTheDocument();
      expect(container.querySelector('.bg-orange-100')).toBeInTheDocument();
      expect(container.querySelector('.bg-yellow-100')).toBeInTheDocument();
      expect(container.querySelector('.bg-blue-100')).toBeInTheDocument();
      expect(container.querySelector('.bg-gray-100')).toBeInTheDocument();
    });
  });

  describe('Current Light Indicator', () => {
    it('should show current light indicator', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        currentColor: '#ff0000',
      });

      // Check for green checkmark indicator (bg-green-500)
      const currentIndicator = container.querySelector('.bg-green-500');
      expect(currentIndicator).toBeInTheDocument();
    });

    it('should not show current indicator when no current color', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        currentColor: null,
      });

      // Check for no green checkmark indicator
      const buttons = container.querySelectorAll('button[title]');
      expect(buttons[0].querySelector('.bg-green-500')).not.toBeInTheDocument();
    });
  });

  describe('Light Selection', () => {
    it('should select light when clicked', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      const button = screen.getByLabelText('Select Urgent');
      await user.click(button);

      // Check for selection indicator (pulsing animation)
      await waitFor(() => {
        const pulsingElement = container.querySelector('.animate-ping');
        expect(pulsingElement).toBeInTheDocument();
      });
    });

    it('should enable submit button after selection', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      expect(submitButton).toBeDisabled();

      const button = screen.getByLabelText('Select Urgent');
      await user.click(button);

      await waitFor(() => {
        expect(submitButton).not.toBeDisabled();
      });
    });
  });

  describe('Toggle Off Behavior', () => {
    it('should toggle off when clicking current light', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
        currentColor: '#ff0000',
        allowToggleOff: true,
        autoSubmitOnSelect: true,
      });

      const button = screen.getByLabelText('Select Urgent');
      await user.click(button);

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#000000', null);
      });
    });

    it('should show toggle-off hint text', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        allowToggleOff: true,
      });

      expect(screen.getByText('Click your current light to turn it off')).toBeInTheDocument();
    });

    it('should not show toggle-off hint when disabled', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        allowToggleOff: false,
      });

      expect(screen.queryByText('Click your current light to turn it off')).not.toBeInTheDocument();
    });

    it('should not toggle off when allowToggleOff is false', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
        currentColor: '#ff0000',
        allowToggleOff: false,
        autoSubmitOnSelect: true,
      });

      const button = screen.getByLabelText('Select Urgent');
      await user.click(button);

      await waitFor(() => {
        // Should select the same color, not toggle off
        expect(onSelect).toHaveBeenCalledWith('#ff0000', null);
      });
    });
  });

  describe('Auto-Submit Mode', () => {
    it('should auto-submit on selection', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});
      const onClose = vi.fn();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect,
        autoSubmitOnSelect: true,
      });

      const button = screen.getByLabelText('Select Urgent');
      await user.click(button);

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#ff0000', null);
        expect(onClose).toHaveBeenCalled();
      });
    });

    it('should not show submit button in auto-submit mode', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        autoSubmitOnSelect: true,
      });

      // Check for footer buttons which should not exist
      const footer = container.querySelector('.bg-gray-50');
      expect(footer).not.toBeInTheDocument();
    });

    it('should pass message in auto-submit mode', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
        autoSubmitOnSelect: true,
        showMessageInput: true,
      });

      const input = screen.getByPlaceholderText('Enter message');
      await user.type(input, 'Test message');

      const button = screen.getByLabelText('Select Urgent');
      await user.click(button);

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#ff0000', 'Test message');
      });
    });
  });

  describe('Manual Submit Mode', () => {
    it('should show submit and cancel buttons', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        autoSubmitOnSelect: false,
      });

      // Check for footer buttons
      const footer = container.querySelector('.bg-gray-50');
      expect(footer).toBeInTheDocument();
      expect(screen.getByText('Cancel')).toBeInTheDocument();
      expect(screen.getByText('Select')).toBeInTheDocument();
    });

    it('should call onSelect on submit', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});
      const onClose = vi.fn();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      await user.click(submitButton);

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#ff0000', null);
        expect(onClose).toHaveBeenCalled();
      });
    });

    it('should call onClose on cancel without calling onSelect', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});
      const onClose = vi.fn();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect,
      });

      const cancelButton = screen.getByText('Cancel');
      await user.click(cancelButton);

      expect(onClose).toHaveBeenCalled();
      expect(onSelect).not.toHaveBeenCalled();
    });

    it('should show custom submit label and icon', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        submitLabel: 'Confirm',
        submitIcon: 'done',
      });

      expect(screen.getByText('Confirm')).toBeInTheDocument();
      expect(screen.getByText('done')).toBeInTheDocument();
    });
  });

  describe('Message Input', () => {
    it('should show message input when enabled', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
      });

      expect(screen.getByLabelText(/Message/i)).toBeInTheDocument();
    });

    it('should not show message input when disabled', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: false,
      });

      expect(screen.queryByLabelText(/Message/i)).not.toBeInTheDocument();
    });

    it('should show optional label when message not required', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageRequired: false,
      });

      expect(screen.getByText('(Optional)')).toBeInTheDocument();
    });

    it('should not show optional label when message required', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageRequired: true,
      });

      expect(screen.queryByText('(Optional)')).not.toBeInTheDocument();
    });

    it('should show custom message label and placeholder', () => {
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageLabel: 'Reason',
        messagePlaceholder: 'Enter reason',
      });

      expect(screen.getByLabelText(/Reason/i)).toBeInTheDocument();
      expect(screen.getByPlaceholderText('Enter reason')).toBeInTheDocument();
    });

    it('should show character counter', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageMaxLength: 60,
      });

      expect(screen.getByText('60')).toBeInTheDocument();

      const input = screen.getByPlaceholderText('Enter message');
      await user.type(input, 'Test');

      await waitFor(() => {
        expect(screen.getByText('56')).toBeInTheDocument();
      });
    });

    it('should enforce max length', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageMaxLength: 10,
      });

      const input = screen.getByPlaceholderText('Enter message') as HTMLInputElement;
      await user.type(input, 'This is a very long message that exceeds the limit');

      expect(input.value.length).toBeLessThanOrEqual(10);
    });

    it('should disable submit when message required but empty', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageRequired: true,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      expect(submitButton).toBeDisabled();
    });

    it('should enable submit when message required and provided', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
        messageRequired: true,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const input = screen.getByPlaceholderText('Enter message');
      await user.type(input, 'Test message');

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      await waitFor(() => {
        expect(submitButton).not.toBeDisabled();
      });
    });

    it('should trim message before submitting', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
        showMessageInput: true,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const input = screen.getByPlaceholderText('Enter message');
      await user.type(input, '  Test message  ');

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      await user.click(submitButton);

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#ff0000', 'Test message');
      });
    });

    it('should pass null for empty message', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
        showMessageInput: true,
        messageRequired: false,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      await user.click(submitButton);

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#ff0000', null);
      });
    });

    it('should submit on Enter key in message input', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {});

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
        showMessageInput: true,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const input = screen.getByPlaceholderText('Enter message');
      await user.type(input, 'Test{Enter}');

      await waitFor(() => {
        expect(onSelect).toHaveBeenCalledWith('#ff0000', 'Test');
      });
    });
  });

  describe('Keyboard Navigation', () => {
    it('should close on Escape key', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onClose = vi.fn();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect: async () => {},
      });

      const dialog = container.querySelector('[role="dialog"]');
      if (dialog) {
        dialog.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
      }

      await waitFor(() => {
        expect(onClose).toHaveBeenCalled();
      });
    });

    it('should not close on Escape during submission', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onClose = vi.fn();
      let resolveSubmit: () => void;
      const onSelect = vi.fn(async () => {
        await new Promise((resolve) => {
          resolveSubmit = resolve as () => void;
        });
      });

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      user.click(submitButton);

      // Wait for submission to start
      await waitFor(() => {
        expect(screen.getByText('Submitting...')).toBeInTheDocument();
      });

      // Try to close during submission
      const dialog = container.querySelector('[role="dialog"]');
      if (dialog) {
        dialog.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
      }

      // Should not close
      expect(onClose).not.toHaveBeenCalled();

      // Finish submission
      resolveSubmit!();
    });
  });

  describe('Backdrop Click', () => {
    it('should close on backdrop click', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onClose = vi.fn();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect: async () => {},
      });

      const backdrop = container.querySelector('.fixed.inset-0');
      if (backdrop) {
        await user.click(backdrop);
        expect(onClose).toHaveBeenCalled();
      }
    });
  });

  describe('Close Button', () => {
    it('should close on close button click', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onClose = vi.fn();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      render(LightPickerModal, {
        isOpen: true,
        onClose,
        onSelect: async () => {},
      });

      const closeButton = screen.getByLabelText('Close');
      await user.click(closeButton);

      expect(onClose).toHaveBeenCalled();
    });

    it('should disable close button during submission', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 100));
      });

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      user.click(submitButton);

      await waitFor(() => {
        const closeButton = screen.getByLabelText('Close');
        expect(closeButton).toBeDisabled();
      });
    });
  });

  describe('Loading State', () => {
    it('should show loading state during submission', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 100));
      });

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      user.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Submitting...')).toBeInTheDocument();
      });
    });

    it('should disable all buttons during submission', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const onSelect = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 100));
      });

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      user.click(submitButton);

      await waitFor(() => {
        const cancelButton = screen.getByText('Cancel').closest('button');
        expect(cancelButton).toBeDisabled();
        expect(lightButton).toBeDisabled();
      });
    });
  });

  describe('Error Handling', () => {
    it('should handle submission error gracefully', async () => {
      const user = userEvent.setup();
      const now = Date.now();
      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});
      const onSelect = vi.fn(async () => {
        throw new Error('Submission failed');
      });

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect,
      });

      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const submitButton = container.querySelector('button.bg-blue-600') as HTMLButtonElement;
      await user.click(submitButton);

      await waitFor(() => {
        expect(consoleError).toHaveBeenCalled();
      });

      consoleError.mockRestore();
    });
  });

  describe('State Reset', () => {
    it('should reset state when modal closes', async () => {
      const user = userEvent.setup();
      const now = Date.now();

      lights.set([
        {
          id: 'light-1',
          name: 'Urgent',
          color: '#ff0000',
          enabled: true,
          priority: 0,
          updated_at: now,
          updated_by: 'peer-1',
        },
      ]);

      const { rerender } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
      });

      // Select light and add message
      const lightButton = screen.getByLabelText('Select Urgent');
      await user.click(lightButton);

      const input = screen.getByPlaceholderText('Enter message');
      await user.type(input, 'Test message');

      // Close modal
      rerender({
        isOpen: false,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
      });

      // Reopen modal
      rerender({
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
        showMessageInput: true,
      });

      // State should be reset
      const newInput = screen.getByPlaceholderText('Enter message') as HTMLInputElement;
      expect(newInput.value).toBe('');
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty lights array', () => {
      lights.set([]);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      const buttons = container.querySelectorAll('button[title]');
      expect(buttons.length).toBe(0);
    });

    it('should handle null lights', () => {
      lights.set(null as any);

      const { container } = render(LightPickerModal, {
        isOpen: true,
        onClose: () => {},
        onSelect: async () => {},
      });

      const buttons = container.querySelectorAll('button[title]');
      expect(buttons.length).toBe(0);
    });
  });
});
