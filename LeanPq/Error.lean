namespace LeanPq

inductive Error where
  | connectionError (code : UInt32)
  | otherError (msg: String)
  deriving BEq, DecidableEq, Repr, Inhabited


instance : ToString Error where
  toString := fun
  | .connectionError code => s!"Connection error: {code}."
  | .otherError msg => s!"Other error: {msg}."

end LeanPq
