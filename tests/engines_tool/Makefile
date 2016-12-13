SUBDIRS=system engines engine containers services service engine_builder registry service_manager
ENGINES=plainguitest testengine
tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
	
clear_last:
	make -ks clear_services
	make -ks clear_engines
	
clear_engines:
	@$(foreach engine,$(ENGINES),\
	engines engine $(engine) stop | engines_test_expects bool true;\
	engines engine $(engine) destroy | engines_test_expects  bool true;\
	engines engine $(engine) delete none | engines_test_expects  bool true;)

clear_services:
	engines service email stop | engines_test_expects  bool true
	engines service email destroy | engines_test_expects  bool true
	engines service imap stop | engines_test_expects  bool true
	engines service imap destroy | engines_test_expects  bool true