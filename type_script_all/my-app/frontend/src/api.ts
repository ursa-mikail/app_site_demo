const API_BASE_URL = 'http://localhost:8000';

export async function fetchHealth() {
  const response = await fetch(`${API_BASE_URL}/api/health`);
  return response.json();
}
