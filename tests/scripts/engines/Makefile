TESTS=engines state container_name build builder

tests:
	$(foreach test,$(TESTS),  make $(test);)
	
engines:
	engines_tool engines 
	
state:
	engines_tool engines state
	
container_name:
	engines_tool engines container_name
	
build:
	cat build_test.json | engines_tool engines build
	
builder:
	engines_tool engines builder status
	engines_tool engines builder follow
	engines_tool engines builder last