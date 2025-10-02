import LeanPq.Error

open LeanPq

def err : Error := Error.connectionError 2

def main : IO Unit := do
  IO.println "Hello, World!"
  IO.println err
