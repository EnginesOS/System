TESTS=list view set_default default add remove  system_ca generate 

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
list:
	engines system certs  | engines_test_expects json
	
view:
	engines system certs engines | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"
	
add:
	engines system certs add testingcert.com testcert.crt testkey.key | engines_test_expects bool true	
	echo -n " Checking:"
	engines system cert testingcert.com | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"
	
		
set_default:
	engines system certs default defaultdomain.com testcert.crt testkey.key  | engines_test_expects bool true	
	
default:
	engines system cert default | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"
	
remove:
	engines system certs remove testingcert.com  | engines_test_expects bool true	
		echo -n " Checking:"
		engines system certs testingcert.com | engines_test_expects json error_object

system_ca:
	engines system cert system_ca | engines_test_expects regex "[-].*BEGIN CERTIFICATE*"

generate:
	cat test_generate.json | engines system certs generate