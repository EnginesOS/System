TESTS=hostnames ports engine_names hostnames

tests:
	$(foreach test,$(TESTS),  make $(test);)
	
hostnames:
	engines_tool system reserved hostnames |engines_test_expects
	
ports:
	engines_tool system reserved ports |engines_test_expects
 
engine_names:
	engines_tool system reserved engine_names  |engines_test_expects
	

	
	