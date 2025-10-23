import LeanPq.Extern
import LeanPq.Error

open Lean
open LeanPq
open Extern

/-- Fetch all results as a list of lists (rows × columns) -/
def fetchAllResults (result : PGresult) : EIO LeanPq.Error (List (List String)) := do
  let nrows ← PqNtuples result
  let ncols ← PqNfields result

  let mut rows : List (List String) := []

  for row in [0:nrows.toNat] do
    let mut cols : List String := []
    for col in [0:ncols.toNat] do
      let value ← PqGetvalue result (Int.ofNat row) (Int.ofNat col)
      cols := cols ++ [value]
    rows := rows ++ [cols]

  return rows

def doConnect : EIO LeanPq.Error Unit := do
  let conninfo := "host=localhost port=5432 dbname=postgres user=postgres password=test"
  let conn ← PqConnectDb conninfo
  let connStatus ← PqStatus conn
  (IO.println s!"connection status: {connStatus}").toEIO (fun e => LeanPq.Error.otherError (toString e))
  let result ← PqExec conn "SELECT * FROM test;"
  let resStatus ← PqResultStatus result
  (IO.println s!"Result status: {resStatus}").toEIO (fun e => LeanPq.Error.otherError (toString e))

  -- Fetch all results as list of lists
  let rows ← fetchAllResults result
  (IO.println s!"Fetched {rows.length} rows").toEIO (fun e => LeanPq.Error.otherError (toString e))

  -- Print each row
  let mut idx := 0
  for row in rows do
    (IO.println s!"Row {idx}: {row}").toEIO (fun e => LeanPq.Error.otherError (toString e))
    idx := idx + 1

def main : IO Unit := do
  let _ ← doConnect.toIO (fun e => IO.Error.otherError 0 (toString e))
  IO.println s!"Test done"
