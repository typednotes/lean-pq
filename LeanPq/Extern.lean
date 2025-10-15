/-
https://gist.github.com/ydewit/7ab62be1bd0fea5bd53b48d23914dd6b#4-scalar-values-in-lean-s-ffi
-/
import LeanPq.Error

namespace LeanPq

opaque Handle : Type := Unit

namespace Extern

@[extern "lean_pq_connect_db_params"]
opaque PqConnectDbParams (keywords : Array String) (values : Array String) (expand_dbname : Int := 0): EIO LeanPq.Error Handle

@[extern "lean_pq_connect_db"]
opaque PqConnectDb (conninfo : String): EIO LeanPq.Error Handle

@[extern "lean_pq_reset"]
opaque PqReset (conn : Handle): EIO LeanPq.Error  Unit

@[extern "lean_pq_finish"]
opaque PqFinish (conn : Handle): EIO LeanPq.Error Unit

-- [Connection Status Functions](https://www.postgresql.org/docs/current/libpq-status.html)

@[extern "lean_pq_db"]
opaque PqDb (conn : Handle): EIO LeanPq.Error String

@[extern "lean_pq_user"]
opaque PqUser (conn : Handle): EIO LeanPq.Error String

@[extern "lean_pq_pass"]
opaque PqPass (conn : Handle): EIO LeanPq.Error String

@[extern "lean_pq_host"]
opaque PqHost (conn : Handle): EIO LeanPq.Error String

@[extern "lean_pq_host_addr"]
opaque PqHostAddr (conn : Handle): EIO LeanPq.Error String

@[extern "lean_pq_port"]
opaque PqPort (conn : Handle): EIO LeanPq.Error String

@[extern "lean_pq_tty"]
opaque PqTty (conn : Handle): EIO LeanPq.Error String

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

@[extern "lean_pq_status"]
opaque PqStatus (conn : Handle): EIO LeanPq.Error ConnStatus

/--
PostgreSQL transaction status values returned by `PQtransactionStatus()`.

These values indicate the current state of the database transaction.
-/
inductive TransactionStatus where
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


instance : ToString TransactionStatus where
  toString := fun
  | .idle => s!"Idle."
  | .active => s!"Active."
  | .inTransaction => s!"In Transaction."
  | .inError => s!"In Error."
  | .unknown => s!"Unknown."

@[extern "lean_pq_transaction_status"]
opaque PqTransactionStatus (conn : Handle): EIO LeanPq.Error TransactionStatus

@[extern "lean_pq_parameter_status"]
opaque PqParameterStatus (conn : Handle) (param_name : String): EIO LeanPq.Error String






end Extern
