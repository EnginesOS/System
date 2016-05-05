TESTS=update restart recreate

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
update:
	engines_tool system control engines_system update | engines_test_expects bool
	
restart:
	engines_tool system control engines_system restart | engines_test_expects bool true
	
recreate:
	engines_tool system control engines_system recreate | engines_test_expects bool true