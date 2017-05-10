SUBDIRS= certs config keys control domains metrics reserved system_status template version 
#do_first_run

tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir); echo $(dir); make -s tests; cd ..;)
	