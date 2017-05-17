SUBDIRS=base_os engines_system registry
#base_os engines_system registry

tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir); echo $(dir); make -s tests; cd ..;)
	
