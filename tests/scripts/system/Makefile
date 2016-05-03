SUBDIRS=do_first_run certs config control domains metrics reserved system_status template version 

tests:
	for dir in $$SUBDIRS ; do\
		cd $$dir ; make tests;\
	done