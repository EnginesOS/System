SUBDIRS=persistent_services non_persistent_services 

tests:
	echo -n "\033[0;31m Service Services tests \033[0;30m"
	@$(foreach dir,$(SUBDIRS),  echo  $(dir):;cd $(dir);echo  $(dir):; make -s tests; cd ..;)




