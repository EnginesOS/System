TESTS=orphans
tests:
	echo -n "\033[0;34m Service Manager tests \033[0;30m\n"
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
