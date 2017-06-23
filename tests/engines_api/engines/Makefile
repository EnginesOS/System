TESTS=engines state container_name  builder

tests:
	echo -n "\033[0;31m Engines tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
engines:
	engines engines |engines_test_expects json
	
state:
	engines engines state|engines_test_expects json
	
container_name:
	engines engines container_name |engines_test_expects json
	
build_plain:
	cat build_test_engine_minimum_args.json  | engines engines build  |engines_test_expects bool true
	make build_check
	
builder:
	echo -n :build_plain
	make build_plain
	echo -n :build_gui
	make build_gui
	make clean
	
	#build_orphan
	#build_existing
	
build_gui:	
	cat build_test_engine_plain_gui_args.json | engines engines build  |engines_test_expects bool true
	make build_check
	
build_check:
	echo -n build check
	engines engine_builder status |engines_test_expects json is_building true
	engines engine_builder params |engines_test_expects json 
	echo -n :follow
	engines engine_builder follow >/tmp/test_bld.out
	 grep "Build Successful" /tmp/test_bld.out |engines_test_expects  regex "*Build Successful*"
	echo -n :last build Params
	engines engine_builder last_build params  |engines_test_expects json
	echo -n :last build log
	engines engine_builder last_build log  >/tmp/test_bld.out
	grep "Build Successful"  /tmp/test_bld.out | engines_test_expects regex "*Build Successful*"
	
clean:
	engines engine testengine stop
	engines engine testengine wait_for stop 20
	engines engine testengine destroy
	engines engine testengine wait_for destroy 30
	engines engine testengine delete all
	