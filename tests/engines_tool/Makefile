SUBDIRS=system engines engine containers services service engine_builder registry service_manager
ENGINES=selfoss testengine
tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
	
clear_last:
	make -ks clear_services
	make -ks clear_engines
	
clear_engines:
	@$(foreach engine,$(ENGINES),\
	engines_tool engine $(engine) stop | engines_test_expects bool true;\
	engines_tool engine $(engine) destroy | engines_test_expects  bool true;\
	engines_tool engine $(engine) delete none | engines_test_expects  bool true;)

clear_services:
	engines_tool service email stop | engines_test_expects  bool true
	engines_tool service email destroy | engines_test_expects  bool true
	engines_tool service imap stop | engines_test_expects  bool true
	engines_tool service imap destroy | engines_test_expects  bool true