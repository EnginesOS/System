TESTS=prepare\
	persistent_services persistent_services_type persistent_service\	
	service_persistent_import service_persistent_replace service_persistent_export \
	clean_up

tests:
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

persistent_services:
	engines_tool engine prosody services persistent | engines_test_expects array
	
	
persistent_services_type:
	engines_tool engine prosody services persistent EnginesSystem database/sql/mysql | engines_test_expects array

persistent_service:
	engines_tool engine prosody service persistent EnginesSystem filesystem/local/filesystem prosody | engines_test_expects json type_path filesystem/local/filesystem 


service_persistent_export:
	engines_tool engine prosody service persistent EnginesSystem database/sql/mysql prosody export  |gzip -d  >/tmp/export_test.sql
	cat /tmp/export_test.sql| engines_test_expects regex "*-- Host:* Database: " 
	cat /tmp/export_test.sql | engines_tool engine prosody service persistent EnginesSystem database/sql/mysql prosody replace
	engines_tool engine prosody action perform list_users | engines_test_expects regex "*test1*"

service_persistent_import:
	echo '{"username":"test2","password":"pass2"}' | engines_tool engine prosody action perform add_user 
	cat test_import_data.sql | engines_tool engine prosody service persistent EnginesSystem database/sql/mysql prosody import
	engines_tool engine prosody action perform list_users | engines_test_expects regex "*test3*"
	engines_tool engine prosody action perform list_users | engines_test_expects regex "*test2*"
	
service_persistent_replace:
	echo '{"username":"test4","password":"pass4"}' | engines_tool engine prosody action perform add_user 
	cat test_import_data.sql | engines_tool engine prosody service persistent EnginesSystem database/sql/mysql prosody replace
	engines_tool engine prosody action perform list_users | engines_test_expects regex "*test3*"
	engines_tool engine prosody action perform list_users | engines_test_expects not regex "*test4*"

prepare:
	cat ../../actions/prosody_build_params.json | engines_tool engines build
	engines_tool engine_builder follow >/dev/null
	echo '{"username":"test1","password":"pass"}' | engines_tool engine prosody action perform add_user 

clean_up:
	engines_tool engine prosody stop 
	engines_tool engine prosody destroy 
	engines_tool engine prosody delete all