#include <lean/lean.h>
#include <libpq-fe.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/*
LibPQ documentation:
https://www.postgresql.org/docs/current/libpq.html
*/

#define DEBUG 1

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

lean_obj_res pq_connection_wrap_handle(Connection *hcurl) {
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

// PQconnectdbParams
LEAN_EXPORT lean_obj_res lean_pq_connect_db_params(b_lean_obj_arg keywords, b_lean_obj_arg values, b_lean_obj_arg expand_dbname) {
  fprintf(stdout, "lean_pq_connect_db_params\n");
  initialize();
  size_t size = lean_array_size(keywords);
  const char **keywords_cstr = (const char **)malloc(size * sizeof(const char *));
  const char **values_cstr = (const char **)malloc(size * sizeof(const char *));
  for (size_t i = 0; i < size; i++) {
    keywords_cstr[i] = lean_string_cstr(lean_array_uget(keywords, i));
    fprintf(stderr, "keywords_cstr[%zu] = %s\n", i, keywords_cstr[i]);
  }
  for (size_t i = 0; i < size; i++) {
    values_cstr[i] = lean_string_cstr(lean_array_uget(values, i));
    fprintf(stderr, "values_cstr[%zu] = %s\n", i, values_cstr[i]);
  }
  int expand_dbname_cstr = lean_unbox(expand_dbname);
  PGconn *conn = PQconnectdbParams(keywords_cstr, values_cstr, expand_dbname_cstr); // Create the libpq handle

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

// PQconnectdb
LEAN_EXPORT lean_obj_res lean_pq_connect_db(b_lean_obj_arg conninfo) {
  fprintf(stdout, "lean_pq_connect_db\n");
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

LEAN_EXPORT lean_obj_res lean_pq_finish(b_lean_obj_arg conn) {
  fprintf(stdout, "lean_pq_finish\n");
  Connection *connection = pq_connection_get_handle(conn);
  PQfinish(connection->conn);
  return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_pq_reset(b_lean_obj_arg conn) {
  fprintf(stdout, "lean_pq_reset\n");
  Connection *connection = pq_connection_get_handle(conn);
  PQreset(connection->conn);
  return lean_io_result_mk_ok(lean_box(0));
}

// Quick test outputing a string
LEAN_EXPORT lean_obj_res lean_pq_quick_test() {
  const char *str = "Hello, World!";
  return lean_io_result_mk_ok(lean_mk_string(str));
}