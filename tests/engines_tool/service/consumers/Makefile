TESTS=list remove view add 

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines service dns consumers |engines_test_expects array
	
view:
	engines service dns consumer email email |engines_test_expects json type_path dns