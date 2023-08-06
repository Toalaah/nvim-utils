Generate documentation (including auto-generation of source-code options)

```shell
export LIB=$(pwd)/../lib
export PATH=$(pwd):$PATH
export MDBOOK_ROOT=$(pwd)
mdbook build
```

Dependencies: `mdbook (>= 0.4) nixdoc (>= 2.0), mdbook-cmdrun`
