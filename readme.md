# Simple frontend-backend app
Given the dir struct and files, i.e. {frontend, backend} with files, we present 4 versions:

1. All typescript
2. backend golang
3. backend rust
4. backend C

The package also demo how to to run it. 

## How Frontend Interfaces with Go Backend - Key Lines

```
Frontend → Backend Communication:

frontend/src/api.ts (Lines 2, 5-29)

Line 2: API_BASE_URL = 'http://localhost:8000' ← Points to Go backend
Line 6: fetch(${API_BASE_URL}/api/health) ← Makes HTTP request to Go
Line 15: fetch(${API_BASE_URL}/api/users) ← Fetches users from Go


frontend/src/App.tsx (Lines 18-30)

Line 19: fetchHealth() ← Calls Go's /api/health endpoint
Line 24: fetchUsers() ← Calls Go's /api/users endpoint
```

```
Backend → Frontend Response:

backend/cmd/server/main.go (Lines 16-31)

Lines 16-20: Defines routes frontend can access
Lines 24-29: CORS middleware ← CRITICAL! Allows frontend (port 3000) to talk to backend (port 8000)


backend/internal/handlers/handlers.go (Lines 27-35, 38-50)

Line 32: Returns JSON to frontend's fetchHealth() call
Line 48: Returns JSON array to frontend's fetchUsers() call
```

The CORS configuration (main.go lines 24-29) is what makes the connection work - without it, the browser blocks all requests!

-----

## How Frontend Interfaces with Rust Backend - Key Lines
```
Frontend → Backend Communication:

frontend/src/api.ts (Lines 2, 5-29)

Line 2: API_BASE_URL = 'http://localhost:8000' ← Points to Rust backend
Line 6: fetch(${API_BASE_URL}/api/health) ← Makes HTTP request to Rust
Line 15: fetch(${API_BASE_URL}/api/users) ← Fetches users from Rust


frontend/src/App.tsx (Lines 18-30)

Line 19: fetchHealth() ← Calls Rust's /api/health endpoint
Line 24: fetchUsers() ← Calls Rust's /api/users endpoint
```

## Backend → Frontend Response:

```
backend/src/main.rs (Lines 102-117)

Lines 102-109: CORS middleware ← CRITICAL! Allows frontend (port 3000) to talk to backend (port 8000)
Line 103: allowed_origin("http://localhost:3000") - Specifically allows your frontend
Lines 114-117: Route definitions - maps URLs to handler functions


backend/src/main.rs (Handler Functions)

Lines 49-57: health_handler() - Returns JSON to frontend's fetchHealth() call
Lines 60-79: get_users_handler() - Returns JSON array to frontend's fetchUsers() call
Line 56 & 78: HttpResponse::Ok().json() - Converts Rust structs to JSON for frontend

```

The Actix-web + CORS setup (main.rs lines 102-109) is what enables the connection. Rust's Serialize trait automatically converts structs to JSON that the frontend can consume!

-----

## How Frontend Interfaces with C Backend - Key Lines
```
Frontend → Backend Communication:
✅ frontend/src/api.ts

Line 2: API_BASE_URL = 'http://localhost:8000' ← Correct
Line 6: fetch(\${API_BASE_URL}/api/health`)` ← Correct
Line 15: fetch(\${API_BASE_URL}/api/users`)` ← Correct

✅ frontend/src/App.tsx

Line 18: fetchHealth() ← Correct (line 19 in your version is close)
Line 24: fetchUsers() ← Correct
```

```
Backend → Frontend Response:
⚠️ backend/src/main.c (Lines changed due to fix)

Lines 11-16: add_cors_headers() function ← Correct
Line 12: Access-Control-Allow-Origin: http://localhost:3000 ← Correct
Lines 19-20: enum MHD_Result handle_request(...) - Function signature
Lines 23-27: Marks unused parameters with (void)
Lines 41-49: URL routing - maps routes to handlers

Line 43: / → handle_root()
Line 45: /api/health → handle_health()
Line 47: /api/users → handle_get_users()
Line 49-51: /api/users/{id} → handle_get_user(id)


Line 64: add_cors_headers(response) ← Adds CORS to every response
Line 65: MHD_queue_response() ← Sends JSON to frontend

✅ backend/src/handlers.c

Lines 8-22: handle_root() - Root endpoint
Lines 25-36: handle_health() - Health check

Lines 28-29: Creates JSON object
Line 31: Converts to string
Line 32: Returns JSON string


Lines 39-68: handle_get_users() - Returns user array
Lines 71-89: handle_get_user(id) - Returns single user
```

The CORS headers (main.c lines 11-16) are what enable the connection. The C server uses libmicrohttpd for HTTP and json-c to create JSON responses that JavaScript can parse!


-----
