TESTS=actions action action_perform 

tests:
	echo \033[0;31m Service Action tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

	
actions:
	engines service email actions | engines_test_expects json list_addresses
	
action:
	engines  service email action list_addresses  | engines_test_expects json name list_addresses

action_perform:
	echo ""| engines service email action perform list_addresses  | engines_test_expects test "@"
 	
