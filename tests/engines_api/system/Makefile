SUBDIRS= certs config keys control domains metrics reserved system_status template version 
#do_first_run

tests:
	echo \033[0;31m System tests \033[0;30m
	@$(foreach dir,$(SUBDIRS), cd $(dir); echo $(dir); make -s tests; cd ..;)
	