// API base URL - points to C backend
const API_BASE_URL = 'http://localhost:8000';

// Fetch health status from C backend
export async function fetchHealth() {
  const response = await fetch(`${API_BASE_URL}/api/health`);
  if (!response.ok) {
    throw new Error('Failed to fetch health status');
  }
  return response.json();
}

// Fetch all users from C backend
export async function fetchUsers() {
  const response = await fetch(`${API_BASE_URL}/api/users`);
  if (!response.ok) {
    throw new Error('Failed to fetch users');
  }
  return response.json();
}

// Fetch single user by ID from C backend
export async function fetchUser(id: number) {
  const response = await fetch(`${API_BASE_URL}/api/users/${id}`);
  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }
  return response.json();
}
