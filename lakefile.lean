import Lake
open System Lake DSL

def pkgConfigLibpq : Array String := run_io do
  let output ← IO.Process.run {
    cmd := "pkg-config"
    args := #["--libs", "libpq"]
  }
  IO.println output.splitOn.toArray
  return output.dropRight 1 |>.splitOn.toArray

package leanPq where
  version := v!"0.1.0"
  moreLinkArgs := pkgConfigLibpq

def buildType := match get_config? buildType with | some "debug" => Lake.BuildType.debug | _ => Lake.BuildType.release

@[default_target]
lean_lib LeanPq

lean_exe examples where
  root := `Examples

@[test_driver]
lean_exe test {
  srcDir := "tests"
  buildType := buildType
  root := `Test
  moreLinkArgs := pkgConfigLibpq
}

target libpq_o pkg : FilePath := do
  let libpq_shim_c := pkg.dir / "libpq" / "shim.c"
  let libpq_shim_o := pkg.buildDir / "libpq" / "shim.o"
  IO.FS.createDirAll libpq_shim_o.parent.get!
  buildFileAfterDep libpq_shim_o (<- inputFile libpq_shim_c true) fun libpq_shim_src => do
    let lean_dir := (<- getLeanIncludeDir).toString
    compileO libpq_shim_o libpq_shim_src #["-I", lean_dir, "-fPIC", "-DDEBUG=0"]

extern_lib libpq pkg := do
  let name := nameToStaticLib "libpq"
  let libpq_o <- fetch <| pkg.target ``libpq_o
  buildStaticLib (pkg.buildDir / "lib" / name) #[libpq_o]
