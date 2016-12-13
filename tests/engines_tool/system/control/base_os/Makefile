TESTS=update
#restart shutdown

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
	
update:
	engines system control base_os update | engines_test_expects bool true	
	
restart:
	engines system control base_os restart | engines_test_expects bool true

shutdown:
	engines system control base_os shutdown test | engines_test_expects bool true
	