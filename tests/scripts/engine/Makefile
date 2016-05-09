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
	engines_tool engine testengine state 	|engines_test_expects text is running
	
stop:
	engines_tool engine testengine stop  |engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is stopped
	
start:
	engines_tool engine testengine start | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is running
	
pause:
	engines_tool engine testengine pause | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is paused
	
unpause:
	engines_tool engine testengine unpause | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is running
	
template:
	engines_tool engine testengine template '_Engines_Builder(engine_name)' | engines_test_expects text is testengine
	
mem_stat:
	engines_tool engine testengine mem_stat | engines_test_expects json maximum
	
net_stat:
	engines_tool engine testengine net_stat | engines_test_expects json in
	
	
blueprint:
	engines_tool engine testengine blueprint | engines_test_expects json software
		
build_report:
	engines_tool engine testengine build_report | engines_test_expects text built
	

properties_net:
	engines_tool engine testengine stop
	cat network_properties.json | engines_tool engine testengine properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state  | engines_test_expects text is running
	
	
properties_run:
	engines_tool engine testengine stop
	cat network_properties.json | engines_tool engine testengine properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state  | engines_test_expects text is running
	echo -n " Checking:"
	engines_tool engine testengine state  | engines_test_expects text 577
	
destroy:
	engines_tool engine testengine stop  | engines_test_expects bool true
	engines_tool engine testengine destroy  | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is nocontainer
	
recreate:
	engines_tool engine testengine recreate | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is running
	
reinstall:
	engines_tool engine testengine stop  | engines_test_expects bool true
	engines_tool engine testengine destroy  | engines_test_expects bool true
	engines_tool engine testengine reinstall | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects text is running
	
delete:
	engines_tool engine testengine stop  | engines_test_expects bool true
	engines_tool engine testengine destroy  | engines_test_expects bool true
	engines_tool engine testengine delete none | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine testengine state | engines_test_expects json error_object,error_mesg