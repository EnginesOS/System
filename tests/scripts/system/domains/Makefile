TESTS=add list view update remove 

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
		
	
add:
	cat add_domain.json | engines_tool system domains add | engines_test_expects bool true
	
list:
	engines_tool system domains list | engines_test_expects json testdomain.com
	
	
view:
	engines_tool system domain view testdomain.com | engines_test_expects json testdomain.com

update:
	cat update_domain.json | engines_tool system domain update | engines_test_expects bool true
	echo -n " Verify update:"
	engines_tool system domain view testdomain.com | engines_test_expects json testdomain.com

remove:
	engines_tool system domains remove testdomain.com | engines_test_expects bool true
	echo -n " Verify remove:"
	engines_tool system domain view testdomain.com | engines_test_expects text null

	
	
