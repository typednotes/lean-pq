import LeanPq.Extern
import LeanPq.Error

open Lean
open LeanPq
open Extern


def doConnect : EIO LeanPq.Error ExecStatus := do
  let conninfo := "host=localhost port=5432 dbname=postgres user=postgres password=test"
  let conn ← PqConnectDb conninfo
  let connStatus ← PqStatus conn
  (IO.println s!"connection status: {connStatus}").toEIO (fun e => LeanPq.Error.otherError (toString e))
  let result ← PqExec conn "SELECT * FROM test;"
  let resStatus ← PqResultStatus result
  return resStatus

def main : IO Unit := do
  let result ← doConnect.toIO (fun e => IO.Error.otherError 0 (toString e))
  IO.println s!"Result: {result}"
  IO.println s!"Test done"
