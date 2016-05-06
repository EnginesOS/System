TESTS=list view set_default default remove add system_ca 

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
list:
	engines_tool system certs  | engines_test_expects array engines
	
view:
	engines_tool system cert engines | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"
	
add:
	engines_tool system add testingcert.com testcert.crt testkey.key | engines_test_expects bool true	
	echo -n " Checking:"
	engines_tool system cert testingcert.com | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"
	
		
set_default:
	engines_tool system certs default testcert.crt testkey.key  | engines_test_expects bool true	
	
default:
	engines_tool system cert default | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"
	
remove:
	engines_tool system certs remove testingcert.com  | engines_test_expects bool true	
		echo -n " Checking:"
		engines_tool system cert testingcert.com | engines_test_expects text null

system_ca:
	engines_tool system cert system_ca | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"

	