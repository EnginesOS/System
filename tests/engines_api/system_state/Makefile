TESTS=running
SERVICES=dns wap cron certs auth mysqld

tests:
	echo -n "\033[0;34m System State tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
		
	
running:
	$(foreach service,$(SERVICES), echo -n $(service):; engines service $(service) status | engines_test_expects json state running)
	