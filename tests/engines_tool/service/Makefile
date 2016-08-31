#note the order of the tests is important create before dependancies
	
TESTS=state stop start pause unpause  template mem_stat net_stat\
	  create dependacies properties_net properties_run\
	 services consumers configurations\
	 destroy  recreate 
	 #actions

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

actions:
	cd actions ; make -s tests ; cd ..

services:	
	cd services ; make -s tests ; cd ..
	
consumers:
	cd consumers ; make -s tests ; cd ..

state:
	engines_tool service dns state 	|engines_test_expects text is running
	
stop:
	engines_tool service dns stop  |engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns state | engines_test_expects text is stopped
	
start:
	engines_tool service dns start | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns state | engines_test_expects text is running
	
pause:
	engines_tool service dns pause | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns state | engines_test_expects text is paused
	
unpause:
	engines_tool service dns unpause | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service dns state | engines_test_expects text is running
	
mem_stat:
	engines_tool service dns mem_stat | engines_test_expects json maximum
	
net_stat:
	engines_tool service dns net_stat | engines_test_expects json in
	
dependacies:
	engines_tool service email state 	|engines_test_expects text is running


properties_net:
	engines_tool service email stop | engines_test_expects bool true
	cat network_properties.json | engines_tool service email properties network | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service testengine state  | engines_test_expects text is running
	

properties_run:
	make properties_memory
	make properties_env
	
properties_memory:
	engines_tool engine email stop | engines_test_expects bool true
	cat runtime_properties_memory.json | engines_tool engine email properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine email state  | engines_test_expects text is running
	echo -n " Checking:"
	engines_tool engine email state  | engines_test_expects text 128
	engines_tool engine email stop | engines_test_expects bool true
	cat revert_runtime_properties_memory.json | engines_tool engine email properties runtime | engines_test_expects bool true
	
properties_env:
	engines_tool engine email stop | engines_test_expects bool true
	cat runtime_properties_env.json | engines_tool engine email properties runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool engine email state  | engines_test_expects text is running
	echo -n " Checking:"
	engines_tool engine email   | engines_test_expects text valuewer32342342
	

	
destroy:
	engines_tool service email stop  | engines_test_expects bool true
	engines_tool service email destroy  | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service email state | engines_test_expects text is nocontainer
	
recreate:
	engines_tool service email stop  | engines_test_expects bool true
	engines_tool service email recreate | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service email state | engines_test_expects text is running
	
create:
	engines_tool service email imap | engines_test_expects bool true
	echo -n " Checking:"
	engines_tool service imap state | engines_test_expects text is running