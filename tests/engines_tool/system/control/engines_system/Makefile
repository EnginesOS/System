TESTS=update restart recreate

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
update:
	engines system control engines_system update | engines_test_expects bool
	
restart:
	engines system control engines_system restart | engines_test_expects bool true
	sleep 120
	engines system status |engines_test_expects json is_rebooting false
	
recreate:
	engines system control engines_system recreate | engines_test_expects bool true
	sleep 120
	engines system status |engines_test_expects json is_rebooting false