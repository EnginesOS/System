TESTS=update locale timezone
#restart shutdown

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
		
update:
	engines system control base_os update | engines_test_expects bool true	
	
restart:
	engines system control base_os restart | engines_test_expects bool true

shutdown:
	engines system control base_os shutdown test | engines_test_expects bool true
	
locale:
	engines system control base_os set locale AU en
	engines system control base_os locale | engines_test_expects json country_code AU
	engines system control base_os set locale US en
	engines system control base_os locale | engines_test_expects json country_code US
	engines system control base_os set locale AU en
	
timezone:
	engines system control base_os set timezone Australia/Sydney 
	engines system control base_os timezone | engines_test_expects text Australia/Sydney
	engines system control base_os set timezone US/Eastern
	engines system control base_os timezone | engines_test_expects text US/Eastern
	engines system control base_os set timezone Australia/Sydney 