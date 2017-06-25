TESTS=prepare state stop start pause unpause engine status blueprint websites logs ps template mem_stat net_stat\
	blueprint build_report properties_net properties_run\
	actions cron services \
	halt start restart create recreate destroy reinstall delete 
 
	
tests:
	echo -n "\033[0;31m Engine tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

actions:
	cd actions ; make -s tests ; cd ..

services:	
	cd services ; make -s tests ; cd ..


cron:	
	cd cron ; make -s tests ; cd ..
	
prepare:
	cat build_test_engine_minimum_args.json  | engines engines build  |engines_test_expects bool true
	engines engine_builder follow_stream >/tmp/test_bld.out
	engines engine enginetest wait_for_startup 180

state:
	engines engine enginetest state |engines_test_expects text is running
	
stop:
	engines engine enginetest stop  |engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	
start:
	engines engine enginetest start | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for start 34| engines_test_expects  bool true
	
restart:
	engines engine enginetest restart | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for start 34 | engines_test_expects  bool true
		
pause:
	engines engine enginetest pause | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for pause 20 | engines_test_expects  bool true
	
unpause:
	engines engine enginetest unpause | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for unpause 20  | engines_test_expects  bool true
	
template:
	engines engine enginetest template '_Engines_Builder(engine_name)' | engines_test_expects text is enginetest
	
mem_stat:
	engines engine enginetest mem_stat | engines_test_expects json maximum
	
net_stat:
	engines engine enginetest net_stat | engines_test_expects json in
	

		
build_report:
	engines engine enginetest build_report | engines_test_expects regex '.*enginetest.*'
	

properties_net:
	cat network_properties.json | engines engine enginetest properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest websites  | engines_test_expects regex '.*newemail.test.com.au.*'

properties_run:
	make properties_memory
	make properties_env
	
properties_memory:
	engines engine enginetest stop | engines_test_expects bool true
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	cat runtime_properties_memory.json | engines engine enginetest properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for start 40  | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest   | engines_test_expects json memory 177
	engines engine enginetest stop | engines_test_expects bool true
	cat revert_runtime_properties_memory.json | engines engine enginetest properties runtime | engines_test_expects bool true
	
properties_env:
	engines engine enginetest stop | engines_test_expects bool true
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	cat runtime_properties_env.json | engines engine enginetest properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest state  | engines_test_expects text is running
	echo -n " Checking:"
	engines engine enginetest   | engines_test_expects text valuewer32342342

destroy:
	engines engine enginetest stop  | engines_test_expects bool true
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	engines engine enginetest destroy  | engines_test_expects bool true
	engines engine enginetest wait_for destroy 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest state | engines_test_expects text is nocontainer

create:
	engines engine enginetest stop  | engines_test_expects bool true
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	engines engine enginetest destroy  | engines_test_expects bool true
	engines engine enginetest wait_for destroy 20 | engines_test_expects bool true
	engines engine enginetest create  | engines_test_expects bool true
	engines engine enginetest wait_for start 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest state | engines_test_expects text is running
	
recreate:
	engines engine enginetest stop | engines_test_expects bool true
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	engines engine enginetest recreate | engines_test_expects bool true
	engines engine enginetest wait_for start 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest state | engines_test_expects text is running
	
reinstall:
	engines engine enginetest reinstall | engines_test_expects bool true
	engines engine enginetest wait_for start 220 | engines_test_expects bool true	
	echo -n " Checking:"
	engines engine enginetest state | engines_test_expects text is running
	
engine:
	engines engine enginetest | engines_test_expects json memory
	
status:
	engines engine enginetest status | engines_test_expects json state
	
blueprint:
	 engines engine enginetest blueprint| engines_test_expects json schema

websites:
	 engines engine enginetest websites | engines_test_expects regex ".*http.*"

logs:
	engines engine enginetest logs | engines_test_expects json stderr

ps:
	engines engine enginetest ps | engines_test_expects json Processes
	
halt:
	engines engine enginetest halt | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	engines engine enginetest status | engines_test_expects json state stopped
	engines engine enginetest status | engines_test_expects json set_state running
	
delete:
	engines engine enginetest stop  | engines_test_expects bool true
	engines engine enginetest wait_for stop 20 | engines_test_expects bool true
	engines engine enginetest destroy  | engines_test_expects bool true
	engines engine enginetest wait_for destroy 20 | engines_test_expects bool true
	engines engine enginetest delete none | engines_test_expects bool true
	echo -n " Checking:"
	engines engine enginetest state | engines_test_expects json error_object,error_mesg
	
clean:
	engines engine enginetest stop
	engines engine enginetest wait_for stop 15
	engines engine enginetest destroy
	engines engine enginetest wait_for destroy 10
	engines engine enginetest delete all