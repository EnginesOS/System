SUBDIRS=system engines engine containers services service engine_builder registry service_manager

tests:
	make -ks clear_last
	@$(foreach dir,$(SUBDIRS), cd $(dir);echo  $(dir):; make -s tests; cd ..;)
	
clear_last:
	engines_tool engine testengine stop
	engines_tool engine testengine destroy
	engines_tool engine testengine delete none
	engines_tool service smtp stop
	engines_tool service smtp destroy
	engines_tool service imap stop
	engines_tool service imap destroy