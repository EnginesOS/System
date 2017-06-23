SUBDIRS=base_os engines_system registry
#base_os engines_system registry

tests:
	echo -n "\033[0;31m Control tests \033[0;30m"
	@$(foreach dir,$(SUBDIRS), cd $(dir); echo $(dir); make -s tests; cd ..;)
	
