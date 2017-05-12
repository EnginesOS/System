TESTS=check_and_act

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)


check_and_act:
	engines containers check_and_act | engines_test_expects json mysql_server