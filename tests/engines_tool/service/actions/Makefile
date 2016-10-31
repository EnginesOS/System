TESTS=actions action action_perform 

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

	
actions:
	engines_tool service email actions | engines_test_expects json list_addresses
	
action:
	engines_tool  service email action list_addresses  | engines_test_expects json name list_addresses

action_perform:
	echo ""| engines_tool engine prosody action perform list_addresses  | engines_test_expects test "@"
 	
