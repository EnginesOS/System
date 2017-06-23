TESTS=list remove view add 

tests:
	echo \033[0;31m Sercice Consumers tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines service dns consumers |engines_test_expects array
	
view:
	engines service dns consumer email email |engines_test_expects json type_path dns