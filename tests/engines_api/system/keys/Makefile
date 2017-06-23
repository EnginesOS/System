SUBDIRS=user
#base_os engines_system registry

tests:
	echo \033[0;31m Key tests \033[0;30m
	@$(foreach dir,$(SUBDIRS), cd $(dir); echo $(dir); make -s tests; cd ..;)
	
