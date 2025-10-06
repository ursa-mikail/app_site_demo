import React, { useEffect, useState } from 'react';
import { fetchHealth } from './api';

const App: React.FC = () => {
  const [status, setStatus] = useState<string>('Loading...');

  useEffect(() => {
    fetchHealth()
      .then(data => setStatus(data.message))
      .catch(err => setStatus('Error connecting to backend'));
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Full-Stack TypeScript App</h1>
      <p>Backend Status: {status}</p>
    </div>
  );
};

export default App;
