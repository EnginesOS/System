TESTS=delete_engine_and_orphanate delete_orphan use_orphan
#use_orphan pickup_orphan

tests:
	echo -n "\033[0;31m Orphans tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
clear_testengine:
	engines engine testengine stop >/dev/null
	engines engine testengine destroy >/dev/null
	engines engine testengine delete all >/dev/null
	
delete_engine_and_orphanate:
	make -k clear_testengine
	cd ../../engines
	make -k build_plain
	cd ../service_manager/orphans
	engines engine testengine stop >/dev/null
	engines engine testengine destroy >/dev/null
	engines engine testengine delete none
	engines service_manager orphan EnginesSystem filesystem/local/filesystem testengine testengine | engines_test_expects json
	
delete_orphan:
	engines service_manager orphan delete EnginesSystem filesystem/local/filesystem testengine testengine | engines_test_expects bool true
	
use_orphan:
	make  delete_engine_and_orphanate
	cat build_test_engine_with_orphan.json | engines engines build  
	make -f ../../engines/Makefile build_check
	make -k clear
	
clear:
	engines engine orphanengine stop >/dev/null
	engines engine orphanengine destroy >/dev/null
	engines engine orphanengine delete all  >/dev/null
	