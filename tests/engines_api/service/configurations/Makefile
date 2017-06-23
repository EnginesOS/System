TESTS=list set view

tests:
	echo \033[0;31m Service Configurations tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines service smtp configurations |engines_test_expects array
	
view:
	engines service smtp configuration default_domain |engines_test_expects json configurator_name default_domain

set:
	echo '{ "variables":{ "domain_name":"test.current.engines" }} ' | engines service smtp configuration run default_domain  |engines_test_expects bool true