.PHONY:test app

app:
	dune build ./bin
	firefox _build/default/bin/index.html &

test:
	dune runtest

switch:
	opam switch create . --deps-only
