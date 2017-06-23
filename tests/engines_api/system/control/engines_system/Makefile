TESTS= heap_dump dump_threads
#update restart recreate
tests:
	echo \033[0;31m Engines system tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
update:
	engines system control engines_system update | engines_test_expects bool
	
restart:
	engines system control engines_system restart | engines_test_expects bool true
	system_service.rb system wait_for_startup 90 | engines_test_expects bool true
	engines system status |engines_test_expects json is_rebooting false
	
recreate:
	engines system control engines_system recreate | engines_test_expects bool true
	system_service.rb system wait_for_startup 90 | engines_test_expects bool true
	engines system status |engines_test_expects json is_rebooting false
	
heap_dump:
	#if test -f /opt/engines/run/system_services/system/run/heap.dump ;\
	# then \
	#    rm /opt/engines/run/system_services/system/run/heap.dump;\
	#  fi
	engines system control engines_system heap_stats | engines_test_expects bool true
	#ls /opt/engines/run/system_services/system/run/heap.dump | engines_test_expects text /opt/engines/run/system_services/system/run/heap.dump
	
dump_threads:
		engines system control engines_system dump_threads | engines_test_expects regex ".*Thread.*"