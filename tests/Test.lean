import LeanPq.Extern
import LeanPq.Error

import Tests.DataType

open Lean
open LeanPq
open Extern

open Std
open ToString


def testConnect : EIO LeanPq.Error PGresult := do
  let conninfo := "host=localhost port=5432 user=postgres password=test dbname=postgres"
  let conn ← PqConnectDb conninfo
  let db ← PqDb conn
  let query := "CREATE TABLE my_first_table (
    first_column text,
    second_column integer
);"
  let query := "DROP TABLE IF EXISTS my_first_table;"
  let result ← PqExec conn query

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

#print IO.RealWorld.nonemptyType
