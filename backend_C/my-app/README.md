# Full-Stack TypeScript + C App

A full-stack application with TypeScript frontend (React) and C backend (libmicrohttpd).

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
│   │   └── api.ts              # API calls to C backend
│   └── dist/
├── backend/
│   ├── Makefile                # Build configuration
│   ├── include/
│   │   └── handlers.h          # Function declarations
│   ├── src/
│   │   ├── main.c              # C server with routing and CORS
│   │   └── handlers.c          # Request handlers
│   └── build/
└── README.md
```

## Dependencies

### Backend (C)
- **libmicrohttpd** - HTTP server library
- **json-c** - JSON manipulation library
- **gcc** - C compiler

Install on Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install libmicrohttpd-dev libjson-c-dev build-essential
```

Install on macOS:
```bash
brew install libmicrohttpd json-c
```

Install on Fedora/RHEL:
```bash
sudo dnf install libmicrohttpd-devel json-c-devel gcc make
```

## Setup and Run

### Backend (C)

```bash
cd backend

# Build the server
make

# Run the server
make run

# Or run directly
./build/server

# Clean build files
make clean
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

## How Frontend Interfaces with C Backend

### Frontend → Backend
1. **frontend/src/api.ts line 2**: Sets `API_BASE_URL = 'http://localhost:8000'`
2. **frontend/src/api.ts line 6**: `fetch()` sends HTTP GET to C server
3. **frontend/src/App.tsx line 19**: Calls `fetchHealth()` which hits C backend

### Backend → Frontend
4. **backend/src/main.c line 12**: CORS header allows frontend origin
5. **backend/src/main.c line 39**: Routes `/api/health` to handler
6. **backend/src/handlers.c line 28-31**: Builds JSON response object
7. **backend/src/handlers.c line 33**: Converts JSON to string
8. **backend/src/main.c line 58**: Adds CORS headers to response
9. **backend/src/main.c line 59**: Sends JSON string to frontend

## API Endpoints

- `GET /` - Welcome message
- `GET /api/health` - Health check
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID

## CORS Explanation

CORS (Cross-Origin Resource Sharing) enables frontend-backend communication:
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8000`
- Different ports = different origins
- `backend/src/main.c` line 12 allows requests from frontend origin

## Testing

1. Install C dependencies (see above)
2. Start backend: `cd backend && make run`
3. Start frontend: `cd frontend && npm start`
4. Open browser to `http://localhost:3000`
5. Check browser DevTools Network tab to see requests
