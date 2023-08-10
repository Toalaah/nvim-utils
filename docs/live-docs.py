#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p "python3.withPackages (ps: [ ps.livereload ])"
# vim: ft=python

from livereload import Server, shell
from tempfile import mkdtemp
import shutil
import logging as log
import os

tmpdir = mkdtemp()
root = os.path.join(tmpdir, "result")
log.info(f"Created temporary directory at {tmpdir}")


def rebuild():
    log.info("Rebuilding")
    cmd = shell(f"nix-build --out-link {root}")
    cmd()


log.info("Performing initial site build")
rebuild()
server = Server()
server.watch("src/**/*", rebuild)
server.watch("../modules/**/*", rebuild)
server.watch("../lib/**/*", rebuild)
server.serve(port=8080, root=root)
log.info("Removing temporary directory")
shutil.rmtree(tmpdir, ignore_errors=True)
