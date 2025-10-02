import LeanPq.Extern
import LeanPq.Error

open Lean
open LeanPq

open Extern

def main : IO Unit := do
  let testString ← PqQuickTest.toIO (fun e => IO.Error.otherError 0 "test")
  try
    IO.println testString
    IO.println s!"Test"
    IO.println (LeanPq.Error.otherError "test")
    -- let conninfo := "host=localhost port=5432 user=postgres password=postgres dbname=postgres"
    -- let conn := pq_connect_db conninfo
    -- let keywords := #["host", "port", "user", "password", "dbname"]
    -- let values := #["localhost", "5432", "postgres", "postgres", "postgres"]
    -- let _ := do
    --   let conn <- PqConnectDbParams keywords values
    --   PqReset conn
    --   PqFinish conn
    IO.println s!"Test done"
  catch e => IO.println s!"error: {e}"
  IO.println s!"Test done 2"
