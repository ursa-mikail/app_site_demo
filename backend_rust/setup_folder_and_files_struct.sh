#!/bin/bash
# chmod +x setup_folder_and_files_struct.sh
# ./setup_folder_and_files_struct.sh

set -e

echo "Creating full-stack TypeScript (Frontend) + Rust (Backend) application structure..."

# Create root directory
ROOT_DIR="my-app"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# Create directory structure
mkdir -p frontend/src frontend/public frontend/dist
mkdir -p backend/src

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
  <title>Full-Stack TypeScript + Rust App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create Rust backend files

# Create Cargo.toml
cat > backend/Cargo.toml << 'EOF'
[package]
name = "backend"
version = "0.1.0"
edition = "2021"

[dependencies]
actix-web = "4.4"
actix-cors = "0.7"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.35", features = ["full"] }
EOF

# Create main.rs
cat > backend/src/main.rs << 'EOF'
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use actix_cors::Cors;
use serde::{Deserialize, Serialize};

// Data models
#[derive(Serialize, Deserialize, Clone)]
struct User {
    id: u32,
    name: String,
    email: String,
}

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    message: String,
}

#[derive(Serialize)]
struct RootResponse {
    message: String,
    endpoints: EndpointsList,
}

#[derive(Serialize)]
struct EndpointsList {
    root: String,
    health: String,
    users: String,
}

// Handler functions

// GET / - Root endpoint
async fn root_handler() -> impl Responder {
    let response = RootResponse {
        message: "Welcome to the Rust API".to_string(),
        endpoints: EndpointsList {
            root: "/".to_string(),
            health: "/api/health".to_string(),
            users: "/api/users".to_string(),
        },
    };
    HttpResponse::Ok().json(response)
}

// GET /api/health - Health check endpoint
async fn health_handler() -> impl Responder {
    let response = HealthResponse {
        status: "ok".to_string(),
        message: "Backend is running".to_string(),
    };
    HttpResponse::Ok().json(response)
}

// GET /api/users - Get all users
async fn get_users_handler() -> impl Responder {
    let users = vec![
        User {
            id: 1,
            name: "Alice".to_string(),
            email: "alice@example.com".to_string(),
        },
        User {
            id: 2,
            name: "Bob".to_string(),
            email: "bob@example.com".to_string(),
        },
        User {
            id: 3,
            name: "Charlie".to_string(),
            email: "charlie@example.com".to_string(),
        },
    ];
    HttpResponse::Ok().json(users)
}

// GET /api/users/{id} - Get single user by ID
async fn get_user_handler(path: web::Path<u32>) -> impl Responder {
    let id = path.into_inner();
    let user = User {
        id,
        name: format!("User {}", id),
        email: format!("user{}@example.com", id),
    };
    HttpResponse::Ok().json(user)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Backend server running on http://localhost:8000");

    HttpServer::new(|| {
        // CORS configuration - allows frontend to communicate with backend
        let cors = Cors::default()
            .allowed_origin("http://localhost:3000") // Frontend URL
            .allowed_methods(vec!["GET", "POST", "PUT", "DELETE"])
            .allowed_headers(vec![
                actix_web::http::header::CONTENT_TYPE,
                actix_web::http::header::AUTHORIZATION,
            ])
            .max_age(3600);

        App::new()
            .wrap(cors)
            // Define routes
            .route("/", web::get().to(root_handler))
            .route("/api/health", web::get().to(health_handler))
            .route("/api/users", web::get().to(get_users_handler))
            .route("/api/users/{id}", web::get().to(get_user_handler))
    })
    .bind(("127.0.0.1", 8000))?
    .run()
    .await
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
    // Fetch health status from Rust backend
    fetchHealth()
      .then(data => setStatus(data.message))
      .catch(err => setStatus('Error connecting to backend'));

    // Fetch users from Rust backend
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
      <h1>Full-Stack TypeScript + Rust App</h1>
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
// API base URL - points to Rust backend
const API_BASE_URL = 'http://localhost:8000';

// Fetch health status from Rust backend
export async function fetchHealth() {
  const response = await fetch(`${API_BASE_URL}/api/health`);
  if (!response.ok) {
    throw new Error('Failed to fetch health status');
  }
  return response.json();
}

// Fetch all users from Rust backend
export async function fetchUsers() {
  const response = await fetch(`${API_BASE_URL}/api/users`);
  if (!response.ok) {
    throw new Error('Failed to fetch users');
  }
  return response.json();
}

// Fetch single user by ID from Rust backend
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
# Full-Stack TypeScript + Rust App

A full-stack application with TypeScript frontend (React) and Rust backend (Actix-web).

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
│   │   └── api.ts              # API calls to Rust backend
│   └── dist/
├── backend/
│   ├── Cargo.toml              # Rust dependencies
│   └── src/
│       └── main.rs             # Rust server with all handlers
└── README.md
```

## How Frontend Interfaces with Rust Backend

### 1. **Frontend Side (TypeScript/React)**

**File: `frontend/src/api.ts`**
- **Line 2**: `const API_BASE_URL = 'http://localhost:8000'` - Points to Rust backend
- **Lines 5-11**: `fetchHealth()` - Makes HTTP GET request to `/api/health`
- **Lines 14-20**: `fetchUsers()` - Makes HTTP GET request to `/api/users`
- **Lines 23-29**: `fetchUser(id)` - Makes HTTP GET request to `/api/users/{id}`

**File: `frontend/src/App.tsx`**
- **Lines 1-2**: Imports the API functions
- **Lines 18-21**: Calls `fetchHealth()` to get backend status from Rust
- **Lines 23-30**: Calls `fetchUsers()` to get user list from Rust backend

### 2. **Backend Side (Rust)**

**File: `backend/src/main.rs`**

**Data Models (Lines 5-32):**
- **Lines 6-11**: `User` struct - Defines user data structure
- **Lines 13-17**: `HealthResponse` struct - Health check response
- Uses `Serialize` to convert Rust structs to JSON for frontend

**Handler Functions (Lines 36-94):**
- **Lines 36-46**: `root_handler()` - Handles GET / requests
- **Lines 49-57**: `health_handler()` - Returns JSON to frontend's `fetchHealth()` call
- **Lines 60-79**: `get_users_handler()` - Returns array of users as JSON
- **Lines 82-90**: `get_user_handler()` - Returns single user as JSON

**Server Setup (Lines 96-120):**
- **Lines 102-109**: **CORS configuration** - Critical for frontend-backend communication
  - **Line 103**: `allowed_origin("http://localhost:3000")` - Allows requests from frontend
  - Without CORS, browser blocks requests from frontend to backend
- **Lines 114-117**: Route definitions - Maps URLs to handler functions

### 3. **Communication Flow**

```
Frontend (Port 3000)              Backend (Port 8000)
─────────────────────            ──────────────────────
api.ts: fetchHealth()
  └─> HTTP GET                 ──>  main.rs: HttpServer
      /api/health                     └─> Route: /api/health
                                            └─> health_handler()
                                                  └─> Returns JSON
  <── JSON Response            <──  {status: "ok", message: "..."}

App.tsx: displays result
```

### 4. **Key Rust Concepts**

**Async Functions:**
- All handlers use `async fn` for non-blocking I/O
- `#[actix_web::main]` macro sets up async runtime

**Serialization:**
- `#[derive(Serialize)]` automatically converts Rust structs to JSON
- `HttpResponse::Ok().json(data)` sends JSON to frontend

**Routing:**
- `web::get().to(handler)` connects URLs to handler functions
- `web::Path<u32>` extracts URL parameters (e.g., `/api/users/1`)

## Setup and Run

### Backend (Rust)

```bash
cd backend

# Build and run (development mode with auto-reload)
cargo watch -x run

# Or build and run normally
cargo run

# Build optimized release version
cargo build --release
./target/release/backend
```

Backend API runs on **http://localhost:8000**

**Note:** First build may take a few minutes as Cargo downloads dependencies.

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

The Rust backend exposes these endpoints that the frontend calls:

- `GET /` - Welcome message with available endpoints
- `GET /api/health` - Health check
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID

## Key Technologies

### Frontend
- **TypeScript** - Type-safe JavaScript
- **React** - UI library
- **Webpack** - Module bundler
- **Fetch API** - HTTP requests to Rust backend

### Backend
- **Rust** - Systems programming language (fast, safe, concurrent)
- **Actix-web** - Fast, powerful web framework
- **Actix-cors** - CORS middleware (enables frontend-backend communication)
- **Serde** - Serialization/deserialization (Rust ↔ JSON)
- **Tokio** - Async runtime for Rust

## CORS Explanation

CORS (Cross-Origin Resource Sharing) is **essential** for frontend-backend communication:

- Frontend runs on `http://localhost:3000`
- Backend runs on `http://localhost:8000`
- Different ports = different origins
- Without CORS, browser blocks the requests for security
- `backend/src/main.rs` lines 102-109 configure CORS to allow frontend requests

## Line-by-Line Interface Points

### Frontend → Backend
1. **api.ts Line 2**: Sets backend URL
2. **api.ts Line 6**: `fetch()` sends HTTP GET to Rust
3. **App.tsx Line 19**: Calls API function

### Backend → Frontend
4. **main.rs Line 103**: CORS allows frontend origin
5. **main.rs Line 115**: Route `/api/health` mapped to handler
6. **main.rs Line 54**: Handler creates response struct
7. **main.rs Line 56**: `HttpResponse::Ok().json()` sends JSON to frontend

## Testing the Connection

1. Start backend: `cd backend && cargo run`
2. Start frontend: `cd frontend && npm start`
3. Open browser to `http://localhost:3000`
4. You should see:
   - Backend status message from Rust
   - List of users fetched from Rust backend
5. Check browser DevTools Network tab to see HTTP requests to Rust backend

## Performance Note

Rust backend is **extremely fast** - typically handles 100k+ requests/second. The Actix-web framework is one of the fastest web frameworks in any language.
EOF

echo ""
echo "✅ Project structure created successfully!"
echo ""
echo "📁 Directory structure:"
tree -L 3 2>/dev/null || find . -type d -not -path '*/node_modules/*' -not -path '*/target/*' | sed 's|[^/]*/|  |g'
echo ""
echo "🚀 Next steps:"
echo "   1. cd $ROOT_DIR/backend && cargo build"
echo "   2. cd $ROOT_DIR/frontend && npm install"
echo "   3. Terminal 1: cd backend && cargo run"
echo "   4. Terminal 2: cd frontend && npm start"
echo "   5. Open http://localhost:3000 in your browser"
echo ""
echo "⚙️  Optional: Install cargo-watch for auto-reload"
echo "   cargo install cargo-watch"
echo "   Then use: cargo watch -x run"
echo ""
echo "📖 Read README.md for detailed explanation of frontend-backend communication"
echo ""