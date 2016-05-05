TESTS=status first_run_required

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
status:
	@engines_tool system status |engines_test_expects json is_rebooting false
	
first_run_required:
	 @engines_tool system status first_run_required |engines_test_expects bool
