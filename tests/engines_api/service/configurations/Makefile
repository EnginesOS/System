TESTS=list set view

tests:
	echo -n "\033[0;34m Service Configurations tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines service smtp configurations |engines_test_expects array
	
view:
	engines service smtp configuration default_domain |engines_test_expects json configurator_name default_domain

set:
	echo '{ "variables":{ "domain_name":"test.current.engines" }} ' | engines service smtp configuration run default_domain  |engines_test_expects bool true