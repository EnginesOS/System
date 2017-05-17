TESTS=services state  system container_name

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
services:
	engines services |engines_test_expects array
	
state:
	engines services state|engines_test_expects json dns running
	
container_name:
	engines services container_name |engines_test_expects array dns
	
system:
	engines services system  |engines_test_expects array registry