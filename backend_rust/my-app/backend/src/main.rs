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
