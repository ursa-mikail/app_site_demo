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
