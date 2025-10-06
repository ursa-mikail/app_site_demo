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
