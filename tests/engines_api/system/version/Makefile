TESTS=release api ident system base_os

tests:
	$(foreach test,$(TESTS),   echo -n $(test):; make -s $(test);)
	
release:
	engines system version release |engines_test_expects text is current
	
api:
	engines system version api  |engines_test_expects text is 0.3

ident:
	engines system version ident |engines_test_expects text is current-0.3-0.4
	
system:
	engines system version system|engines_test_expects text is 0.4
	
base_os:
	engines system version base_os|engines_test_expects json name Ubuntu