namespace LeanPq

inductive Error where
  | connectionError (code : UInt32)

instance : ToString Error where
  toString
  | .connectionError code => s!"Connection error: {code}."

end LeanPq
