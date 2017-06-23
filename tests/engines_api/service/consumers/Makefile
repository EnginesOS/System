TESTS=list remove view add 

tests:
	echo -n "\033[0;31m Service Consumers tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines service dns consumers |engines_test_expects array
	
view:
	engines service dns consumer email email |engines_test_expects json type_path dns