TESTS=

tests:
	$(foreach test,$(TESTS),  make $(test);)
	
release:
	engines_tool system version release |engines_test_expects text current