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
