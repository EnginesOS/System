TESTS=non_persistent_services non_persistent_services_type service_non_persistent\
	service_non_persistent_deregister service_non_persistent_register service_non_persistent_reregister

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
	
non_persistent_services:
	engines_tool service email services non_persistent | engines_test_expects array


non_persistent_services_type:
	engines_tool service email services non_persistent EnginesSystem | engines_test_expects array


service_non_persistent:
	engines_tool service email service non_persistent EnginesSystem dns email | engines_test_expects json  service_handle email 

service_non_persistent_deregister:


service_non_persistent_register:


service_non_persistent_reregister:
