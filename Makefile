.PHONY:test
test:
	dune exec -- tabs

switch:
	opam switch create . --deps-only
