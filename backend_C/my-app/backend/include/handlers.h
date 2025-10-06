#ifndef HANDLERS_H
#define HANDLERS_H

// Handler function declarations
char* handle_root(void);
char* handle_health(void);
char* handle_get_users(void);
char* handle_get_user(const char *id);

#endif
