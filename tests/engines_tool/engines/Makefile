TESTS=engines state container_name build builder

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
engines:
	engines_tool engines |engines_test_expects array
	
state:
	engines_tool engines state|engines_test_expects json
	
container_name:
	engines_tool engines container_name |engines_test_expects array
	
build:
	cat build_test_engine.json | engines_tool engines build  |engines_test_expects bool true
	
builder:
	engines_tool engine_builder status |engines_test_expects json is_building true
	engines_tool engine_builder follow |engines_test_expects  regex "*Build Finished*"
	engines_tool engine_builder last_build params  |engines_test_expects json
	engines_tool engine_builder last_build log  | engines_test_expects regex "*Build Finished*"