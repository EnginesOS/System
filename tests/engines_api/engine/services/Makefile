TESTS=persistent_services non_persistent_services 

tests:
	@$(foreach dir,$(TESTS),  echo  $(dir):;cd $(dir);echo  $(dir):; make -s tests; cd ..;)




