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
