TESTS=add list remove

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines_tool service dns consumers |engines_test_expects array
	
view:
	engines_tool service dns consumer email email |engines_test_expects json type_path dns