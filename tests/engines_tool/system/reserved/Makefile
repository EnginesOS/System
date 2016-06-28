TESTS=hostnames ports engine_names hostnames

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
hostnames:
	engines_tool system reserved hostnames |engines_test_expects array
	
ports:
	engines_tool system reserved ports |engines_test_expects array 
 
engine_names:
	engines_tool system reserved engine_names  |engines_test_expects array
	

	
	