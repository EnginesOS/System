SUBDIRS=persistent_services non_persistent_services 

tests:
	echo -n "\033[0;34m Service Services tests \033[0;30m\n"
	@$(foreach dir,$(SUBDIRS),  echo  $(dir):;cd $(dir);echo  $(dir):; make -s tests; cd ..;)




