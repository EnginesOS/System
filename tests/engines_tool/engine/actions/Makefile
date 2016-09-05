TESTS=prepare actions action action_perform clean_up

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
prepare:
	cat prosody_build_params.json | engines_tool engines build
	engines engine_builder follow >/dev/null
	
actions:
	engines_tool engine prosody actions | engines_test_expects json list_users
	
action:
	engines_tool engine prosody action list_users | engines_test_expects json name list_users

action_perform:
	echo '{"username":"test","password":"pass"}' | engines_tool engine prosody action perform add_user  | engines_test_expects test "Successfully added test"
 	
clean_up:
	engines_tool engine prosody stop 
	engines_tool engine prosody destroy 
	engines_tool engine prosody delete all
