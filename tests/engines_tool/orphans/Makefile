TESTS=delete_engine_and_orphanate delete_orphan 
#use_orphan pickup_orphan

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
delete_engine_and_orphanate:
	cd ../../engines
	engines engine testengine stop >/dev/null
	engines engine testengine destroy >/dev/null
	engines engine testengine delete all >/dev/null
	make -k build_plain
	cd ../service_manager/orphans
	engines engine testengine stop >/dev/null
	engines engine testengine destroy >/dev/null
	engines engine testengine delete none
	engines service_manager orphan EnginesSystem filesystem/local/filesystem testengine testengine | engines_test_expects json
	
delete_orphan:
	engines service_manager orphan delete EnginesSystem filesystem/local/filesystem testengine testengine | engines_test_expects bool true
	
use_orphan:
	make -ks delete_engine_and_orphanate
	