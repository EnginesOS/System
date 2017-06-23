TESTS=restart recreate

tests:
	echo \033[0;31m Registry tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
restart:
	system_service.rb registry restart 
	 #engines system control registry restart  | engines_test_expects bool true
	 
recreate:
	system_service.rb registry stop
	system_service.rb registry destroy
	system_service.rb registry create  | engines_test_expects bool true
	system_service.rb registry start  | engines_test_expects bool true