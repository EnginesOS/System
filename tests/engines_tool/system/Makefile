SUBDIRS=do_first_run certs config control domains metrics reserved system_status template version 

tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir); echo $(dir); make -s tests; cd ..;)
	