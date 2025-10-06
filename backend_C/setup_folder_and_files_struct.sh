#!/bin/bash
# chmod +x setup_folder_and_files_struct.sh
# ./setup_folder_and_files_struct.sh

set -e

echo "Creating full-stack TypeScript (Frontend) + C (Backend) application structure..."

# Create root directory
ROOT_DIR="my-app"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# Create directory structure
mkdir -p frontend/src frontend/public frontend/dist
mkdir -p backend/src backend/include backend/build

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
  <title>Full-Stack TypeScript + C App</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
EOF

# Create C backend files - using printf to preserve tabs in Makefile
printf 'CC = gcc
CFLAGS = -Wall -Wextra -g -Iinclude -I/opt/homebrew/include
LDFLAGS = -L/opt/homebrew/lib -lmicrohttpd -ljson-c

SRC_DIR = src
BUILD_DIR = build

SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJECTS = $(SOURCES:$(SRC_DIR)/%%.c=$(BUILD_DIR)/%%.o)
TARGET = $(BUILD_DIR)/server

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJECTS)
\t$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%%.o: $(SRC_DIR)/%%.c | $(BUILD_DIR)
\t$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
\tmkdir -p $(BUILD_DIR)

clean:
\trm -rf $(BUILD_DIR)

run: $(TARGET)
\t./$(TARGET)
' > backend/Makefile

# Create main.c
cat > backend/src/main.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <microhttpd.h>
#include <json-c/json.h>
#include "handlers.h"

#define PORT 8000

// CORS headers - allows frontend to communicate with backend
void add_cors_headers(struct MHD_Response *response) {
    MHD_add_response_header(response, "Access-Control-Allow-Origin", "http://localhost:3000");
    MHD_add_response_header(response, "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    MHD_add_response_header(response, "Access-Control-Allow-Headers", "Content-Type, Authorization");
    MHD_add_response_header(response, "Content-Type", "application/json");
}

// Main request handler - routes requests to appropriate handlers
enum MHD_Result handle_request(void *cls, struct MHD_Connection *connection,
                   const char *url, const char *method,
                   const char *version, const char *upload_data,
                   size_t *upload_data_size, void **con_cls) {
    
    (void)cls;              // Mark unused parameters
    (void)version;
    (void)upload_data;
    (void)upload_data_size;
    (void)con_cls;
    
    struct MHD_Response *response;
    enum MHD_Result ret;
    char *response_str;

    // Handle OPTIONS preflight requests (CORS)
    if (strcmp(method, "OPTIONS") == 0) {
        response = MHD_create_response_from_buffer(0, "", MHD_RESPMEM_PERSISTENT);
        add_cors_headers(response);
        ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
        MHD_destroy_response(response);
        return ret;
    }

    // Route GET requests
    if (strcmp(method, "GET") == 0) {
        if (strcmp(url, "/") == 0) {
            response_str = handle_root();
        } else if (strcmp(url, "/api/health") == 0) {
            response_str = handle_health();
        } else if (strcmp(url, "/api/users") == 0) {
            response_str = handle_get_users();
        } else if (strncmp(url, "/api/users/", 11) == 0) {
            const char *id_str = url + 11;
            response_str = handle_get_user(id_str);
        } else {
            // 404 Not Found
            response_str = strdup("{\"error\":\"Not Found\"}");
            response = MHD_create_response_from_buffer(strlen(response_str),
                                                       response_str, MHD_RESPMEM_MUST_FREE);
            add_cors_headers(response);
            ret = MHD_queue_response(connection, MHD_HTTP_NOT_FOUND, response);
            MHD_destroy_response(response);
            return ret;
        }

        // Send successful response
        response = MHD_create_response_from_buffer(strlen(response_str),
                                                   response_str, MHD_RESPMEM_MUST_FREE);
        add_cors_headers(response);
        ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
        MHD_destroy_response(response);
        return ret;
    }

    // Method not allowed
    response_str = strdup("{\"error\":\"Method Not Allowed\"}");
    response = MHD_create_response_from_buffer(strlen(response_str),
                                               response_str, MHD_RESPMEM_MUST_FREE);
    add_cors_headers(response);
    ret = MHD_queue_response(connection, MHD_HTTP_METHOD_NOT_ALLOWED, response);
    MHD_destroy_response(response);
    return ret;
}

int main() {
    struct MHD_Daemon *daemon;

    printf("Backend server running on http://localhost:%d\n", PORT);

    // Start HTTP server
    daemon = MHD_start_daemon(MHD_USE_SELECT_INTERNALLY, PORT, NULL, NULL,
                             &handle_request, NULL, MHD_OPTION_END);
    
    if (daemon == NULL) {
        fprintf(stderr, "Failed to start server\n");
        return 1;
    }

    printf("Press Enter to stop the server...\n");
    getchar();

    MHD_stop_daemon(daemon);
    return 0;
}
EOF

# Create handlers.h
cat > backend/include/handlers.h << 'EOF'
#ifndef HANDLERS_H
#define HANDLERS_H

// Handler function declarations
char* handle_root(void);
char* handle_health(void);
char* handle_get_users(void);
char* handle_get_user(const char *id);

#endif
EOF

# Create handlers.c
cat > backend/src/handlers.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <json-c/json.h>
#include "handlers.h"

// GET / - Root endpoint
char* handle_root(void) {
    json_object *root = json_object_new_object();
    json_object *endpoints = json_object_new_object();
    
    json_object_object_add(root, "message", json_object_new_string("Welcome to the C API"));
    json_object_object_add(endpoints, "root", json_object_new_string("/"));
    json_object_object_add(endpoints, "health", json_object_new_string("/api/health"));
    json_object_object_add(endpoints, "users", json_object_new_string("/api/users"));
    json_object_object_add(root, "endpoints", endpoints);
    
    const char *json_str = json_object_to_json_string(root);
    char *response = strdup(json_str);
    json_object_put(root);
    
    return response;
}

// GET /api/health - Health check endpoint
char* handle_health(void) {
    json_object *root = json_object_new_object();
    
    json_object_object_add(root, "status", json_object_new_string("ok"));
    json_object_object_add(root, "message", json_object_new_string("Backend is running"));
    
    const char *json_str = json_object_to_json_string(root);
    char *response = strdup(json_str);
    json_object_put(root);
    
    return response;
}

// GET /api/users - Get all users
char* handle_get_users(void) {
    json_object *users_array = json_object_new_array();
    
    // User 1
    json_object *user1 = json_object_new_object();
    json_object_object_add(user1, "id", json_object_new_int(1));
    json_object_object_add(user1, "name", json_object_new_string("Alice"));
    json_object_object_add(user1, "email", json_object_new_string("alice@example.com"));
    json_object_array_add(users_array, user1);
    
    // User 2
    json_object *user2 = json_object_new_object();
    json_object_object_add(user2, "id", json_object_new_int(2));
    json_object_object_add(user2, "name", json_object_new_string("Bob"));
    json_object_object_add(user2, "email", json_object_new_string("bob@example.com"));
    json_object_array_add(users_array, user2);
    
    // User 3
    json_object *user3 = json_object_new_object();
    json_object_object_add(user3, "id", json_object_new_int(3));
    json_object_object_add(user3, "name", json_object_new_string("Charlie"));
    json_object_object_add(user3, "email", json_object_new_string("charlie@example.com"));
    json_object_array_add(users_array, user3);
    
    const char *json_str = json_object_to_json_string(users_array);
    char *response = strdup(json_str);
    json_object_put(users_array);
    
    return response;
}

// GET /api/users/{id} - Get single user by ID
char* handle_get_user(const char *id) {
    json_object *user = json_object_new_object();
    
    int user_id = atoi(id);
    json_object_object_add(user, "id", json_object_new_int(user_id));
    
    char name[50];
    char email[50];
    snprintf(name, sizeof(name), "User %d", user_id);
    snprintf(email, sizeof(email), "user%d@example.com", user_id);
    
    json_object_object_add(user, "name", json_object_new_string(name));
    json_object_object_add(user, "email", json_object_new_string(email));
    
    const char *json_str = json_object_to_json_string(user);
    char *response = strdup(json_str);
    json_object_put(user);
    
    return response;
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
EOF

cat > frontend/src/api.ts << 'EOF'
// API base URL - points to C backend
const API_BASE_URL = 'http://localhost:8000';

// Fetch health status from C backend
export async function fetchHealth() {
  const response = await fetch(`${API_BASE_URL}/api/health`);
  if (!response.ok) {
    throw new Error('Failed to fetch health status');
  }
  return response.json();
}

// Fetch all users from C backend
export async function fetchUsers() {
  const response = await fetch(`${API_BASE_URL}/api/users`);
  if (!response.ok) {
    throw new Error('Failed to fetch users');
  }
  return response.json();
}

// Fetch single user by ID from C backend
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
EOF

echo ""
echo "Project structure created successfully!"
echo ""
echo "Next steps:"
echo "  1. Install C dependencies (see README.md)"
echo "  2. cd $ROOT_DIR/backend && make"
echo "  3. cd $ROOT_DIR/frontend && npm install"
echo "  4. Terminal 1: cd backend && make run"
echo "  5. Terminal 2: cd frontend && npm start"
echo "  6. Open http://localhost:3000"
echo ""

echo ""
echo "🚀 Next steps:"
echo "   1. Install C dependencies (see README.md Dependencies section)"
echo "   2. cd $ROOT_DIR/backend && make"
echo "   3. cd $ROOT_DIR/frontend && npm install"
echo "   4. Terminal 1: cd backend && make run"
echo "   5. Terminal 2: cd frontend && npm start"
echo "   6. Open http://localhost:3000 in your browser"
echo ""
echo "📦 Install C dependencies:"
echo "   Ubuntu/Debian: sudo apt-get install libmicrohttpd-dev libjson-c-dev build-essential"
echo "   macOS:         brew install libmicrohttpd json-c"
echo "   Fedora/RHEL:   sudo dnf install libmicrohttpd-devel json-c-devel gcc make"
echo ""
echo "📖 Read README.md for detailed explanation of frontend-backend communication"
echo ""