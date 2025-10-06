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
