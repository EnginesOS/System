TESTS=persistent_services persistent_services_type persistent_service\
	 service_persistent_import service_persistent_replace service_persistent_export
	 
tests:
	echo -n "\033[0;34m Service Persistent Services tests \033[0;30m\n"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)

persistent_services:
	engines service email services persistent | engines_test_expects array
	
	
persistent_services_type:
	engines service email services persistent EnginesSystem | engines_test_expects array

persistent_service:
	engines service email services persistent EnginesSystem  database/sql/mysql email | engines_test_expects json type_path database/sql/mysql


service_persistent_export:
	engines service email service persistent EnginesSystem database/sql/mysql email export  |gzip -d  >/tmp/export_test.sql
	cat /tmp/export_test.sql| engines_test_expects regex "*-- Host:* Database: " 
	cat /tmp/export_test.sql | engines email service persistent EnginesSystem database/sql/mysql email replace
	

service_persistent_import:	
	cat test_import_data.sql | engines service email service persistent EnginesSystem database/sql/mysql email import

	
service_persistent_replace:
	cat test_import_data.sql | engines service email service persistent EnginesSystem database/sql/mysql email replace


