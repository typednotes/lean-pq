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

@[extern "lean_pq_db"]
opaque PqDb (conn : Handle): EIO LeanPq.Error String

end Extern
