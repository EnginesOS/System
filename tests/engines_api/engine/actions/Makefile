TESTS=prepare actions action action_perform clean_up

tests:
	echo \033[0;31m Engine Action tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
prepare:
	cat prosody_build_params.json | engines engines build
	engines engine_builder follow >/dev/null
	
actions:
	engines engine prosody actions | engines_test_expects json list_users
	
action:
	engines engine prosody action list_users | engines_test_expects json name list_users

action_perform:
	echo '{"username":"test","password":"pass"}' | engines engine prosody action perform add_user  | engines_test_expects text "Successfully added test"
 	
clean_up:
	engines engine prosody stop 
	engines engine prosody destroy 
	engines engine prosody delete all
