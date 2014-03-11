export WEBMANCHINE_PORT=8005

ERL			?= erl
ERL			= erlc
EBIN_DIRS		:= $(wildcard deps/*/ebin)

.PHONY: rel deps test

all: deps compile

allcompile: deps
	@./rebar compile
	
compile:
	@./rebar compile 

devel:
	@./rebar compile skip_deps=true	

deps:
	@./rebar get-deps
	@./rebar check-deps

clean:
	@./rebar clean

realclean: clean
	@./rebar delete-deps

test:
	@mkdir .eunit
	@cp -r test/vectors .eunit/
	@./rebar skip_deps=true eunit

rel: deps
	@./rebar compile generate

doc:
	./rebar skip_deps=true doc

console:
	@erl -pa deps/*/ebin deps/*/include ebin include  -pa apps/*/ebin

analyze: checkplt
	@./rebar skip_deps=true dialyze

buildplt:
	@./rebar skip_deps=true build-plt

checkplt: buildplt
	@./rebar skip_deps=true check-plt


xref:
	@./rebar skip_deps=true xref
	
        
