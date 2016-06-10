TESTS=engines state container_name  builder

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
engines:
	engines_tool engines |engines_test_expects json
	
state:
	engines_tool engines state|engines_test_expects json
	
container_name:
	engines_tool engines container_name |engines_test_expects json
	
build_plain:
	cat build_test_engine_minimum_args.json  | engines_tool engines build  |engines_test_expects bool true
	make build_check
	
builder:
	echo -n :build_plain
	make build_plain
	echo -n :build_gui
	make build_gui
	
	#build_orphan
	#build_existing
	
build_gui:	
	cat build_test_engine_plain_gui_args.json | engines_tool engines build  |engines_test_expects bool true
	make build_check
	
build_check:
	echo -n build check
	engines_tool engine_builder status |engines_test_expects json is_building true
	echo -n :follow
	engines_tool engine_builder follow |engines_test_expects  regex "*Build Successful*"
	echo -n :last build Params
	engines_tool engine_builder last_build params  |engines_test_expects json
	echo -n :last build log
	engines_tool engine_builder last_build log  | engines_test_expects regex "*Build Successful*"
	

	