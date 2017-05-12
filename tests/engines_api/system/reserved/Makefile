TESTS=hostnames ports engine_names hostnames

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
hostnames:
	engines system reserved hostnames |engines_test_expects array
	
ports:
	engines system reserved ports |engines_test_expects array 
 
engine_names:
	engines system reserved engine_names  |engines_test_expects array
	

	
	