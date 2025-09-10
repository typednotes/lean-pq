import LeanPq.Extern

open Lean
open LeanPq

open Extern

def main : IO Unit := do
  try
    IO.println s!"Test"
    let conninfo := "host=localhost port=5432 user=postgres password=postgres dbname=postgres"
    let conn := pq_connect_db conninfo
    -- IO.println s!"conn: {conn}"
  catch e => IO.println s!"error: {e}"
