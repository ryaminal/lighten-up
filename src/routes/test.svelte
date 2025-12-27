<script lang="ts">
  import { onMount } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';

  // Define minimal types for the test UI to avoid "any" lint errors.
  interface Peer {
    peer_id: string;
    peer_name: string;
    light_state: { color: string };
  }
  interface Light {
    id: string;
    name: string;
    color: string;
    priority: number;
  }
  interface ChatMsg {
    peer_name: string;
    content: string;
    timestamp?: number;
  }

  let peers: Peer[] = [];
  let lights: Light[] = [];
  let messages: ChatMsg[] = [];
  let myColor = '#ff0000';
  let chatInput = '';

  async function loadData() {
    try {
      peers = await invoke('get_peers');
      lights = await invoke('get_lights');
      messages = await invoke('get_chat_messages');
    } catch (e) {
      console.error('Failed to load data:', e);
    }
  }

  async function setColor() {
    try {
      await invoke('set_light_color', { color: myColor });
      console.log('Color set to:', myColor);
    } catch (e) {
      console.error('Failed to set color:', e);
    }
  }

  async function sendMessage() {
    if (!chatInput.trim()) return;
    try {
      await invoke('send_chat_message', { content: chatInput });
      chatInput = '';
      await loadData();
    } catch (e) {
      console.error('Failed to send message:', e);
    }
  }

  onMount(() => {
    loadData();
    const interval = setInterval(loadData, 2000);
    return () => clearInterval(interval);
  });
</script>

<div class="container">
  <h1>Lighten Up - Test UI</h1>

  <section>
    <h2>My Light Color</h2>
    <div class="color-picker">
      <input type="color" bind:value={myColor} />
      <button on:click={setColor}>Set Color</button>
      <div class="color-preview" style="background-color: {myColor};"></div>
    </div>
  </section>

  <section>
    <h2>Peers ({peers.length})</h2>
    <div class="peers">
      {#each peers as peer (peer.peer_id)}
        <div class="peer-card">
          <div class="peer-color" style="background-color: {peer.light_state.color};"></div>
          <div>
            <strong>{peer.peer_name}</strong>
            <br />
            <small>{peer.peer_id.slice(0, 12)}...</small>
          </div>
        </div>
      {/each}
      {#if peers.length === 0}
        <p>No peers online</p>
      {/if}
    </div>
  </section>

  <section>
    <h2>Chat ({messages.length})</h2>
    <div class="chat">
      <div class="messages">
        {#each messages as msg (msg)}
          <div class="message">
            <strong>{msg.peer_name}:</strong>
            {msg.content}
          </div>
        {/each}
        {#if messages.length === 0}
          <p>No messages yet</p>
        {/if}
      </div>
      <div class="chat-input">
        <input
          type="text"
          bind:value={chatInput}
          on:keypress={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Type a message..."
        />
        <button on:click={sendMessage}>Send</button>
      </div>
    </div>
  </section>

  <section>
    <h2>Lights Config ({lights.length})</h2>
    <div class="lights">
      {#each lights as light (light.id)}
        <div class="light-card">
          <div class="light-color" style="background-color: {light.color};"></div>
          <div>
            <strong>{light.name}</strong>
            <br />
            <small>Priority: {light.priority}</small>
          </div>
        </div>
      {/each}
      {#if lights.length === 0}
        <p>No lights configured</p>
      {/if}
    </div>
  </section>
</div>

<style>
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    font-family:
      system-ui,
      -apple-system,
      sans-serif;
  }

  h1 {
    margin-bottom: 30px;
  }

  section {
    margin-bottom: 30px;
    padding: 20px;
    background: #f5f5f5;
    border-radius: 8px;
  }

  h2 {
    margin-top: 0;
    margin-bottom: 15px;
  }

  .color-picker {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .color-preview {
    width: 50px;
    height: 50px;
    border-radius: 4px;
    border: 2px solid #ccc;
  }

  .peers,
  .lights {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 10px;
  }

  .peer-card,
  .light-card {
    display: flex;
    gap: 10px;
    padding: 10px;
    background: white;
    border-radius: 4px;
    align-items: center;
  }

  .peer-color,
  .light-color {
    width: 40px;
    height: 40px;
    border-radius: 4px;
    border: 2px solid #ccc;
    flex-shrink: 0;
  }

  .chat {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .messages {
    background: white;
    padding: 15px;
    border-radius: 4px;
    min-height: 200px;
    max-height: 400px;
    overflow-y: auto;
  }

  .message {
    margin-bottom: 10px;
    padding: 8px;
    background: #f9f9f9;
    border-radius: 4px;
  }

  .chat-input {
    display: flex;
    gap: 10px;
  }

  .chat-input input {
    flex: 1;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 4px;
  }

  button {
    padding: 10px 20px;
    background: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }

  button:hover {
    background: #0056b3;
  }

  input[type='color'] {
    width: 60px;
    height: 40px;
    border: none;
    cursor: pointer;
  }
</style>
