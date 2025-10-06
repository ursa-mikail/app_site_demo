import React, { useEffect, useState } from 'react';
import { fetchHealth, fetchUsers } from './api';

interface User {
  id: number;
  name: string;
  email: string;
}

const App: React.FC = () => {
  const [status, setStatus] = useState<string>('Loading...');
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    // Fetch health status from C backend
    fetchHealth()
      .then(data => setStatus(data.message))
      .catch(err => setStatus('Error connecting to backend'));

    // Fetch users from C backend
    fetchUsers()
      .then(data => {
        setUsers(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching users:', err);
        setLoading(false);
      });
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Full-Stack TypeScript + C App</h1>
      <p><strong>Backend Status:</strong> {status}</p>
      
      <h2>Users</h2>
      {loading ? (
        <p>Loading users...</p>
      ) : (
        <ul>
          {users.map(user => (
            <li key={user.id}>
              {user.name} - {user.email}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default App;
