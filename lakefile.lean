import Lake
open System Lake DSL

def linkArgsLinux : IO (Array String) := do
  let p ← IO.Process.run { cmd := "/bin/sh", args := #["-c", "ldconfig -p | grep -m 1 libpq | awk '{ print $4 }'"]}
  pure (if p.trim.isEmpty then #["-lpq"] else #[p.trim])

def linkArgsDarwin : IO (Array String) := do
  let output ← IO.Process.run {
    cmd := "pkg-config"
    args := #["--libs", "libpq"]
  }
  return output.dropRight 1 |>.splitOn.toArray

def linkArgs : Array String := run_io do
  if System.Platform.isOSX then
    return <- linkArgsDarwin
  else
    return <- linkArgsLinux

package leanPq where
  version := v!"0.1.0"
  moreLinkArgs := linkArgs

def buildType := match get_config? buildType with | some "debug" => Lake.BuildType.debug | _ => Lake.BuildType.release

@[default_target]
lean_lib LeanPq

-- @[default_target]
lean_exe examples {
  root := `Examples
}

@[test_driver]
lean_exe test {
  srcDir := "Tests"
  buildType := buildType
  root := `Test
}

def traceArgs : FetchM (Array String) := do
  let output ← IO.Process.run {
    cmd := "pkg-config"
    args := #["--cflags", "libpq"]
  }
  logInfo s!"traceArgs: {output}"
  return (output.dropRight 1 |>.splitOn.toArray)

target extern_o pkg : FilePath := do
  let LeanPq_extern_c := pkg.dir / "LeanPq" / "extern.c"
  let LeanPq_extern_o := pkg.buildDir / "LeanPq" / "extern.o"
  IO.FS.createDirAll LeanPq_extern_o.parent.get!
  let lean_dir := (← getLeanIncludeDir).toString
  let trace_args ← traceArgs
  buildO LeanPq_extern_o (← inputTextFile LeanPq_extern_c) (#["-I", lean_dir]++trace_args) #["-fPIC"]

@[default_target]
extern_lib extern pkg := do
  let name := nameToStaticLib "extern"
  let LeanPq_extern_o <- extern_o.fetch
  buildStaticLib (pkg.sharedLibDir / name) #[LeanPq_extern_o]
