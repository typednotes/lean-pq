#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>
#include <lean/lean.h>




struct connection {
    PGconn *conn;
};

typedef struct connection Connection;

// struct connection *create_connection(const char *host, const char *port, const char *user, const char *password, const char *database) {
//     PGconn *conn = PQconnectdb(host, port, user, password, database);
//     return conn;
// }