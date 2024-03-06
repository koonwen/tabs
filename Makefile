test:
	dune exec -- main

switch:
	opam switch create . --deps-only
