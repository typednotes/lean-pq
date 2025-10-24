/-
https://gist.github.com/ydewit/7ab62be1bd0fea5bd53b48d23914dd6b#4-scalar-values-in-lean-s-ffi
-/
import LeanPq.Error

namespace LeanPq

opaque Handle : Type := Unit

namespace Extern

/-- Makes a new connection to the database server using parameter arrays.
Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQCONNECTDBPARAMS -/
@[extern "lean_pq_connect_db_params"]
opaque PqConnectDbParams (keywords : Array String) (values : Array String) (expand_dbname : Int := 0): EIO LeanPq.Error Handle

/-- Makes a new connection to the database server using a connection string.
Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQCONNECTDB -/
@[extern "lean_pq_connect_db"]
opaque PqConnectDb (conninfo : String): EIO LeanPq.Error Handle

/-- Resets the communication channel with the server.
Documentation: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PQRESET -/
@[extern "lean_pq_reset"]
opaque PqReset (conn : Handle): EIO LeanPq.Error  Unit

-- [Connection Status Functions](https://www.postgresql.org/docs/current/libpq-status.html)

/-- Returns the database name of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQDB -/
@[extern "lean_pq_db"]
opaque PqDb (conn : Handle): EIO LeanPq.Error String

/-- Returns the user name of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQUSER -/
@[extern "lean_pq_user"]
opaque PqUser (conn : Handle): EIO LeanPq.Error String

/-- Returns the password of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPASS -/
@[extern "lean_pq_pass"]
opaque PqPass (conn : Handle): EIO LeanPq.Error String

/-- Returns the server host name of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQHOST -/
@[extern "lean_pq_host"]
opaque PqHost (conn : Handle): EIO LeanPq.Error String

/-- Returns the server IP address of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQHOSTADDR -/
@[extern "lean_pq_host_addr"]
opaque PqHostAddr (conn : Handle): EIO LeanPq.Error String

/-- Returns the port of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPORT -/
@[extern "lean_pq_port"]
opaque PqPort (conn : Handle): EIO LeanPq.Error String

/-- Returns the debug tty of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQTTY -/
@[extern "lean_pq_tty"]
opaque PqTty (conn : Handle): EIO LeanPq.Error String

/-- Returns the command-line options passed in the connection request.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQOPTIONS -/
@[extern "lean_pq_options"]
opaque PqOptions (conn : Handle): EIO LeanPq.Error String

/--
PostgreSQL connection status values returned by `PQstatus()`.

Each value corresponds to a specific state in the PostgreSQL connection lifecycle.
-/
inductive ConnStatus where
  /-- Connection is ready for use. -/
  | connectionOk
  /-- Connection is bad and cannot be used. -/
  | connectionBad
  /-- Connection is being established. -/
  | connectionStarted
  /-- Connection has been made. -/
  | connectionMade
  /-- Waiting for a response from the server. -/
  | connectionAwaitingResponse
  /-- Authentication completed successfully. -/
  | connectionAuthOk
  /-- Environment variables have been set. -/
  | connectionSetEnv
  /-- SSL startup is in progress. -/
  | connectionSslStartup
  /-- Connection is needed but not yet established. -/
  | connectionNeeded
  /-- Connection is being checked for writability. -/
  | connectionCheckWritable
  /-- Connection is consuming input. -/
  | connectionConsume
  /-- GSS startup is in progress. -/
  | connectionGssStartup
  /-- Connection is being checked for target. -/
  | connectionCheckTarget
  /-- Connection is being checked for standby. -/
  | connectionCheckStandby
  /-- Connection has been allocated. -/
  | connectionAllocated
  deriving BEq, DecidableEq, Repr, Inhabited


instance : ToString ConnStatus where
  toString := fun
  | .connectionOk => s!"Connection OK."
  | .connectionBad => s!"Connection BAD."
  | .connectionStarted => s!"Connection STARTED."
  | .connectionMade => s!"Connection MADE."
  | .connectionAwaitingResponse => s!"Connection AWAITING RESPONSE."
  | .connectionAuthOk => s!"Connection AUTH OK."
  | .connectionSetEnv => s!"Connection SET ENV."
  | .connectionSslStartup => s!"Connection SSL STARTUP."
  | .connectionNeeded => s!"Connection NEEDED."
  | .connectionCheckWritable => s!"Connection CHECK WRITABLE."
  | .connectionConsume => s!"Connection CONSUME."
  | .connectionGssStartup => s!"Connection GSS STARTUP."
  | .connectionCheckTarget => s!"Connection CHECK TARGET."
  | .connectionCheckStandby => s!"Connection CHECK STANDBY."
  | .connectionAllocated => s!"Connection ALLOCATED."

/-- Returns the status of the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQSTATUS -/
@[extern "lean_pq_status"]
opaque PqStatus (conn : Handle): EIO LeanPq.Error ConnStatus

/--
PostgreSQL transaction status values returned by `PQtransactionStatus()`.

These values indicate the current state of the database transaction.
-/
inductive PGTransactionStatus where
  /-- Server is idle and ready to accept commands. -/
  | idle
  /-- Server is processing a command. -/
  | active
  /-- Server is in a transaction block. -/
  | inTransaction
  /-- Server is in a failed transaction block. -/
  | inError
  /-- Server status is unknown (e.g., connection lost). -/
  | unknown
  deriving BEq, DecidableEq, Repr, Inhabited


instance : ToString PGTransactionStatus where
  toString := fun
  | .idle => s!"Idle."
  | .active => s!"Active."
  | .inTransaction => s!"In Transaction."
  | .inError => s!"In Error."
  | .unknown => s!"Unknown."

/-- Returns the current in-transaction status of the server.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQTRANSACTIONSTATUS -/
@[extern "lean_pq_transaction_status"]
opaque PqTransactionStatus (conn : Handle): EIO LeanPq.Error PGTransactionStatus

/-- Looks up a current parameter setting of the server.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPARAMETERSTATUS -/
@[extern "lean_pq_parameter_status"]
opaque PqParameterStatus (conn : Handle) (param_name : String): EIO LeanPq.Error String

/-- Returns the version of the protocol used to communicate with the server.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQPROTOCOLVERSION -/
@[extern "lean_pq_protocol_version"]
opaque PqProtocolVersion (conn : Handle): EIO LeanPq.Error Int

/-- Returns the server version number.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQSERVERVERSION -/
@[extern "lean_pq_server_version"]
opaque PqServerVersion (conn : Handle): EIO LeanPq.Error Int

/-- Returns the error message most recently generated by an operation on the connection.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQERRORMESSAGE -/
@[extern "lean_pq_error_message"]
opaque PqErrorMessage (conn : Handle): EIO LeanPq.Error String

/-- Returns the file descriptor number of the connection socket to the server.
Documentation: https://www.postgresql.org/docs/current/libpq-status.html#LIBPQ-PQSOCKET -/
@[extern "lean_pq_socket"]
opaque PqSocket (conn : Handle): EIO LeanPq.Error Int

/--
PostgreSQL result object returned by `PQexec()`.

This object contains the result of a database query.
-/
opaque PGresult: Type

/-- Submits a command to the server and waits for the result.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQEXEC -/
@[extern "lean_pq_exec"]
opaque PqExec (conn : Handle) (command : String): EIO LeanPq.Error PGresult

/-- Submits a command to the server and waits for the result, with the ability to pass parameters separately.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQEXECPARAMS -/
@[extern "lean_pq_exec_params"]
opaque PqExecParams (conn : Handle) (command : String) (nParams : Int) (paramTypes : Array USize) (paramValues : Array String) (paramLengths : Array Int) (paramFormats : Array Int) (resultFormat : Int): EIO LeanPq.Error PGresult

/-- Submits a request to create a prepared statement with the given parameters.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQPREPARE -/
@[extern "lean_pq_prepare"]
opaque PqPrepare (conn : Handle) (stmtName : String) (query : String) (nParams : Int) (paramTypes : Array USize): EIO LeanPq.Error PGresult

/-- Sends a request to execute a prepared statement with given parameters.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQEXECPREPARED -/
@[extern "lean_pq_exec_prepared"]
opaque PqExecPrepared (conn : Handle) (stmtName : String) (nParams : Int) (paramValues : Array String) (paramLengths : Array Int) (paramFormats : Array Int) (resultFormat : Int): EIO LeanPq.Error PGresult

/--
PostgreSQL execution status values returned by `PQresultStatus()`.

These values indicate the result status of a database command.
-/
inductive ExecStatus where
  /-- The string sent to the server was empty. -/
  | emptyQuery
  /-- Successful completion of a command returning no data. -/
  | commandOk
  /-- Successful completion of a command returning data. -/
  | tuplesOk
  /-- Copy In (to server) data transfer started. -/
  | copyIn
  /-- Copy Out (from server) data transfer started. -/
  | copyOut
  /-- The server sent us a Copy In/Out data transfer. -/
  | copyBoth
  /-- A response to a Describe command. -/
  | badResponse
  /-- A nonfatal error occurred. -/
  | nonfatalError
  /-- A fatal error occurred. -/
  | fatalError
  /-- A response to a Ping command. -/
  | pingResponse
  /-- A response to a Pipelined Query command. -/
  | pipelineAborted
  deriving BEq, DecidableEq, Repr, Inhabited

instance : ToString ExecStatus where
  toString := fun
  | .emptyQuery => s!"Empty Query"
  | .commandOk => s!"Command OK"
  | .tuplesOk => s!"Tuples OK"
  | .copyIn => s!"Copy In"
  | .copyOut => s!"Copy Out"
  | .copyBoth => s!"Copy Both"
  | .badResponse => s!"Bad Response"
  | .nonfatalError => s!"Nonfatal Error"
  | .fatalError => s!"Fatal Error"
  | .pingResponse => s!"Ping Response"
  | .pipelineAborted => s!"Pipeline Aborted"

-- Result Status Functions
/-- Returns the result status of the command.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTSTATUS -/
@[extern "lean_pq_result_status"]
opaque PqResultStatus (result : PGresult): EIO LeanPq.Error ExecStatus

/-- Converts the enumerated type returned by PQresultStatus into a string constant.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESSTATUS -/
@[extern "lean_pq_res_status"]
opaque PqResStatus (result : PGresult): EIO LeanPq.Error ExecStatus

/-- Returns the error message associated with the command.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTERRORMESSAGE -/
@[extern "lean_pq_result_error_message"]
opaque PqResultErrorMessage (result : PGresult): EIO LeanPq.Error String

/-- Returns an individual field of an error report.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQRESULTERRORFIELD -/
@[extern "lean_pq_result_error_field"]
opaque PqResultErrorField (result : PGresult) (fieldcode : Int): EIO LeanPq.Error String

-- Retrieving Query Result Information
/-- Returns the number of rows (tuples) in the query result.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQNTUPLES -/
@[extern "lean_pq_ntuples"]
opaque PqNtuples (result : PGresult): EIO LeanPq.Error Int

/-- Returns the number of columns (fields) in each row of the query result.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQNFIELDS -/
@[extern "lean_pq_nfields"]
opaque PqNfields (result : PGresult): EIO LeanPq.Error Int

/-- Returns the column name associated with the given column number.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFNAME -/
@[extern "lean_pq_fname"]
opaque PqFname (result : PGresult) (fieldNum : Int): EIO LeanPq.Error String

/-- Returns the column number associated with the given column name.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFNUMBER -/
@[extern "lean_pq_fnumber"]
opaque PqFnumber (result : PGresult) (fieldName : String): EIO LeanPq.Error Int

/-- Returns the OID of the table from which the given column was fetched.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFTABLE -/
@[extern "lean_pq_ftable"]
opaque PqFtable (result : PGresult) (fieldNum : Int): EIO LeanPq.Error USize

/-- Returns the column number (within its table) of the column making up the specified query result column.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFTABLECOL -/
@[extern "lean_pq_ftablecol"]
opaque PqFtablecol (result : PGresult) (fieldNum : Int): EIO LeanPq.Error Int

/-- Returns the format code indicating the format of the given column.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFFORMAT -/
@[extern "lean_pq_fformat"]
opaque PqFformat (result : PGresult) (fieldNum : Int): EIO LeanPq.Error Int

/-- Returns the data type associated with the given column number.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFTYPE -/
@[extern "lean_pq_ftype"]
opaque PqFtype (result : PGresult) (fieldNum : Int): EIO LeanPq.Error USize

/-- Returns the size in bytes of the type associated with the given column number.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFSIZE -/
@[extern "lean_pq_fsize"]
opaque PqFsize (result : PGresult) (fieldNum : Int): EIO LeanPq.Error Int

/-- Returns the type modifier of the type associated with the given column number.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQFMOD -/
@[extern "lean_pq_fmod"]
opaque PqFmod (result : PGresult) (fieldNum : Int): EIO LeanPq.Error Int

/-- Returns 1 if the PGresult contains binary tuple data, 0 if it contains text data.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQBINARYTUPLES -/
@[extern "lean_pq_binary_tuples"]
opaque PqBinaryTuples (result : PGresult): EIO LeanPq.Error Int

-- Retrieving Other Result Information
/-- Returns the command status tag from the last SQL command executed.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQCMDSTATUS -/
@[extern "lean_pq_cmd_status"]
opaque PqCmdStatus (result : PGresult): EIO LeanPq.Error String

/-- Returns the number of rows affected by the SQL command.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQCMDTUPLES -/
@[extern "lean_pq_cmd_tuples"]
opaque PqCmdTuples (result : PGresult): EIO LeanPq.Error String

/-- Returns the OID of the inserted row, if the SQL command was an INSERT that inserted exactly one row into a table that has OIDs.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQOIDVALUE -/
@[extern "lean_pq_oid_value"]
opaque PqOidValue (result : PGresult): EIO LeanPq.Error USize

/-- Returns a string with the OID of the inserted row, if the SQL command was an INSERT that inserted exactly one row into a table that has OIDs.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQOIDSTATUS -/
@[extern "lean_pq_oid_status"]
opaque PqOidStatus (result : PGresult): EIO LeanPq.Error String

-- Retrieving Row Values
/-- Returns a single field value of one row of a PGresult.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQGETVALUE -/
@[extern "lean_pq_getvalue"]
opaque PqGetvalue (result : PGresult) (rowNum : Int) (fieldNum : Int): EIO LeanPq.Error String

/-- Tests a field for a null value.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQGETISNULL -/
@[extern "lean_pq_getisnull"]
opaque PqGetisnull (result : PGresult) (rowNum : Int) (fieldNum : Int): EIO LeanPq.Error Int

/-- Returns the actual length of a field value in bytes.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQGETLENGTH -/
@[extern "lean_pq_getlength"]
opaque PqGetlength (result : PGresult) (rowNum : Int) (fieldNum : Int): EIO LeanPq.Error Int

/-- Returns the number of parameters of a prepared statement.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQNPARAMS -/
@[extern "lean_pq_nparams"]
opaque PqNparams (result : PGresult): EIO LeanPq.Error Int

/-- Returns the data type of the indicated statement parameter.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQPARAMTYPE -/
@[extern "lean_pq_paramtype"]
opaque PqParamtype (result : PGresult) (paramNum : Int): EIO LeanPq.Error USize

-- Escaping Strings for Inclusion in SQL Commands
/-- Escapes a string for use as an SQL string literal on the given connection.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPELITERAL -/
@[extern "lean_pq_escape_literal"]
opaque PqEscapeLiteral (conn : Handle) (str : String): EIO LeanPq.Error String

/-- Escapes a string for use as an SQL identifier on the given connection.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPEIDENTIFIER -/
@[extern "lean_pq_escape_identifier"]
opaque PqEscapeIdentifier (conn : Handle) (str : String): EIO LeanPq.Error String

/-- Escapes string literals, much like PQescapeLiteral, but the caller is responsible for providing an appropriately sized buffer.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPESTRINGCONN -/
@[extern "lean_pq_escape_string_conn"]
opaque PqEscapeStringConn (conn : Handle) (input : String): EIO LeanPq.Error String

/-- Escapes binary data for use within an SQL command with the type bytea.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQESCAPEBYTEACONN -/
@[extern "lean_pq_escape_bytea_conn"]
opaque PqEscapeByteaConn (conn : Handle) (input : String): EIO LeanPq.Error String

/-- Converts a string representation of binary data into binary data — the reverse of PQescapeBytea.
Documentation: https://www.postgresql.org/docs/current/libpq-exec.html#LIBPQ-PQUNESCAPEBYTEA -/
@[extern "lean_pq_unescape_bytea"]
opaque PqUnescapeBytea (str : String): EIO LeanPq.Error String

end Extern
