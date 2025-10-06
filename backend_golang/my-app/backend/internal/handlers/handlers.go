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
