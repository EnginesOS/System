SUBDIRS=system engines engine containers services service engine_builder registry service_manager

tests:
	$(foreach dir,$(SUBDIRS), cd $(dir); make tests; cd ..;)
	