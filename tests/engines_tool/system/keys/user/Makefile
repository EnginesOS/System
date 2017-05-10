TESTS=generate public upload 

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
generate:
	engines system keys user generate engines | engines_test_expects regex "^-----BEGIN RSA PRIVATE KEY-----.*-----END RSA PRIVATE KEY-----$"
	
upload:
	engines system keys user engines > /tmp/pubkey
	cat /tmp/pubkey 
	
public:
	engines system keys user engines| engines_test_expects regex "^ssh-rsa .*"
	