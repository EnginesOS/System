TESTS=prepare state stop start pause unpause engine status blueprint websites logs ps template mem_stat net_stat\
	blueprint build_report properties_net properties_run\
	actions services \
	halt start restart create recreate destroy reinstall delete 
 
	
tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

actions:
	cd actions ; make -s tests ; cd ..

services:	
	cd services ; make -s tests ; cd ..


cron:	
	cd cron ; make -s tests ; cd ..
	
prepare:
	cat build_test_engine_minimum_args.json  | engines engines build  |engines_test_expects bool true
	engines engine_builder follow >/tmp/test_bld.out
	engines engine testengine wait_for_startup 180

state:
	engines engine testengine state |engines_test_expects text is running
	
stop:
	engines engine testengine stop  |engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	
start:
	engines engine testengine start | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for start 34| engines_test_expects  bool true
	
restart:
	engines engine testengine restart | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for start 34 | engines_test_expects  bool true
		
pause:
	engines engine testengine pause | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for pause 20 | engines_test_expects  bool true
	
unpause:
	engines engine testengine unpause | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for unpause 20  | engines_test_expects  bool true
	
template:
	engines engine testengine template '_Engines_Builder(engine_name)' | engines_test_expects text is testengine
	
mem_stat:
	engines engine testengine mem_stat | engines_test_expects json maximum
	
net_stat:
	engines engine testengine net_stat | engines_test_expects json in
	

		
build_report:
	engines engine testengine build_report | engines_test_expects regex '.*testengine.*'
	

properties_net:
	cat network_properties.json | engines engine testengine properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine websites  | engines_test_expects regex '.*newemail.test.com.au.*'

properties_run:
	make properties_memory
	make properties_env
	
properties_memory:
	engines engine testengine stop | engines_test_expects bool true
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	cat runtime_properties_memory.json | engines engine testengine properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for start 40  | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine   | engines_test_expects json memory 177
	engines engine testengine stop | engines_test_expects bool true
	cat revert_runtime_properties_memory.json | engines engine testengine properties runtime | engines_test_expects bool true
	
properties_env:
	engines engine testengine stop | engines_test_expects bool true
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	cat runtime_properties_env.json | engines engine testengine properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state  | engines_test_expects text is running
	echo -n " Checking:"
	engines engine testengine   | engines_test_expects text valuewer32342342

destroy:
	engines engine testengine stop  | engines_test_expects bool true
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	engines engine testengine destroy  | engines_test_expects bool true
	engines engine testengine wait_for destroy 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is nocontainer

create:
	engines engine testengine stop  | engines_test_expects bool true
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	engines engine testengine destroy  | engines_test_expects bool true
	engines engine testengine wait_for destroy 20 | engines_test_expects bool true
	engines engine testengine create  | engines_test_expects bool true
	engines engine testengine wait_for start 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
recreate:
	engines engine testengine stop | engines_test_expects bool true
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	engines engine testengine recreate | engines_test_expects bool true
	engines engine testengine wait_for start 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
reinstall:
	engines engine testengine reinstall | engines_test_expects bool true
	engines engine testengine wait_for start 120 | engines_test_expects bool true	
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects text is running
	
engine:
	engines engine testengine | engines_test_expects json memory
	
status:
	engines engine testengine status | engines_test_expects json state
	
blueprint:
	 engines engine testengine blueprint| engines_test_expects json schema

websites:
	 engines engine testengine websites | engines_test_expects regex ".*http.*"

logs:
	engines engine testengine logs | engines_test_expects json stderr

ps:
	engines engine testengine ps | engines_test_expects json Processes
	
halt:
	engines engine testengine halt | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	engines engine testengine status | engines_test_expects json state stopped
	engines engine testengine status | engines_test_expects json set_state running
	
delete:
	engines engine testengine stop  | engines_test_expects bool true
	engines engine testengine wait_for stop 20 | engines_test_expects bool true
	engines engine testengine destroy  | engines_test_expects bool true
	engines engine testengine wait_for destroy 20 | engines_test_expects bool true
	engines engine testengine delete none | engines_test_expects bool true
	echo -n " Checking:"
	engines engine testengine state | engines_test_expects json error_object,error_mesg
	
clean:
	engines engine testengine stop
	engines engine testengine wait_for stop 15
	engines engine testengine destroy
	engines engine testengine wait_for destroy 10
	engines engine testengine delete all