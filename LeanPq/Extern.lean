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

inductive ConnStatus where
  | connectionOk
  | connectionBad
  | connectionStarted
  | connectionMade
  | connectionAwaitingResponse
  | connectionAuthOk
  | connectionSetEnv
  | connectionSslStartup
  | connectionNeeded
  | connectionCheckWritable
  | connectionConsume
  | connectionGssStartup
  | connectionCheckTarget
  | connectionCheckStandby
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

end Extern
