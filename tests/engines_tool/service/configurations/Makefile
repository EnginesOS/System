TESTS=list set view

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

list:
	engines_tool service stmp configurations |engines_test_expects array
	
view:
	engines_tool service smtp configuration default_domain |engines_test_expects json configurator_name default_domain

set:
	echo '{ "variables":{ "domain_name":"test.current.engines" }} ' | engines_tool service smtp configuration run default_domain  |engines_test_expects bool true