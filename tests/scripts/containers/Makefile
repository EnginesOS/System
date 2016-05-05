TESTS=changed

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

	
changed:
	engines_tool changed