TESTS=hosted_dns selfhosted_dns dyndns zeroconf external

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
hosted_dns:
	#clear_first_ran
	#rm ca
	external_ip_self_hosted_dns.json | engines system do_first_run | engines_test_expects bool true

selfhosted_dns:
	cat internal_ip_self_hosted_dns.json | engines system do_first_run | engines_test_expects bool true
	
dyndns:
	cat dyndns.json | engines system do_first_run | engines_test_expects bool true
	
zero_conf:
	cat zeroconf.json  | engines system do_first_run | engines_test_expects bool true
	
external:
	cat externally_hosted_dns.json | engines system do_first_run | engines_test_expects bool true