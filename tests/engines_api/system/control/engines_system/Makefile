TESTS=update restart recreate heap_dump dump_threads

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
update:
	engines system control engines_system update | engines_test_expects bool
	
restart:
	engines system control engines_system restart | engines_test_expects bool true
	sleep 120
	engines system status |engines_test_expects json is_rebooting false
	
recreate:
	engines system control engines_system recreate | engines_test_expects bool true
	sleep 120
	engines system status |engines_test_expects json is_rebooting false
	
heap_dump:
	rm /opt/engines/run/system_services/system/run/heap.dump
	engines system control engines_system heap_stats | engines_test_expects bool true
	ls /opt/engines/run/system_services/system/run/heap.dump | engines_test_expects text /opt/engines/run/system_services/system/run/heap.dump
	
dump_threads:
		engines system control engines_system dump_threads | engines_test_expects regex ".*Thread.*"