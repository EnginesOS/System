TESTS=memory load mem_stats disk

tests:	
	$(foreach test,$(TESTS), echo -n $(test); make $(test);)
	
memory:
	engines_tool system metrics memory|engines_test_expects json total
	
load:
	engines_tool system metrics load|engines_test_expects text_len gt 1
	
mem_stats:
	engines_tool system metrics mem_stats |engines_test_expects json containers

disk:
	engines_tool system metrics disk |engines_test_expects json