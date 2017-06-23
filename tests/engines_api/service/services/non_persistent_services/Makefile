TESTS=non_persistent_services non_persistent_services_type service_non_persistent\
	service_non_persistent_deregister service_non_persistent_register service_non_persistent_reregister

tests:
	echo \033[0;31m Service No Persistent Services tests \033[0;30m
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
non_persistent_services:
	engines service email services non_persistent | engines_test_expects array


non_persistent_services_type:
	engines service email services non_persistent EnginesSystem | engines_test_expects array


service_non_persistent:
	engines service email service non_persistent EnginesSystem dns email | engines_test_expects json  service_handle email 

service_non_persistent_deregister:
	engines service nginx service non_persistent deregister EnginesSystem dns nginx|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer nginx nginx |engines_test_expects  json error_object 

service_non_persistent_register:
	engines service nginx service non_persistent register EnginesSystem dns nginx|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer nginx nginx |engines_test_expects  json type_path dns
	

service_non_persistent_reregister:
	engines service nginx service non_persistent reregister EnginesSystem dns nginx|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer nginx nginx |engines_test_expects  json type_path dns