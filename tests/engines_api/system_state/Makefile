TESTS=running
SERVICES=dns nginx cron cert_auth auth mysql_server

tests:
	echo -n "\033[0;31m System State tests \033[0;30m"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
		
	
running:
	$(foreach service,$(SERVICES), echo -n $(service):; engines service $(service) status | engines_test_expects json state running)
	