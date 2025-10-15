import LeanPq.Extern
import LeanPq.Error

open Lean
open LeanPq
open Extern

open Std
open ToString

def f (x: Nat) : Nat := x + 1

def testConnect : EIO LeanPq.Error PGresult := do
  let conninfo := "host=localhost port=5432 user=postgres password=postgres dbname=postgres"
  let conn ← PqConnectDb conninfo
  let db ← PqDb conn
  let result ← PqExec conn "SELECT 1"
  return result

def main : IO Unit := do
  let result ← testConnect.toIO (fun e => IO.Error.otherError 0 (toString e))
  -- IO.println result
  IO.println s!"Test"
  -- let keywords := #["host", "port", "user", "password", "dbname"]
  -- let values := #["localhost", "5432", "postgres", "postgres", "postgres"]
  -- let _ := do
  --   let conn <- PqConnectDbParams keywords values
  --   PqReset conn
  --   PqFinish conn
  IO.println s!"Test done"
