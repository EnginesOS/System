TESTS=services state  system container_name

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
services:
	engines_tool services |engines_test_expects array
	
state:
	engines_tool services state|engines_test_expects array
	
container_name:
	engines_tool services container_name |engines_test_expects array
	
system:
	engines_tool services system  |engines_test_expects array