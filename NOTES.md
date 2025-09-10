---
title: Lean PQ
---

# Develepment Environment

## Ubuntu

`docker run --rm -it -v $(pwd):/workspace -w /workspace ubuntu:latest bash`

Then:
```bash
apt update
apt install git build-essential curl libcurl4-openssl-dev pkg-config
curl https://elan.lean-lang.org/elan-init.sh | sh
source $HOME/.elan/env
```

# References

## Lean 4

https://blog.cofree.coffee/2024-03-03-lean-for-haskell-developers/

### Doc about Lean FFI

https://github.com/leanprover/lean4/blob/master/doc/dev/ffi.md

### FFI Tutorial

https://github.com/DSLstandard/Lean4-FFI-Programming-Tutorial-GLFW
or https://gist.github.com/ydewit/7ab62be1bd0fea5bd53b48d23914dd6b
referred in the first link.

### Headers

https://github.com/leanprover/lean4/blob/master/src/include/lean/lean.h

## FFI Examples

### Example of redis-lean

https://github.com/marcellop71/redis-lean/tree/main

### Example FFI

https://github.com/leanprover/lean4/blob/master/src/lake/examples/ffi/lib/lakefile.lean

## LibPQ

### libpq documentation

### Binding inspiration

#### Postgresql-simple

https://github.com/haskellari/postgresql-simple

#### Hasql

https://github.com/nikita-volkov/hasql

# Linkiong

To get the flags you can run: `pkg-config --libs libcurl`