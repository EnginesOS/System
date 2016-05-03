SUBDIRS=system engines engine containers services service engine_builder registry service_manager

tests:
	for dir in $$SUBDIRS ; do\
		cd $$dir ; make tests;\
	done