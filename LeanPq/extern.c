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

// PQconnectdbParams - Makes a new connection to the database server using parameter arrays
// Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQCONNECTDBPARAMS
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
  int expand_dbname_int = lean_unbox(expand_dbname);
  PGconn *conn = PQconnectdbParams(keywords_cstr, values_cstr, expand_dbname_int); // Create the libpq handle
  ConnStatusType status = PQstatus(conn);
  // If the connection is not successful, return an error
  if (status != CONNECTION_OK)
    return lean_io_result_mk_error(mk_pq_connection_error((uint32_t)status));
  Connection *connection = (Connection *)malloc(sizeof *connection); // Allocate our wrapper
  if (!connection)
    return lean_io_result_mk_error(mk_pq_other_error("No connection"));
  // Initialize all fields to safe defaults
  connection->conn = conn;
#if DEBUG
  fprintf(stderr, "Connection %p\n", conn);
#endif
  if (!conn)
    return lean_io_result_mk_error(mk_pq_other_error("No connection"));
  else
    return lean_io_result_mk_ok(pq_connection_wrap_handle(connection));
}

// PQconnectdb - Makes a new connection to the database server using a connection string
// Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQCONNECTDB
LEAN_EXPORT lean_obj_res lean_pq_connect_db(b_lean_obj_arg conninfo) {
  initialize();
  const char *conninfo_cstr = lean_string_cstr(conninfo); // Convert Lean string to C string
  PGconn *conn = PQconnectdb(conninfo_cstr); // Create the libpq handle
  ConnStatusType status = PQstatus(conn);
  // If the connection is not successful, return an error
  if (status != CONNECTION_OK)
    return lean_io_result_mk_error(mk_pq_connection_error((uint32_t)status));
  Connection *connection = (Connection *)malloc(sizeof *connection); // Allocate our wrapper
  if (!connection)
    return lean_io_result_mk_error(lean_box(LEAN_PQ_CONNECTION_FAILED_INIT));
  // Initialize all fields to safe defaults
  connection->conn = conn;
#if DEBUG
  fprintf(stderr, "Connection %p\n", conn);
#endif
  if (!conn)
    return lean_io_result_mk_error(lean_box(LEAN_PQ_CONNECTION_FAILED_INIT));
  else
    return lean_io_result_mk_ok(pq_connection_wrap_handle(connection));
}

// PQfinish - Closes the connection to the server and frees memory
// Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQFINISH
LEAN_EXPORT lean_obj_res lean_pq_finish(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  PQfinish(connection->conn);
  return lean_io_result_mk_ok(lean_box(0));
}

// PQreset - Resets the communication channel with the server
// Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQRESET
LEAN_EXPORT lean_obj_res lean_pq_reset(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  PQreset(connection->conn);
  return lean_io_result_mk_ok(lean_box(0));
}

// [Connection Status Functions](https://www.postgresql.org/docs/current/libpq-status.html)

// PQdb - Returns the database name of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQDB
LEAN_EXPORT lean_obj_res lean_pq_db(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * db = PQdb(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(db));
}

// PQuser - Returns the user name of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQUSER
LEAN_EXPORT lean_obj_res lean_pq_user(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * user = PQuser(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(user));
}

// PQpass - Returns the password of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPASS
LEAN_EXPORT lean_obj_res lean_pq_pass(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * pass = PQpass(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(pass));
}

// PQhost - Returns the server host name of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQHOST
LEAN_EXPORT lean_obj_res lean_pq_host(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * host = PQhost(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(host));
}

// PQhostaddr - Returns the server IP address of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQHOSTADDR
LEAN_EXPORT lean_obj_res lean_pq_host_addr(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * host = PQhostaddr(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(host));
}

// PQport - Returns the port of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPORT
LEAN_EXPORT lean_obj_res lean_pq_port(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * port = PQport(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(port));
}

// PQtty - Returns the debug tty of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQTTY
LEAN_EXPORT lean_obj_res lean_pq_tty(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * tty = PQtty(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(tty));
}

// PQoptions - Returns the command-line options passed in the connection request
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQOPTIONS
LEAN_EXPORT lean_obj_res lean_pq_options(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * options = PQoptions(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(options));
}

// PQstatus - Returns the status of the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQSTATUS
LEAN_EXPORT lean_obj_res lean_pq_status(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  ConnStatusType status = PQstatus(connection->conn);
  lean_object * status_obj = lean_box_uint32((uint32_t)status);
  return lean_io_result_mk_ok(status_obj);
}

// PQtransactionStatus - Returns the current in-transaction status of the server
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQTRANSACTIONSTATUS
LEAN_EXPORT lean_obj_res lean_pq_transaction_status(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  PGTransactionStatusType transaction_status = PQtransactionStatus(connection->conn);
  lean_object * transaction_status_obj = lean_box_uint32((uint32_t)transaction_status);
  return lean_io_result_mk_ok(transaction_status_obj);
}

// PQparameterStatus - Looks up a current parameter setting of the server
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPARAMETERSTATUS
LEAN_EXPORT lean_obj_res lean_pq_parameter_status(b_lean_obj_arg conn, b_lean_obj_arg param_name) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * param_name_cstr = lean_string_cstr(param_name);
  const char * param_value = PQparameterStatus(connection->conn, param_name_cstr);
  return lean_io_result_mk_ok(lean_mk_string(param_value));
}

// PQprotocolVersion - Returns the version of the protocol used to communicate with the server
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPROTOCOLVERSION
LEAN_EXPORT lean_obj_res lean_pq_protocol_version(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  int protocol_version = PQprotocolVersion(connection->conn);
  lean_object * protocol_version_boxed = lean_box_uint32((uint32_t)protocol_version);
  return lean_io_result_mk_ok(protocol_version_boxed);
}

// PQserverVersion - Returns the server version number
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQSERVERVERSION
LEAN_EXPORT lean_obj_res lean_pq_server_version(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  int server_version = PQserverVersion(connection->conn);
  lean_object * server_version_boxed = lean_box_uint32((uint32_t)server_version);
  return lean_io_result_mk_ok(server_version_boxed);
}

// PQerrorMessage - Returns the error message most recently generated by an operation on the connection
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQERRORMESSAGE
LEAN_EXPORT lean_obj_res lean_pq_error_message(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * error_message = PQerrorMessage(connection->conn);
  return lean_io_result_mk_ok(lean_mk_string(error_message));
}

// PQsocket - Returns the file descriptor number of the connection socket to the server
// Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQSOCKET
LEAN_EXPORT lean_obj_res lean_pq_socket(b_lean_obj_arg conn) {
  Connection *connection = pq_connection_get_handle(conn);
  int socket = PQsocket(connection->conn);
  lean_object * socket_boxed = lean_box_uint32((uint32_t)socket);
  return lean_io_result_mk_ok(socket_boxed);
}

// [Command Execution Functions](https://www.postgresql.org/docs/current/libpq-exec.html)

// PQexec - Submits a command to the server and waits for the result
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQEXEC
LEAN_EXPORT lean_obj_res lean_pq_exec(b_lean_obj_arg conn, b_lean_obj_arg cmd) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * cmd_cstr = lean_string_cstr(cmd);
  PGresult * result = PQexec(connection->conn, cmd_cstr);
  lean_object * result_boxed = lean_box_usize((size_t)result);
  return lean_io_result_mk_ok(result_boxed);
}

// PQexecParams - Submits a command to the server and waits for the result, with the ability to pass parameters separately
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQEXECPARAMS
LEAN_EXPORT lean_obj_res lean_pq_exec_params(
  b_lean_obj_arg conn,
  b_lean_obj_arg cmd,
  b_lean_obj_arg nParams,
  b_lean_obj_arg paramTypes,
  b_lean_obj_arg paramValues,
  b_lean_obj_arg paramLengths,
  b_lean_obj_arg paramFormats,
  b_lean_obj_arg resultFormat) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * cmd_cstr = lean_string_cstr(cmd);
  int nParams_int = lean_unbox(nParams);
  const Oid * paramTypes_oid = (const Oid *)lean_unbox(paramTypes);
  const char * const * paramValues_cstr_array = (const char **)lean_unbox(paramValues);
  const int * paramLengths_int = (const int *)lean_unbox(paramLengths);
  const int * paramFormats_int = (const int *)lean_unbox(paramFormats);
  int resultFormat_int = lean_unbox(resultFormat);
  PGresult * result = PQexecParams(connection->conn, cmd_cstr, nParams_int, paramTypes_oid, paramValues_cstr_array, paramLengths_int, paramFormats_int, resultFormat_int);
  lean_object * result_boxed = lean_box_usize((size_t)result);
  return lean_io_result_mk_ok(result_boxed);
}

// PQprepare - Submits a request to create a prepared statement with the given parameters
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQPREPARE
LEAN_EXPORT lean_obj_res lean_pq_prepare(b_lean_obj_arg conn, b_lean_obj_arg stmtName, b_lean_obj_arg query, b_lean_obj_arg nParams, b_lean_obj_arg paramTypes) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * stmtName_cstr = lean_string_cstr(stmtName);
  const char * query_cstr = lean_string_cstr(query);
  const int nParams_int = lean_unbox(nParams);
  const Oid * paramTypes_oid = (const Oid *)lean_unbox(paramTypes);
  PGresult * result = PQprepare(connection->conn, stmtName_cstr, query_cstr, nParams_int, paramTypes_oid);
  lean_object * result_boxed = lean_box_usize((size_t)result);
  return lean_io_result_mk_ok(result_boxed);
}

// PQexecPrepared - Sends a request to execute a prepared statement with given parameters
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQEXECPREPARED
LEAN_EXPORT lean_obj_res lean_pq_exec_prepared(b_lean_obj_arg conn, b_lean_obj_arg stmtName, b_lean_obj_arg nParams, b_lean_obj_arg paramValues, b_lean_obj_arg paramLengths, b_lean_obj_arg paramFormats, b_lean_obj_arg resultFormat) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * stmtName_cstr = lean_string_cstr(stmtName);
  const int nParams_int = lean_unbox(nParams);
  const char * const * paramValues_cstr_array = (const char **)lean_unbox(paramValues);
  const int * paramLengths_int = (const int *)lean_unbox(paramLengths);
  const int * paramFormats_int = (const int *)lean_unbox(paramFormats);
  int resultFormat_int = lean_unbox(resultFormat);
  PGresult * result = PQexecPrepared(connection->conn, stmtName_cstr, nParams_int, paramValues_cstr_array, paramLengths_int, paramFormats_int, resultFormat_int);
  lean_object * result_boxed = lean_box_usize((size_t)result);
  return lean_io_result_mk_ok(result_boxed);
}

// [Result Functions](https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-EXEC-SELECT-INFO)

// Result Status Functions
// PQresultStatus - Returns the result status of the command
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTSTATUS
LEAN_EXPORT lean_obj_res lean_pq_result_status(b_lean_obj_arg result) {
  PGresult * result_unboxed = (PGresult *)lean_unbox_usize(result);
  ExecStatusType status = PQresultStatus(result_unboxed);
  lean_object * status_boxed = lean_box_uint32((uint32_t)status);
  return lean_io_result_mk_ok(status_boxed);
}

// PQresStatus - Converts the enumerated type returned by PQresultStatus into a string constant
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESSTATUS
LEAN_EXPORT lean_obj_res lean_pq_res_status(b_lean_obj_arg result) {
  PGresult * result_unboxed = (PGresult *)lean_unbox_usize(result);
  ExecStatusType status = PQresultStatus(result_unboxed);
  lean_object * status_boxed = lean_box_uint32((uint32_t)status);
  return lean_io_result_mk_ok(status_boxed);
}

// PQresultErrorMessage - Returns the error message associated with the command
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTERRORMESSAGE
LEAN_EXPORT lean_obj_res lean_pq_result_error_message(b_lean_obj_arg result) {
  PGresult * result_unboxed = (PGresult *)lean_unbox_usize(result);
  const char * error_message = PQresultErrorMessage(result_unboxed);
  return lean_io_result_mk_ok(lean_mk_string(error_message));
}

// PQresultErrorField - Returns an individual field of an error report
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTERRORFIELD
LEAN_EXPORT lean_obj_res lean_pq_result_error_field(b_lean_obj_arg result, b_lean_obj_arg fieldcode) {
  PGresult * result_unboxed = (PGresult *)lean_unbox_usize(result);
  int fieldcode_int = lean_unbox(fieldcode);
  const char * error_field = PQresultErrorField(result_unboxed, fieldcode_int);
  return lean_io_result_mk_ok(lean_mk_string(error_field));
}

// Retrieving Query Result Information
// PQntuples - Returns the number of rows (tuples) in the query result
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQNTUPLES
LEAN_EXPORT lean_obj_res lean_pq_ntuples(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int ntuples = PQntuples(result_obj);
  return lean_io_result_mk_ok(lean_box(ntuples));
}

// PQnfields - Returns the number of columns (fields) in each row of the query result
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQNFIELDS
LEAN_EXPORT lean_obj_res lean_pq_nfields(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int nfields = PQnfields(result_obj);
  return lean_io_result_mk_ok(lean_box(nfields));
}

// PQfname - Returns the column name associated with the given column number
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFNAME
LEAN_EXPORT lean_obj_res lean_pq_fname(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  const char * fname = PQfname(result_obj, field_num_int);
  return lean_io_result_mk_ok(lean_mk_string(fname));
}

// PQfnumber - Returns the column number associated with the given column name
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFNUMBER
LEAN_EXPORT lean_obj_res lean_pq_fnumber(b_lean_obj_arg result, b_lean_obj_arg field_name) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  const char * field_name_cstr = lean_string_cstr(field_name);
  int fnumber = PQfnumber(result_obj, field_name_cstr);
  return lean_io_result_mk_ok(lean_box(fnumber));
}

// PQftable - Returns the OID of the table from which the given column was fetched
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFTABLE
LEAN_EXPORT lean_obj_res lean_pq_ftable(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  Oid ftable = PQftable(result_obj, field_num_int);
  lean_object * ftable_obj = lean_box_usize((size_t)ftable);
  return lean_io_result_mk_ok(ftable_obj);
}

// PQftablecol - Returns the column number (within its table) of the column making up the specified query result column
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFTABLECOL
LEAN_EXPORT lean_obj_res lean_pq_ftablecol(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  int ftablecol = PQftablecol(result_obj, field_num_int);
  return lean_io_result_mk_ok(lean_box(ftablecol));
}

// PQfformat - Returns the format code indicating the format of the given column
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFFORMAT
LEAN_EXPORT lean_obj_res lean_pq_fformat(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  int fformat = PQfformat(result_obj, field_num_int);
  return lean_io_result_mk_ok(lean_box(fformat));
}

// PQftype - Returns the data type associated with the given column number
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFTYPE
LEAN_EXPORT lean_obj_res lean_pq_ftype(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  Oid ftype = PQftype(result_obj, field_num_int);
  lean_object * ftype_obj = lean_box_usize((size_t)ftype);
  return lean_io_result_mk_ok(ftype_obj);
}

// PQfsize - Returns the size in bytes of the type associated with the given column number
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFSIZE
LEAN_EXPORT lean_obj_res lean_pq_fsize(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  int fsize = PQfsize(result_obj, field_num_int);
  return lean_io_result_mk_ok(lean_box(fsize));
}

// PQfmod - Returns the type modifier of the type associated with the given column number
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFMOD
LEAN_EXPORT lean_obj_res lean_pq_fmod(b_lean_obj_arg result, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int field_num_int = lean_unbox(field_num);
  int fmod = PQfmod(result_obj, field_num_int);
  return lean_io_result_mk_ok(lean_box(fmod));
}

// PQbinaryTuples - Returns 1 if the PGresult contains binary tuple data, 0 if it contains text data
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQBINARYTUPLES
LEAN_EXPORT lean_obj_res lean_pq_binary_tuples(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int binary_tuples = PQbinaryTuples(result_obj);
  return lean_io_result_mk_ok(lean_box(binary_tuples));
}

// Retrieving Other Result Information
// PQcmdStatus - Returns the command status tag from the last SQL command executed
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQCMDSTATUS
LEAN_EXPORT lean_obj_res lean_pq_cmd_status(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  const char * cmd_status = PQcmdStatus(result_obj);
  return lean_io_result_mk_ok(lean_mk_string(cmd_status));
}

// PQcmdTuples - Returns the number of rows affected by the SQL command
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQCMDTUPLES
LEAN_EXPORT lean_obj_res lean_pq_cmd_tuples(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  const char * cmd_tuples = PQcmdTuples(result_obj);
  return lean_io_result_mk_ok(lean_mk_string(cmd_tuples));
}

// PQoidValue - Returns the OID of the inserted row, if the SQL command was an INSERT that inserted exactly one row into a table that has OIDs
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQOIDVALUE
LEAN_EXPORT lean_obj_res lean_pq_oid_value(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  Oid oid_value = PQoidValue(result_obj);
  lean_object * oid_value_obj = lean_box_usize((size_t)oid_value);
  return lean_io_result_mk_ok(oid_value_obj);
}

// PQoidStatus - Returns a string with the OID of the inserted row, if the SQL command was an INSERT that inserted exactly one row into a table that has OIDs
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQOIDSTATUS
LEAN_EXPORT lean_obj_res lean_pq_oid_status(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  const char * oid_status = PQoidStatus(result_obj);
  return lean_io_result_mk_ok(lean_mk_string(oid_status));
}

// Retrieving Row Values
// PQgetvalue - Returns a single field value of one row of a PGresult
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQGETVALUE
LEAN_EXPORT lean_obj_res lean_pq_getvalue(b_lean_obj_arg result, b_lean_obj_arg row_num, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int row_num_int = lean_unbox(row_num);
  int field_num_int = lean_unbox(field_num);
  const char * value = PQgetvalue(result_obj, row_num_int, field_num_int);
  return lean_io_result_mk_ok(lean_mk_string(value));
}

// PQgetisnull - Tests a field for a null value
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQGETISNULL
LEAN_EXPORT lean_obj_res lean_pq_getisnull(b_lean_obj_arg result, b_lean_obj_arg row_num, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int row_num_int = lean_unbox(row_num);
  int field_num_int = lean_unbox(field_num);
  int is_null = PQgetisnull(result_obj, row_num_int, field_num_int);
  return lean_io_result_mk_ok(lean_box(is_null));
}

// PQgetlength - Returns the actual length of a field value in bytes
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQGETLENGTH
LEAN_EXPORT lean_obj_res lean_pq_getlength(b_lean_obj_arg result, b_lean_obj_arg row_num, b_lean_obj_arg field_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int row_num_int = lean_unbox(row_num);
  int field_num_int = lean_unbox(field_num);
  int length = PQgetlength(result_obj, row_num_int, field_num_int);
  return lean_io_result_mk_ok(lean_box(length));
}

// PQnparams - Returns the number of parameters of a prepared statement
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQNPARAMS
LEAN_EXPORT lean_obj_res lean_pq_nparams(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int nparams = PQnparams(result_obj);
  return lean_io_result_mk_ok(lean_box(nparams));
}

// PQparamtype - Returns the data type of the indicated statement parameter
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQPARAMTYPE
LEAN_EXPORT lean_obj_res lean_pq_paramtype(b_lean_obj_arg result, b_lean_obj_arg param_num) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  int param_num_int = lean_unbox(param_num);
  Oid param_type = PQparamtype(result_obj, param_num_int);
  lean_object * param_type_obj = lean_box_usize((size_t)param_type);
  return lean_io_result_mk_ok(param_type_obj);
}

// Escaping Strings for Inclusion in SQL Commands
// PQescapeLiteral - Escapes a string for use as an SQL string literal on the given connection
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPELITERAL
LEAN_EXPORT lean_obj_res lean_pq_escape_literal(b_lean_obj_arg conn, b_lean_obj_arg str) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * str_cstr = lean_string_cstr(str);
  size_t str_length = strlen(str_cstr);
  char * escaped = PQescapeLiteral(connection->conn, str_cstr, str_length);
  if (escaped == NULL) {
    return lean_io_result_mk_error(mk_pq_other_error("PQescapeLiteral failed"));
  }
  lean_object * result = lean_mk_string(escaped);
  PQfreemem(escaped);
  return lean_io_result_mk_ok(result);
}

// PQescapeIdentifier - Escapes a string for use as an SQL identifier on the given connection
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPEIDENTIFIER
LEAN_EXPORT lean_obj_res lean_pq_escape_identifier(b_lean_obj_arg conn, b_lean_obj_arg str) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * str_cstr = lean_string_cstr(str);
  size_t str_length = strlen(str_cstr);
  char * escaped = PQescapeIdentifier(connection->conn, str_cstr, str_length);
  if (escaped == NULL) {
    return lean_io_result_mk_error(mk_pq_other_error("PQescapeIdentifier failed"));
  }
  lean_object * result = lean_mk_string(escaped);
  PQfreemem(escaped);
  return lean_io_result_mk_ok(result);
}

// PQescapeStringConn - Escapes string literals, much like PQescapeLiteral, but the caller is responsible for providing an appropriately sized buffer
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPESTRINGCONN
LEAN_EXPORT lean_obj_res lean_pq_escape_string_conn(b_lean_obj_arg conn, b_lean_obj_arg from) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * from_cstr = lean_string_cstr(from);
  size_t from_length = strlen(from_cstr);
  // Allocate buffer for escaped string (worst case: 2x original length + 1)
  size_t to_length = 2 * from_length + 1;
  char * to = (char *)malloc(to_length);
  if (to == NULL) {
    return lean_io_result_mk_error(mk_pq_other_error("Memory allocation failed"));
  }
  int error = 0;
  size_t escaped_length = PQescapeStringConn(connection->conn, to, from_cstr, from_length, &error);
  if (error != 0) {
    free(to);
    return lean_io_result_mk_error(mk_pq_other_error("PQescapeStringConn failed"));
  }
  lean_object * result = lean_mk_string(to);
  free(to);
  return lean_io_result_mk_ok(result);
}

// PQescapeByteaConn - Escapes binary data for use within an SQL command with the type bytea
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPEBYTEACONN
LEAN_EXPORT lean_obj_res lean_pq_escape_bytea_conn(b_lean_obj_arg conn, b_lean_obj_arg from) {
  Connection *connection = pq_connection_get_handle(conn);
  const char * from_cstr = lean_string_cstr(from);
  size_t from_length = strlen(from_cstr);
  size_t to_length = 0;
  unsigned char * escaped = PQescapeByteaConn(connection->conn, (const unsigned char *)from_cstr, from_length, &to_length);
  if (escaped == NULL) {
    return lean_io_result_mk_error(mk_pq_other_error("PQescapeByteaConn failed"));
  }
  lean_object * result = lean_mk_string((const char *)escaped);
  PQfreemem(escaped);
  return lean_io_result_mk_ok(result);
}

// PQunescapeBytea - Converts a string representation of binary data into binary data — the reverse of PQescapeBytea
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQUNESCAPEBYTEA
LEAN_EXPORT lean_obj_res lean_pq_unescape_bytea(b_lean_obj_arg str) {
  const char * str_cstr = lean_string_cstr(str);
  size_t str_length = strlen(str_cstr);
  size_t to_length = 0;
  unsigned char * unescaped = PQunescapeBytea((const unsigned char *)str_cstr, &to_length);
  if (unescaped == NULL) {
    return lean_io_result_mk_error(mk_pq_other_error("PQunescapeBytea failed"));
  }
  lean_object * result = lean_mk_string((const char *)unescaped);
  PQfreemem(unescaped);
  return lean_io_result_mk_ok(result);
}

// PQclear - Frees the storage associated with a PGresult
// Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQCLEAR
LEAN_EXPORT lean_obj_res lean_pq_clear(b_lean_obj_arg result) {
  PGresult * result_obj = (PGresult *)lean_unbox_usize(result);
  PQclear(result_obj);
  return lean_io_result_mk_ok(lean_box(0));
}