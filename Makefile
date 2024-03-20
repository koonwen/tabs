.PHONY:test app

app:
	dune build
	dune build ./bin/index.html
	firefox _build/default/bin/index.html &

test:
	dune runtest

switch:
	opam switch create . --deps-only
