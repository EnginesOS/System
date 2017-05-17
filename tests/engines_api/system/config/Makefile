TESTS=set_default_domain default_domain set_hostname hostname set_default_site default_site remote_exception_logging

tests:
	#host=`hostname`
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
set_default_domain:
	engines system config set default_domain testdomain.com | engines_test_expects bool true	

default_domain:
	engines system config default_domain | engines_test_expects text testdomain.com

set_hostname:
	engines system config set hostname testhost | engines_test_expects bool true	

hostname:
	engines system config  hostname testhost | engines_test_expects text testhost
	#engines system config set host $host | engines_test_expects bool true

set_default_site:
	engines system config set default_site mysite.com.au | engines_test_expects bool true	

default_site:
	engines system config default_site | engines_test_expects text mysite.com.au

remote_exception_logging:
	 engines system config remote_exception_logging | engines_test_expects bool 	
	 
set_remote_exception_logging:	 
	 engines system config remote_exception_logging disable | engines_test_expects bool true
	 echo -n ' verify setting"
	 engines system config remote_exception_logging | engines_test_expects bool false	
	  engines system config remote_exception_logging enable | engines_test_expects bool true
	 echo -n ' verify setting"
	 engines system config remote_exception_logging | engines_test_expects bool true	