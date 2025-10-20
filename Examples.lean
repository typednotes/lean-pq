import LeanPq.Extern
import LeanPq.Error

open Lean
open LeanPq
open Extern


def doConnect : EIO LeanPq.Error ExecStatus := do
  let conninfo := "host=localhost port=5432 user=postgres password=postgres dbname=postgres"
  let conn ← PqConnectDb conninfo
  let result ← PqExec conn "SELECT 1"
  let res ← PqResultStatus result
  return res

def main : IO Unit := do
  let result ← doConnect.toIO (fun e => IO.Error.otherError 0 (toString e))
  IO.println s!"Result: {result}"
  IO.println s!"Test done"
