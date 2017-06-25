TESTS=non_persistent_services non_persistent_services_type service_non_persistent\
	service_non_persistent_deregister service_non_persistent_register service_non_persistent_reregister

tests:
	echo -n "\033[0;31m Engines Non Persistent Services tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
non_persistent_services:
	engines engine enginetest services non_persistent | engines_test_expects array


non_persistent_services_type:
	engines engine enginetest services non_persistent EnginesSystem | engines_test_expects array


service_non_persistent:
	engines engine enginetest service non_persistent EnginesSystem dns enginetest | engines_test_expects json  service_handle enginetest 

service_non_persistent_deregister:
	engines engine enginetest service non_persistent deregister EnginesSystem dns enginetest|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer enginetest enginetest |engines_test_expects  json error_object 
	
service_non_persistent_register:
	engines engine enginetest service non_persistent register EnginesSystem dns enginetest|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer enginetest enginetest |engines_test_expects  json type_path dns

service_non_persistent_reregister:
	engines engine enginetest service non_persistent reregister EnginesSystem dns enginetest|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer enginetest enginetest |engines_test_expects  json type_path dns

service_non_persistent_add:
	cat add_non_persistent_service.json | engines engine enginetest services non_persistent add EnginesSystem dns |engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer enginetest  testservice |engines_test_expects  json type_path dns
	
service_non_persistent_edit:
	cat edit_persistent_service.json |engines engine enginetest service non_persistent modify EnginesSystem dns testservice|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer enginetest  testservice 
	
service_non_persistent_del:
	engines engine enginetest services non_persistent del EnginesSystem dns testservice|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer enginetest  testservice |engines_test_expects bool false