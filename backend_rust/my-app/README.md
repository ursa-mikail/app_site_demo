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
