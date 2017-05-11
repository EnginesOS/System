TESTS=non_persistent_services non_persistent_services_type service_non_persistent\
	service_non_persistent_deregister service_non_persistent_register service_non_persistent_reregister

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
non_persistent_services:
	engines engine testengine services non_persistent | engines_test_expects array


non_persistent_services_type:
	engines engine testengine services non_persistent EnginesSystem | engines_test_expects array


service_non_persistent:
	engines engine testengine service non_persistent EnginesSystem dns testengine | engines_test_expects json  service_handle testengine 

service_non_persistent_deregister:
	engines engine testengine service non_persistent deregister EnginesSystem dns testengine|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer testengine testengine |engines_test_expects  json error_object 
	
service_non_persistent_register:
	engines engine testengine service non_persistent register EnginesSystem dns testengine|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer testengine testengine |engines_test_expects  json type_path dns

service_non_persistent_reregister:
	engines engine testengine service non_persistent reregister EnginesSystem dns testengine|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer testengine testengine |engines_test_expects  json type_path dns

service_non_persistent_add:
	cat add_non_persistent_service.json | engines engine testengine services non_persistent add EnginesSystem dns |engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer testengine  testservice |engines_test_expects  json type_path dns
	
service_non_persistent_edit:
	cat edit_persistent_service.json |engines engine testengine service non_persistent modify EnginesSystem dns testservice|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer testengine  testservice 
	
service_non_persistent_del:
	engines engine testengine services non_persistent del EnginesSystem dns testservice|engines_test_expects bool true
	echo -n " Checking:"
	engines service dns consumer testengine  testservice |engines_test_expects bool false