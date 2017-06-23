SUBDIRS=system engines engine containers services service engine_builder registry service_manager
ENGINES=plainguitest testengine
tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
	
clear_last:
	make -ks clear_services
	make -ks clear_engines
	
clear_engines:
	echo "\033[0;31m Clean engines test \033[0;30m"
	@$(foreach engine,$(ENGINES),\
	engines engine $(engine) stop &>/dev/null;\
	engines engine $(engine) destroy &>/dev/null;\
	engines engine $(engine) delete none&>/dev/null ;)

clear_services:
	echo "\033[0;31m Clean services test \033[0;30m"
	engines service email stop &>/dev/null
	engines service email destroy &>/dev/null
	engines service imap stop &>/dev/null
	engines service imap destroy &>/dev/null