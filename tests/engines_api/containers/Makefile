TESTS=check_and_act

tests:
	echo -n "\033[0;34m Container tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)


check_and_act:
	engines containers check_and_act | engines_test_expects json mysqld