TESTS=orphans
tests:
	echo \033[0;31m Service Manager tests \033[0;30m
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
