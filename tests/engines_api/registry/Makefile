TESTS=configurations engines services orphans shares

tests:
	echo \033[0;31m Registry tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
configurations:
	engines registry configurations | engines_test_expects json
	
engines:
	engines registry engines | engines_test_expects json
	


services:
	engines registry services | engines_test_expects json


orphans:
	engines registry orphans | engines_test_expects json
	
	
shares:
	engines registry shares  | engines_test_expects json