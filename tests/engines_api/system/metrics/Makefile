TESTS=memory load mem_stats disk

tests:
	echo -n "\033[0;31m Metrics tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
memory:
	engines system metrics memory|engines_test_expects json total
	
load:
	engines system metrics load|engines_test_expects text_len gt 1
	
mem_stats:
	engines system metrics mem_stats |engines_test_expects json containers

disk:
	engines system metrics disks |engines_test_expects json
	
network:
	engines system metrics network|engines_test_expects json