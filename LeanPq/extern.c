#include <lean/lean.h>
#include <libpq-fe.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/*
LibPQ documentation:
https://www.postgresql.org/docs/current/libpq.html

https://gist.github.com/ydewit/7ab62be1bd0fea5bd53b48d23914dd6b#4-scalar-values-in-lean-s-ffi
*/


#define DEBUG 1

#define LEAN_PQ_CONNECTION_FAILED_INIT 100

// [Database Connection Control Functions](https://www.postgresql.org/docs/current/libpq-connect.html)


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

// Error management

static lean_object* mk_pq_connection_error(const uint32_t code) {
  lean_object* code_obj = lean_box_uint32(code);
  lean_object* connect_err = lean_alloc_ctor(0, 1, 0); // IOError constructor
  lean_ctor_set(connect_err, 0, code_obj);
  return connect_err;
}

static lean_object* mk_pq_other_error(const char* msg) {
  lean_object* msg_obj = lean_mk_string(msg);
  lean_object* other_err = lean_alloc_ctor(1, 1, 0); // IOError constructor
  lean_ctor_set(other_err, 0, msg_obj);
  return other_err;
}

// PQconnectdbParams
LEAN_EXPORT lean_obj_res lean_pq_connect_db_params(b_lean_obj_arg keywords, b_lean_obj_arg values, b_lean_obj_arg expand_dbname) {
  initialize();
  size_t size = lean_array_size(keywords);
  const char **keywords_cstr = (const char **)malloc(size * sizeof(const char *));
  const char **values_cstr = (const char **)malloc(size * sizeof(const char *));
  for (size_t i = 0; i < size; i++) {
    keywords_cstr[i] = lean_string_cstr(lean_array_uget(keywords, i));
  }
  for (size_t i = 0; i < size; i++) {
    values_cstr[i] = lean_string_cstr(lean_array_uget(values, i));
  }
  int expand_dbname_cstr = lean_unbox(expand_dbname);
  PGconn *conn = PQconnectdbParams(keywords_cstr, values_cstr, expand_dbname_cstr); // Create the libpq handle
  ConnStatusType status = PQstatus(conn);
  if (status != CONNECTION_OK)
    return lean_io_result_mk_error(mk_pq_connection_error((uint32_t)status));
  Connection *connection = (Connection *)malloc(sizeof *connection); // Allocate our wrapper
  if (!connection)
    return lean_io_result_mk_error(mk_pq_other_error("No connection"));

  // Initialize all fields to safe defaults
  connection->conn = conn;
#if DEBUG
  fprintf(stderr, "pq_connect_db %p\n", conn);
#endif
  if (!conn)
    return lean_io_result_mk_error(mk_pq_other_error("No connection"));
  else
    return lean_io_result_mk_ok(pq_connection_wrap_handle(connection));
}

// PQconnectdb
LEAN_EXPORT lean_obj_res lean_pq_connect_db(b_lean_obj_arg conninfo) {
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
  Connection *connection = pq_connection_get_handle(conn);
  PQfinish(connection->conn);
  return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_pq_reset(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  PQreset(connection->conn);
  return lean_io_result_mk_ok(lean_box(0));
}

// [Connection Status Functions](https://www.postgresql.org/docs/current/libpq-status.html)

LEAN_EXPORT lean_obj_res lean_pq_db(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * db = PQdb(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(db));
}

LEAN_EXPORT lean_obj_res lean_pq_user(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * user = PQuser(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(user));
}

LEAN_EXPORT lean_obj_res lean_pq_pass(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * pass = PQpass(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(pass));
}

LEAN_EXPORT lean_obj_res lean_pq_host(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * host = PQhost(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(host));
}

LEAN_EXPORT lean_obj_res lean_pq_host_addr(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * host = PQhostaddr(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(host));
}

LEAN_EXPORT lean_obj_res lean_pq_port(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * port = PQport(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(port));
}

LEAN_EXPORT lean_obj_res lean_pq_tty(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * tty = PQtty(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(tty));
}

LEAN_EXPORT lean_obj_res lean_pq_options(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * options = PQoptions(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(options));
}

LEAN_EXPORT lean_obj_res lean_pq_status(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  ConnStatusType status = PQstatus(connection->conn);
  lean_object * status_result = lean_alloc_ctor(status, 0, 0);
  return lean_io_result_mk_ok(status_result);
}

LEAN_EXPORT lean_obj_res lean_pq_transaction_status(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  PGTransactionStatusType transaction_status = PQtransactionStatus(connection->conn);
  lean_object * transaction_status_result = lean_alloc_ctor(transaction_status, 0, 0);
  return lean_io_result_mk_ok(transaction_status_result);
}

LEAN_EXPORT lean_obj_res lean_pq_parameter_status(b_lean_obj_arg conn, b_lean_obj_arg param_name) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * param_name_cstr = lean_string_cstr(param_name);
  const char * param_value = PQparameterStatus(connection->conn, param_name_cstr);
  return lean_io_result_mk_ok(lean_mk_string(param_value));
}

