import { getLights, createLight, updateLight, deleteLight } from '$lib/tauri';
import type { LightConfig } from '$lib/generated/types';
import { findUnusedColor } from './lightColorUtils';

export async function addNewLight(
  existingLights: LightConfig[],
  peerId: string
): Promise<LightConfig[]> {
  const newColor = findUnusedColor(existingLights);

  const newLight: LightConfig = {
    id: crypto.randomUUID(),
    color: newColor,
    name: 'New Light',
    enabled: true,
    priority: existingLights.length,
    updated_at: Math.floor(Date.now() / 1000),
    updated_by: peerId,
  };

  await createLight(newLight);
  const refreshed = await getLights();
  return refreshed.sort((a, b) => a.priority - b.priority);
}

export async function removeLight(id: string): Promise<LightConfig[]> {
  await deleteLight(id);
  const refreshed = await getLights();
  return refreshed.sort((a, b) => a.priority - b.priority);
}

export async function updateLightDetails(
  light: LightConfig,
  peerId: string
): Promise<LightConfig[]> {
  light.updated_at = Math.floor(Date.now() / 1000);
  light.updated_by = peerId;
  await updateLight(light);
  const refreshed = await getLights();
  return refreshed.sort((a, b) => a.priority - b.priority);
}

export async function moveLightPriority(
  lights: LightConfig[],
  fromIndex: number,
  toIndex: number,
  peerId: string
): Promise<LightConfig[]> {
  const newLights = [...lights];
  const [movedLight] = newLights.splice(fromIndex, 1);
  newLights.splice(toIndex, 0, movedLight);

  const updatedLights = newLights.map((light, i) => ({
    ...light,
    priority: i,
    updated_at: Math.floor(Date.now() / 1000),
    updated_by: peerId,
  }));

  const minIndex = Math.min(fromIndex, toIndex);
  const maxIndex = Math.max(fromIndex, toIndex);

  for (let i = minIndex; i <= maxIndex; i++) {
    await updateLight(updatedLights[i]);
  }

  const refreshed = await getLights();
  return refreshed.sort((a, b) => a.priority - b.priority);
}

export async function normalizePriorities(
  lights: LightConfig[],
  peerId: string
): Promise<LightConfig[]> {
  const needsNormalization = lights.some((light, index) => light.priority !== index);

  if (!needsNormalization) {
    return lights;
  }

  console.log('[Settings] Normalizing priorities to fix duplicates');

  const normalizedLights = lights.map((light, index) => ({
    ...light,
    priority: index,
    updated_at: Math.floor(Date.now() / 1000),
    updated_by: peerId,
  }));

  for (const light of normalizedLights) {
    await updateLight(light);
  }

  const refreshed = await getLights();
  return refreshed.sort((a, b) => a.priority - b.priority);
}
