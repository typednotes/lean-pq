#include <lean/lean.h>
#include <libpq-fe.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/*
LibPQ documentation:
https://www.postgresql.org/docs/current/libpq.html
*/

#define LEAN_PQ_CONNECTION_FAILED_INIT 100

struct connection {
  PGconn *conn;
};

typedef struct connection Connection;

static lean_external_class *global_pq_connection_external_class = NULL;

static void pq_connection_finalizer(void *h) {
  Connection *connection = (Connection *)h;
#if DEBUG
  fprintf(stderr, "pq_connection_finalizer %p\n", connection->conn);
#endif
  // Closes the connection to the server. Also frees memory used by the PGconn
  // object.
  PQfinish(connection->conn);
  free(connection);
}

static void pq_connection_foreach(void *mod, b_lean_obj_arg fn) {}

lean_object *pq_connection_wrap_handle(Connection *hcurl) {
  return lean_alloc_external(global_pq_connection_external_class, hcurl);
}

static Connection *pq_connection_get_handle(lean_object *hcurl) {
  return (Connection *)lean_get_external_data(hcurl);
}

static void initialize() {
  if (global_pq_connection_external_class == NULL) {
    global_pq_connection_external_class = lean_register_external_class(
        pq_connection_finalizer, pq_connection_foreach);
  }
}

// //PQconnectdbParams
// LEAN_EXPORT lean_object *lean_pq_connect_db_params(b_lean_obj_arg keywords, b_lean_obj_arg values, b_lean_obj_arg expand_dbname) {
//   initialize();

//   PGconn *conn = PQconnectdbParams(NULL, NULL, NULL, NULL, NULL); // Create the libpq handle

//   Connection *connection = (Connection *)malloc(sizeof *connection); // Allocate our wrapper

//   if (!context)
//     return lean_io_result_mk_error(lean_box(CURLE_FAILED_INIT));

//   // Initialize all fields to safe defaults
//   context->curl = curl;

// #if DEBUG
//   fprintf(stderr, "curl_easy_init %p\n", curl);
// #endif

//   if (!curl)
//     return lean_io_result_mk_error(lean_box(CURLE_FAILED_INIT));
//   else
//     return lean_io_result_mk_ok(context_wrap_handle(context));
// }

//PQconnectdb
LEAN_EXPORT lean_object *lean_pq_connect_db(b_lean_obj_arg conninfo) {
  initialize();
  const char *conninfo_cstr = lean_string_cstr(conninfo); // Convert Lean string to C string
  PGconn *conn = PQconnectdb(conninfo_cstr); // Create the libpq handle

  Connection *connection = (Connection *)malloc(sizeof *connection); // Allocate our wrapper

  if (!connection)
    return lean_io_result_mk_error(lean_box(LEAN_PQ_CONNECTION_FAILED_INIT));

  // Initialize all fields to safe defaults
  connection->conn = conn;

#if DEBUG
  fprintf(stderr, "pq_connect_db %p\n", conn);
#endif

  if (!conn)
    return lean_io_result_mk_error(lean_box(LEAN_PQ_CONNECTION_FAILED_INIT));
  else
    return lean_io_result_mk_ok(pq_connection_wrap_handle(connection));
}

// struct connection *create_connection(const char *host, const char *port,
// const char *user, const char *password, const char *database) {
//     PGconn *conn = PQconnectdb(host, port, user, password, database);
//     return conn;
// }