TESTS=engines state container_name build builder

tests:
	$(foreach test,$(TESTS),  make $(test);)
	
engines:
	engines_tool engines |engines_test_expects json_array
	
state:
	engines_tool engines state|engines_test_expects json_array
	
container_name:
	engines_tool engines container_name |engines_test_expects json_array
	
build:
	cat build_test.json | engines_tool engines build  |engines_test_expects boolean true
	
builder:
	engines_tool engines builder status |engines_test_expects json
	engines_tool engines builder follow |engines_test_expects text
	engines_tool engines builder last |engines_test_expects json