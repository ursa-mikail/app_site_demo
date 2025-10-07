#!/bin/bash
# chmod +x setup_python_fullstack.sh
# ./setup_python_fullstack.sh

set -e

echo "Creating full-stack TypeScript frontend + Python backend application..."

# Create root directory
ROOT_DIR="my-app"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# Create directory structure
mkdir -p frontend/src frontend/public frontend/dist
mkdir -p backend/app

# Create placeholder files
touch frontend/src/{index.tsx,App.tsx,api.ts}
touch backend/app/{__init__.py,main.py,models.py}

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
  <title>Full-Stack Python App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create backend requirements.txt
cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
python-dotenv==1.0.0
EOF

# Create backend .env
cat > backend/.env << 'EOF'
PORT=8000
HOST=0.0.0.0
DEBUG=True
EOF

# Create backend main.py
cat > backend/app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.models import HealthResponse, WelcomeResponse

app = FastAPI(title="Python Backend API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", response_model=WelcomeResponse)
async def root():
    return {
        "message": "Welcome to the Python API",
        "endpoints": {
            "health": "/api/health",
            "root": "/",
            "docs": "/docs"
        }
    }

@app.get("/api/health", response_model=HealthResponse)
async def health_check():
    return {
        "status": "ok",
        "message": "Python backend is running"
    }
EOF

# Create backend models.py
cat > backend/app/models.py << 'EOF'
from pydantic import BaseModel
from typing import Dict

class HealthResponse(BaseModel):
    status: str
    message: str

class WelcomeResponse(BaseModel):
    message: str
    endpoints: Dict[str, str]
EOF

# Create backend __init__.py
cat > backend/app/__init__.py << 'EOF'
"""
Python Backend Application
"""
EOF

# Create backend run script
cat > backend/run.py << 'EOF'
import uvicorn
from dotenv import load_dotenv
import os

load_dotenv()

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", 8000)),
        reload=os.getenv("DEBUG", "True") == "True"
    )
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
      <h1>Full-Stack Python Backend App</h1>
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

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv
*.egg-info/
dist/
build/

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Build outputs
frontend/dist/
backend/dist/
EOF

# Create root README.md
cat > README.md << 'EOF'
# Full-Stack Python Backend App

A full-stack application with TypeScript frontend (React) and Python backend (FastAPI).

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
│   ├── requirements.txt
│   ├── .env
│   ├── run.py
│   └── app/
│       ├── __init__.py
│       ├── main.py
│       └── models.py
├── .gitignore
└── README.md
```

## Setup and Run

### Backend (Python)

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python run.py
```

Backend API runs on http://localhost:8000
API documentation available at http://localhost:8000/docs

### Frontend

```bash
cd frontend
npm install
npm start
```

Frontend app runs on http://localhost:3000

## Features

- **Backend (Python)**
  - FastAPI framework for high performance
  - Pydantic models for data validation
  - Automatic API documentation (Swagger/OpenAPI)
  - CORS enabled for frontend communication
  - Hot reloading in development

- **Frontend (TypeScript/React)**
  - React with TypeScript for type safety
  - Webpack for bundling
  - Hot reloading in development
  - Sample API integration

## Available Scripts

### Backend
- `python run.py` - Run development server with auto-reload
- `pip install -r requirements.txt` - Install dependencies

### Frontend
- `npm start` - Run development server
- `npm run build` - Create production build

## API Endpoints

- `GET /` - Welcome message with available endpoints
- `GET /api/health` - Health check endpoint
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative API documentation (ReDoc)

## Environment Variables

Backend environment variables are configured in `backend/.env`:
- `PORT` - Server port (default: 8000)
- `HOST` - Server host (default: 0.0.0.0)
- `DEBUG` - Enable debug mode (default: True)
EOF

cd ..

echo ""
echo "✅ Project structure created successfully!"
echo ""
echo "📁 Directory structure:"
tree -L 3 "$ROOT_DIR" 2>/dev/null || find "$ROOT_DIR" -type d -not -path '*/node_modules/*' -not -path '*/venv/*' | sed 's|[^/]*/|  |g'
echo ""
echo "🚀 Next steps:"
echo ""
echo "Backend Setup:"
echo "   cd $ROOT_DIR/backend"
echo "   python -m venv venv"
echo "   source venv/bin/activate          # On Linux/Mac"
echo "   # OR"
echo "   venv\\Scripts\\activate            # On Windows"
echo "   pip install -r requirements.txt"
echo "   python run.py"
echo ""
echo "Frontend Setup (in a new terminal):"
echo "   cd $ROOT_DIR/frontend"
echo "   npm install"
echo "   npm start"
echo ""
echo "📚 API Documentation will be available at http://localhost:8000/docs"
echo ""