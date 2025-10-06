#!/bin/bash
# chmod +x setup_folder_and_files_struct.sh
# ./setup_folder_and_files_struct.sh

set -e

echo "Creating full-stack TypeScript application structure..."

# Create root directory
ROOT_DIR="my-app"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# Create directory structure
mkdir -p frontend/src frontend/public frontend/dist
mkdir -p backend/src backend/dist

# Create placeholder files
touch frontend/src/{index.tsx,App.tsx,api.ts}
touch backend/src/{index.ts,types.ts}

# Create frontend package.json
cat > frontend/package.json << 'EOF'
{
  "name": "frontend",
  "version": "1.0.0",
  "scripts": {
    "start": "webpack serve --mode development",
    "build": "webpack --mode production"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.0.0",
    "webpack": "^5.88.0",
    "webpack-cli": "^5.1.0",
    "webpack-dev-server": "^4.15.0",
    "ts-loader": "^9.4.0",
    "html-webpack-plugin": "^5.5.0"
  }
}
EOF

# Create frontend tsconfig.json
cat > frontend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES6",
    "jsx": "react",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "./dist"
  },
  "include": ["src"]
}
EOF

# Create frontend webpack config
cat > frontend/webpack.config.js << 'EOF'
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.tsx',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx']
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html'
    })
  ],
  devServer: {
    port: 3000,
    hot: true
  }
};
EOF

# Create frontend index.html
cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Full-Stack TypeScript App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create backend package.json
cat > backend/package.json << 'EOF'
{
  "name": "backend",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "@types/cors": "^2.8.0",
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0",
    "ts-node-dev": "^2.0.0"
  }
}
EOF

# Create backend tsconfig.json
cat > backend/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
EOF

# Create sample backend code
cat > backend/src/index.ts << 'EOF'
import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 8000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ 
    message: 'Welcome to the API',
    endpoints: {
      health: '/api/health',
      root: '/'
    }
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Backend is running' });
});

app.listen(PORT, () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
});
EOF

cat > backend/src/types.ts << 'EOF'
export interface ApiResponse {
  status: string;
  message: string;
}
EOF

# Create sample frontend code
cat > frontend/src/index.tsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat > frontend/src/App.tsx << 'EOF'
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
EOF

cat > frontend/src/api.ts << 'EOF'
const API_BASE_URL = 'http://localhost:8000';

export async function fetchHealth() {
  const response = await fetch(`${API_BASE_URL}/api/health`);
  return response.json();
}
EOF

# Create root README.md
cat > README.md << 'EOF'
# Full-Stack TypeScript App

A full-stack application with TypeScript frontend (React) and backend (Express).

## Project Structure

```
my-app/
├── frontend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── webpack.config.js
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── index.tsx
│   │   ├── App.tsx
│   │   └── api.ts
│   └── dist/
├── backend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts
│   │   └── types.ts
│   └── dist/
└── README.md
```

## Setup and Run

### Backend

```bash
cd backend
npm install
npm run dev
```

Backend API runs on http://localhost:8000

### Frontend

```bash
cd frontend
npm install
npm start
```

Frontend app runs on http://localhost:3000

## Features

- TypeScript for type safety
- React frontend with Webpack
- Express backend with CORS
- Hot reloading in development
- Sample API integration

## Available Scripts

### Backend
- `npm run dev` - Run development server with auto-reload
- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Run compiled production build

### Frontend
- `npm start` - Run development server
- `npm run build` - Create production build
EOF

echo ""
echo "✅ Project structure created successfully!"
echo ""
echo "📁 Directory structure:"
tree -L 3 2>/dev/null || find . -type d -not -path '*/node_modules/*' | sed 's|[^/]*/|  |g'
echo ""
echo "🚀 Next steps:"
echo "   1. cd $ROOT_DIR/backend && npm install"
echo "   2. cd $ROOT_DIR/frontend && npm install"
echo "   3. Run 'npm run dev' in backend, then 'npm start' in frontend"
echo ""