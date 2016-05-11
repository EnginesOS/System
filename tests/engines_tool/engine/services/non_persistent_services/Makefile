TESTS=non_persistent_services non_persistent_services_type service_non_persistent\
	service_non_persistent_deregister service_non_persistent_register service_non_persistent_reregister

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
non_persistent_services:
	engines_tool engine testengine services non_persistent | engines_test_expects array


non_persistent_services_type:
	engines_tool engine testengine services non_persistent EnginesSystem | engines_test_expects array


service_non_persistent:
	engines_tool engine testengine service non_persistent EnginesSystem dns testengine | engines_test_expects json  service_handle testengine 

service_non_persistent_deregister:
	engines_tool engine testengine service non_persistent deregister EnginesSystem dns testengine|engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns consumer testengine testengine |engines_test_expects  json error_object 
	
service_non_persistent_register:
	engines_tool engine testengine service non_persistent register EnginesSystem dns testengine|engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns consumer testengine testengine |engines_test_expects  json type_path dns

service_non_persistent_reregister:
	engines_tool engine testengine service non_persistent reregister EnginesSystem dns testengine|engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns consumer testengine testengine |engines_test_expects  json type_path dns

"