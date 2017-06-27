TESTS=add list view update remove 

tests:
	echo -n "\033[0;31m Domain name tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
		
	
add:
	cat add_domain.json | engines system domains add | engines_test_expects bool true
	
list:
	engines system domains list | engines_test_expects json testdomain.com	
	
view:
	engines system domain view testdomain.com | engines_test_expects json domain_name testdomain.com

update:
	cat update_domain.json | engines system domain update testdomain.com | engines_test_expects bool true
	echo -n " Verify update:"
	engines system domains view testdomain.com | engines_test_expects json self_hosted true

remove:
	engines system domains remove testdomain.com | engines_test_expects bool true
	echo -n " Verify remove:"
	engines system domains view testdomain.com | engines_test_expects text '{}'

	
	
