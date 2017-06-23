TESTS=persistent_services non_persistent_services 

tests:
	echo -n "\033[0;31m Engines Services tests \033[0;30m\n"
	@$(foreach dir,$(TESTS),  echo  $(dir):;cd $(dir);echo  $(dir):; make -s tests; cd ..;)




