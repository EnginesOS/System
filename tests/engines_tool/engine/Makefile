TESTS=state stop start pause unpause  template mem_stat net_stat\
	blueprint build_report properties_net properties_run\
	actions services \
	 destroy recreate reinstall delete

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

actions:
	cd actions ; make -s tests ; cd ..

services:	
	cd services ; make -s tests ; cd ..

state:
	engines_tool engine installtest state 	|engines_test_expects text is running
	
stop:
	engines_tool engine installtest stop  |engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is stopped
	
start:
	engines_tool engine installtest start | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is running
	
pause:
	engines_tool engine installtest pause | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is paused
	
unpause:
	engines_tool engine installtest unpause | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is running
	
template:
	engines_tool engine testengine template '_Engines_Builder(engine_name)' | engines_test_expects text is testengine
	
mem_stat:
	engines_tool engine installtest mem_stat | engines_test_expects json maximum
	
net_stat:
	engines_tool engine installtest net_stat | engines_test_expects json in
	
	
blueprint:
	engines_tool engine installtest blueprint | engines_test_expects json software
		
build_report:
	engines_tool engine installtest build_report | engines_test_expects text built
	

properties_net:
	engines_tool engine installtest stop | engines_test_expects bool true
	cat network_properties.json | engines_tool engine installtest properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state  | engines_test_expects text is running

properties_run:
	make properties_memory
	make properties_env
	
properties_memory:
	engines_tool engine installtest stop | engines_test_expects bool true
	cat runtime_properties_memory.json | engines_tool engine installtest properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state  | engines_test_expects text is running
	echo -n " Checking:"
	engines_tool engine installtest state  | engines_test_expects text 577
	engines_tool engine installtest stop | engines_test_expects bool true
	cat revert_runtime_properties_memory.json | engines_tool engine installtest properties runtime | engines_test_expects bool true
	
properties_env:
	engines_tool engine installtest stop | engines_test_expects bool true
	cat runtime_properties_env.json | engines_tool engine installtest properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state  | engines_test_expects text is running
	echo -n " Checking:"
	engines_tool engine installtest   | engines_test_expects text valuewer32342342

destroy:
	engines_tool engine installtest stop  | engines_test_expects bool true
	engines_tool engine installtest destroy  | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is nocontainer
	
recreate:
	engines_tool engine installtest recreate | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is running
	
reinstall:
	engines_tool engine installtest stop  | engines_test_expects bool true
	engines_tool engine installtest destroy  | engines_test_expects bool true
	engines_tool engine installtest reinstall | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects text is running
	
delete:
	engines_tool engine installtest stop  | engines_test_expects bool true
	engines_tool engine installtest destroy  | engines_test_expects bool true
	engines_tool engine installtest delete none | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine installtest state | engines_test_expects json error_object,error_mesg