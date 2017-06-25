TESTS=prepare\
	persistent_services persistent_services_type persistent_service\
	service_persistent_import service_persistent_replace service_persistent_export \
	clean_up

tests:
	echo -n "\033[0;31m Engines Persistent Services tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

persistent_services:
	engines engine prosody services persistent | engines_test_expects array
	
	
persistent_services_type:
	engines engine prosody services persistent EnginesSystem database/sql/mysql | engines_test_expects array

persistent_service:
	engines engine prosody service persistent EnginesSystem filesystem/local/filesystem prosody | engines_test_expects json type_path filesystem/local/filesystem 


service_persistent_export:
	engines engine prosody service persistent EnginesSystem database/sql/mysql prosody export  |gzip -d  >/tmp/export_test.sql
	cat /tmp/export_test.sql| engines_test_expects regex "*-- Host:* Database: " 
	cat /tmp/export_test.sql | engines engine prosody service persistent EnginesSystem database/sql/mysql prosody replace
	engines engine prosody action perform list_users | engines_test_expects regex "*test1*"

service_persistent_import:
	echo '{"username":"test2","password":"pass2"}' | engines engine prosody action perform add_user 
	cat test_import_data.sql | engines engine prosody service persistent EnginesSystem database/sql/mysql prosody import
	engines engine prosody action perform list_users | engines_test_expects regex "*test3*"
	engines engine prosody action perform list_users | engines_test_expects regex "*test2*"
	
service_persistent_replace:
	echo '{"username":"test4","password":"pass4"}' | engines engine prosody action perform add_user 
	cat test_import_data.sql | engines engine prosody service persistent EnginesSystem database/sql/mysql prosody replace
	engines engine prosody action perform list_users | engines_test_expects regex "*test3*"
	engines engine prosody action perform list_users | engines_test_expects not regex "*test4*"

prepare:
	cat ../../actions/prosody_build_params.json | engines engines build
	engines engine_builder follow >/dev/null
	echo '{"username":"test1","password":"pass"}' | engines engine prosody action perform add_user 



clean_up:
	engines engine prosody stop 
	engines engine prosody destroy 
	engines engine prosody delete all
	
	
service_persistent_add:
	cat add_persistent_service.json | engines engine enginetest services persistent add EnginesSystem database/sql/mysql |engines_test_expects bool true
	echo -n " Checking:"
	engines service database/sql/mysql consumer enginetest  testdatabase |engines_test_expects  json type_path database/sql/mysql
	
service_persistent_edit:
	cat edit_persistent_service.json |engines engine enginetest service persistent modify EnginesSystem database/sql/mysql testdatabase|engines_test_expects bool true
	echo -n " Checking:"
	engines service database/sql/mysql consumer enginetest  testservice 
	
service_persistent_del:
	engines engine enginetest services persistent del EnginesSystem database/sql/mysql testdatabase|engines_test_expects bool true
	echo -n " Checking:"
	engines service database/sql/mysql consumer enginetest  testservice |engines_test_expects bool false