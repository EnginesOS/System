TESTS=actions action action_perform 

tests:
	echo -n "\033[0;34m Service Action tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	

	
actions:
	engines service email actions/ | engines_test_expects json list_addresses
	
action:
	engines  service email action list_addresses  | engines_test_expects json name list_addresses

action_perform:
	echo ""| engines service email action perform list_addresses  | engines_test_expects test "@"
 	
