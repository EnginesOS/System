SUBDIRS=system engines engine containers services service engine_builder registry service_manager
ENGINES=markengine phppgadmin
tests:
	echo -n "\033[0;34m System State tests \033[0;30m\n"
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
	
clear_last:
	make -ks clear_services
	make -ks clear_engines
	
clear_engines:
	echo -n "\033[0;34m Clean engines test \033[0;30m\n"
	@$(foreach engine,$(ENGINES),\
	engines engine $(engine) stop &>/dev/null;\
	engines engine $(engine) wait_for stop 45 &>/dev/null;\
	engines engine $(engine) destroy &>/dev/null;\
	engines engine $(engine) wait_for destroy 15 &>/dev/null;\
	engines engine $(engine) delete none&>/dev/null ;)

clear_services:
	echo -n "\033[0;34m Clean services test \033[0;30m\n"
	engines service email stop &>/dev/null
	engines service email wait_for stop 45
	engines service email destroy &>/dev/null
	engines service imap stop &>/dev/null
	engines service email wait_for stop 45
	engines service imap destroy &>/dev/null
