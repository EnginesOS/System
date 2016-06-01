TESTS=orphans
tests:
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
