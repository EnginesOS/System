TESTS=state stop start pause unpause  template mem_stat net_stat\
	blueprint build_report properties_net properties_run\
	actions services \
	 destroy recreate delete reinstall 
 
	
tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

actions:
	cd actions ; make -s tests ; cd ..

services:	
	cd services ; make -s tests ; cd ..

state:
	engines engine testengine state 	|engines_test_expects text is running
	
stop:
	engines engine testengine stop  |engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is stopped
	
start:
	engines engine testengine start | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
pause:
	engines engine testengine pause | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is paused
	
unpause:
	engines engine testengine unpause | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
template:
	engines engine testengine template '_Engines_Builder(engine_name)' | engines_test_expects text is testengine
	
mem_stat:
	engines engine testengine mem_stat | engines_test_expects json maximum
	
net_stat:
	engines engine testengine net_stat | engines_test_expects json in
	
	
blueprint:
	engines engine testengine blueprint | engines_test_expects json software
		
build_report:
	engines engine testengine build_report | engines_test_expects text built
	

properties_net:
	engines engine testengine stop | engines_test_expects bool true
	cat network_properties.json | engines engine testengine properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state  | engines_test_expects text is running

properties_run:
	make properties_memory
	make properties_env
	
properties_memory:
	engines engine testengine stop | engines_test_expects bool true
	cat runtime_properties_memory.json | engines engine testengine properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state  | engines_test_expects text is running
	echo -n " Checking:"
	engines engine testengine state  | engines_test_expects text 577
	engines engine testengine stop | engines_test_expects bool true
	cat revert_runtime_properties_memory.json | engines engine testengine properties runtime | engines_test_expects bool true
	
properties_env:
	engines engine testengine stop | engines_test_expects bool true
	cat runtime_properties_env.json | engines engine testengine properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state  | engines_test_expects text is running
	echo -n " Checking:"
	engines engine testengine   | engines_test_expects text valuewer32342342

destroy:
	engines engine testengine stop  | engines_test_expects bool true
	engines engine testengine destroy  | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is nocontainer
	
recreate:
	engines engine testengine recreate | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
reinstall:
	engines engine testengine stop  | engines_test_expects bool true
	engines engine testengine destroy  | engines_test_expects bool true
	engines engine testengine reinstall | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
delete:
	engines engine testengine stop  | engines_test_expects bool true
	engines engine testengine destroy  | engines_test_expects bool true
	engines engine testengine delete none | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects json error_object,error_mesg