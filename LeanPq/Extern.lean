namespace LeanPq

opaque Handle : Type := Unit

namespace Extern

@[extern "lean_pq_connect_db_params"]
opaque PqConnectDbParams (keywords : Array String) (values : Array String) (expand_dbname : Int := 0): EIO UInt32 Handle

@[extern "lean_pq_connect_db"]
opaque PqConnectDb (conninfo : String): EIO UInt32 Handle

@[extern "lean_pq_reset"]
opaque PqReset (conn : Handle): EIO UInt32 Unit

@[extern "lean_pq_finish"]
opaque PqFinish (conn : Handle): EIO UInt32 Unit

@[extern "lean_pq_quick_test"]
opaque PqQuickTest: EIO UInt32 String

end Extern
