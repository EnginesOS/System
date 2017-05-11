TESTS=status first_run_required system_update_status

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
status:
	engines system status |engines_test_expects json is_rebooting false
	
first_run_required:
	 engines system status first_run_required |engines_test_expects bool
	 
system_update_status:
	engines system status update  |engines_test_expects json needs_engines_update 
