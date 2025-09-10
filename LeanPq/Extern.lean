namespace LeanPq

opaque Handle : Type := Unit

namespace Extern

@[extern "lean_pq_connect_db"]
opaque pq_connect_db (conninfo : String): EIO UInt32 Handle

end Extern
