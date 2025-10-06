#!/bin/bash
# chmod +x setup_folder_and_files_struct.sh
# ./setup_folder_and_files_struct.sh

set -e

echo "Creating full-stack TypeScript (Frontend) + Go (Backend) application structure..."

# Create root directory
ROOT_DIR="my-app"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# Create directory structure
mkdir -p frontend/src frontend/public frontend/dist
mkdir -p backend/cmd/server backend/internal/handlers backend/internal/models

# Create placeholder files
touch frontend/src/{index.tsx,App.tsx,api.ts}

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
  <title>Full-Stack TypeScript + Go App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create Go backend files

# Create go.mod
cat > backend/go.mod << 'EOF'
module github.com/yourusername/my-app

go 1.21

require (
  github.com/gorilla/mux v1.8.1
  github.com/rs/cors v1.10.1
)
EOF

# Create main.go
cat > backend/cmd/server/main.go << 'EOF'
package main

import (
  "log"
  "net/http"
  "github.com/yourusername/my-app/internal/handlers"
  "github.com/gorilla/mux"
  "github.com/rs/cors"
)

func main() {
  router := mux.NewRouter()

  // Root endpoint
  router.HandleFunc("/", handlers.RootHandler).Methods("GET")
  
  // API endpoints
  router.HandleFunc("/api/health", handlers.HealthHandler).Methods("GET")
  router.HandleFunc("/api/users", handlers.GetUsersHandler).Methods("GET")
  router.HandleFunc("/api/users/{id}", handlers.GetUserHandler).Methods("GET")

  // CORS middleware - allows frontend to communicate with backend
  c := cors.New(cors.Options{
    AllowedOrigins:   []string{"http://localhost:3000"}, // Frontend URL
    AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
    AllowedHeaders:   []string{"Content-Type", "Authorization"},
    AllowCredentials: true,
  })

  handler := c.Handler(router)

  log.Println("Backend server running on http://localhost:8000")
  log.Fatal(http.ListenAndServe(":8000", handler))
}
EOF

# Create handlers
cat > backend/internal/handlers/handlers.go << 'EOF'
package handlers

import (
  "encoding/json"
  "net/http"
  "github.com/gorilla/mux"
  "github.com/yourusername/my-app/internal/models"
)

// RootHandler - handles GET /
func RootHandler(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json")
  response := map[string]interface{}{
    "message": "Welcome to the Go API",
    "endpoints": map[string]string{
      "root":   "/",
      "health": "/api/health",
      "users":  "/api/users",
    },
  }
  json.NewEncoder(w).Encode(response)
}

// HealthHandler - handles GET /api/health
func HealthHandler(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json")
  response := models.HealthResponse{
    Status:  "ok",
    Message: "Backend is running",
  }
  json.NewEncoder(w).Encode(response)
}

// GetUsersHandler - handles GET /api/users
func GetUsersHandler(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json")
  
  users := []models.User{
    {ID: 1, Name: "Alice", Email: "alice@example.com"},
    {ID: 2, Name: "Bob", Email: "bob@example.com"},
    {ID: 3, Name: "Charlie", Email: "charlie@example.com"},
  }
  
  json.NewEncoder(w).Encode(users)
}

// GetUserHandler - handles GET /api/users/{id}
func GetUserHandler(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json")
  
  vars := mux.Vars(r)
  id := vars["id"]
  
  // Mock user data
  user := models.User{
    ID:    1,
    Name:  "User " + id,
    Email: "user" + id + "@example.com",
  }
  
  json.NewEncoder(w).Encode(user)
}
EOF

# Create models
cat > backend/internal/models/models.go << 'EOF'
package models

type HealthResponse struct {
  Status  string `json:"status"`
  Message string `json:"message"`
}

type User struct {
  ID    int    `json:"id"`
  Name  string `json:"name"`
  Email string `json:"email"`
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
    // Fetch health status from Go backend
    fetchHealth()
      .then(data => setStatus(data.message))
      .catch(err => setStatus('Error connecting to backend'));

    // Fetch users from Go backend
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
      <h1>Full-Stack TypeScript + Go App</h1>
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
EOF

cat > frontend/src/api.ts << 'EOF'
// API base URL - points to Go backend
const API_BASE_URL = 'http://localhost:8000';

// Fetch health status from Go backend
export async function fetchHealth() {
  const response = await fetch(`${API_BASE_URL}/api/health`);
  if (!response.ok) {
    throw new Error('Failed to fetch health status');
  }
  return response.json();
}

// Fetch all users from Go backend
export async function fetchUsers() {
  const response = await fetch(`${API_BASE_URL}/api/users`);
  if (!response.ok) {
    throw new Error('Failed to fetch users');
  }
  return response.json();
}

// Fetch single user by ID from Go backend
export async function fetchUser(id: number) {
  const response = await fetch(`${API_BASE_URL}/api/users/${id}`);
  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }
  return response.json();
}
EOF

# Create root README.md
cat > README.md << 'EOF'
# Full-Stack TypeScript + Go App

A full-stack application with TypeScript frontend (React) and Go backend.

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
│   │   ├── index.tsx          # React entry point
│   │   ├── App.tsx             # Main React component
│   │   └── api.ts              # API calls to Go backend
│   └── dist/
├── backend/
│   ├── go.mod
│   ├── cmd/
│   │   └── server/
│   │       └── main.go         # Go server entry point
│   └── internal/
│       ├── handlers/
│       │   └── handlers.go     # HTTP request handlers
│       └── models/
│           └── models.go       # Data models
└── README.md
```

## How Frontend Interfaces with Go Backend

### 1. **Frontend Side (TypeScript/React)**

**File: `frontend/src/api.ts`**
- **Line 2**: `const API_BASE_URL = 'http://localhost:8000'` - Points to Go backend
- **Lines 5-11**: `fetchHealth()` - Makes HTTP GET request to `/api/health`
- **Lines 14-20**: `fetchUsers()` - Makes HTTP GET request to `/api/users`
- **Lines 23-29**: `fetchUser(id)` - Makes HTTP GET request to `/api/users/{id}`

**File: `frontend/src/App.tsx`**
- **Lines 1-2**: Imports the API functions
- **Lines 18-21**: Calls `fetchHealth()` to get backend status
- **Lines 23-30**: Calls `fetchUsers()` to get user list from Go backend

### 2. **Backend Side (Go)**

**File: `backend/cmd/server/main.go`**
- **Line 18**: Defines routes that frontend can call
- **Lines 24-29**: **CORS configuration** - Critical for frontend-backend communication
  - `AllowedOrigins: []string{"http://localhost:3000"}` - Allows requests from frontend
  - Without CORS, browser blocks requests from frontend to backend

**File: `backend/internal/handlers/handlers.go`**
- **Lines 14-24**: `RootHandler` - Handles GET / requests
- **Lines 27-35**: `HealthHandler` - Returns JSON that frontend receives
- **Lines 38-50**: `GetUsersHandler` - Returns array of users as JSON
- **Lines 53-67**: `GetUserHandler` - Returns single user as JSON

### 3. **Communication Flow**

```
Frontend (Port 3000)              Backend (Port 8000)
─────────────────────            ──────────────────────
api.ts: fetchHealth()
  └─> HTTP GET                 ──>  main.go: router
      /api/health                     └─> handlers.go: HealthHandler
                                            └─> Returns JSON
  <── JSON Response            <──  {status: "ok", message: "..."}

App.tsx: displays result
```

## Setup and Run

### Backend (Go)

```bash
cd backend

# Install dependencies
go mod download

# Run the server
go run cmd/server/main.go
```

Backend API runs on **http://localhost:8000**

### Frontend (TypeScript/React)

```bash
cd frontend

# Install dependencies
npm install

# Run development server
npm start
```

Frontend app runs on **http://localhost:3000**

## API Endpoints

The Go backend exposes these endpoints that the frontend calls:

- `GET /` - Welcome message with available endpoints
- `GET /api/health` - Health check
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID

## Key Technologies

### Frontend
- **TypeScript** - Type-safe JavaScript
- **React** - UI library
- **Webpack** - Module bundler
- **Fetch API** - HTTP requests to Go backend

### Backend
- **Go** - Backend language
- **Gorilla Mux** - HTTP router
- **rs/cors** - CORS middleware (enables frontend-backend communication)

## CORS Explanation

CORS (Cross-Origin Resource Sharing) is **essential** for frontend-backend communication:

- Frontend runs on `http://localhost:3000`
- Backend runs on `http://localhost:8000`
- Different ports = different origins
- Without CORS, browser blocks the requests for security
- `backend/cmd/server/main.go` lines 24-29 configure CORS to allow frontend requests

## Testing the Connection

1. Start backend: `cd backend && go run cmd/server/main.go`
2. Start frontend: `cd frontend && npm start`
3. Open browser to `http://localhost:3000`
4. You should see:
   - Backend status message
   - List of users fetched from Go backend
5. Check browser DevTools Network tab to see HTTP requests to Go backend
EOF

echo ""
echo "✅ Project structure created successfully!"
echo ""
echo "📁 Directory structure:"
tree -L 3 2>/dev/null || find . -type d -not -path '*/node_modules/*' | sed 's|[^/]*/|  |g'
echo ""
echo "🚀 Next steps:"
echo "   1. cd $ROOT_DIR/backend && go mod download"
echo "   2. cd $ROOT_DIR/frontend && npm install"
echo "   3. Terminal 1: cd backend && go mod tidy && go run cmd/server/main.go"
echo "   4. Terminal 2: cd frontend && npm start"
echo "   5. Open http://localhost:3000 in your browser"
echo ""
echo "📖 Read README.md for detailed explanation of frontend-backend communication"
echo ""