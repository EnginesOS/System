TESTS=changed

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

	
changed:
	engines containers changed | engines_test_expects json service