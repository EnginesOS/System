TESTS=restart recreate

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
restart:
	 engines_tool system control registry restart  | engines_test_expects bool true
	 
recreate:
	engines_tool system control registry recreate  | engines_test_expects bool true