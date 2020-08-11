#note the order of the tests is important create before dependancies
	
TESTS=state stop start pause unpause  template mem_stat net_stat\
	 create dependacies properties_net properties_run\
	 _services _consumers _configurations _configurations\
	 destroy create  recreate \
	 _actions destroy

tests:
	echo -n "\033[0;34m Service tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

_actions:
	cd _actions ; make -s tests ; cd ..

_services:	
	cd _services ; make -s tests ; cd ..
	
consumers:
	cd _consumers ; make -s tests ; cd ..

state:
	engines service dns state |engines_test_expects text is running
	
stop:
	engines service dns stop |engines_test_expects bool true
	engines service dns wait_for stop 25 | engines_test_expects bool true
	echo -n " Checking:"
	engines service dns state | engines_test_expects text is stopped
	
start:
	engines service dns start | engines_test_expects bool true
	engines service dns wait_for start 25 | engines_test_expects bool true
	echo -n " Checking:"
	engines service dns state | engines_test_expects text is running
	
pause:
	engines service dns pause | engines_test_expects bool true
	engines service dns wait_for pause 25 | engines_test_expects bool true
	echo -n " Checking:"
	engines service dns state | engines_test_expects text is paused
	
unpause:
	engines service dns unpause | engines_test_expects bool true
	engines service dns wait_for unpause 25 | engines_test_expects bool true
	echo -n " Checking:"
	engines service dns state | engines_test_expects text is running
	
mem_stat:
	engines service dns mem_stat | engines_test_expects json maximum
	
net_stat:
	engines service dns net_stat | engines_test_expects json in
	
dependacies:
	engines service email state |engines_test_expects text is running


properties_net:
	engines service email stop | engines_test_expects bool true
	engines service email wait_for stop 25 | engines_test_expects bool true
	cat network_properties.json | engines service email properties set network | engines_test_expects bool true
	echo -n " Checking:"
	engines service email state  | engines_test_expects text is running
	
template:
	engines service dns template '_Engines_Builder(engine_name)' | engines_test_expects text is dns
	
properties_run:
	make properties_memory
	make properties_env
	
properties_memory:
	engines service email stop | engines_test_expects bool true
	engines service email wait_for stop 25 | engines_test_expects bool true
	cat runtime_properties_memory.json | engines service email properties set runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines service email wait_for start 25 | engines_test_expects bool true
	engines service email state  | engines_test_expects text is running
	echo -n " Checking:" 
	engines service email  |  engines_test_expects json memory 128
	engines service email stop | engines_test_expects bool true
	engines service email wait_for stop 25 | engines_test_expects bool true
	cat revert_runtime_properties_memory.json | engines service email properties set runtime | engines_test_expects bool true
	engines service email wait_for start 25 | engines_test_expects bool true
	
properties_env:
	engines service email stop | engines_test_expects bool true
	engines service email wait_for stop 25 | engines_test_expects bool true
	cat runtime_properties_env.json | engines service email properties set runtime | engines_test_expects bool true
	echo -n " Checking:"
	engines service email state  | engines_test_expects text is running
	echo -n " Checking:"
	engines service email   | engines_test_expects text valuewer32342342
	

	
destroy:
	engines service email stop  | engines_test_expects regex '.*'
	engines service email wait_for stop 45 
	engines service email destroy  | engines_test_expects regex '.*'
	engines service email wait_for destroy 20 
	echo -n " Checking:"
	engines service email state | engines_test_expects text is nocontainer
	engines service imap stop  | engines_test_expects regex '.*'
	engines service imap wait_for stop 45 
	engines service imap destroy  | engines_test_expects regex '.*'
	engines service imap wait_for destroy 20 | engines_test_expects bool true
	echo -n " Checking:"
	engines service imap state | engines_test_expects text is nocontainer
	
recreate:
	engines service imap stop  | engines_test_expects bool true
	engines service imap wait_for stop 45 | engines_test_expects bool true
	engines service imap recreate | engines_test_expects bool true
	echo -n " Checking:"
	engines service imap wait_for start 120 | engines_test_expects bool true
	
	
create:
	engines service  imap create | engines_test_expects bool true
	echo -n " Checking:"
	engines service email wait_for start 240 | engines_test_expects bool true
	engines service imap wait_for start 140 | engines_test_expects bool true
	
_configurations:
	cd configurations ; make -s tests ; cd ..
	
	
	