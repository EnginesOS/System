TESTS= default_domain docker_ip hrs_from_gmt mgmt_host mongo_host mysql_host pgsql_host publickey random release system_hostname smtp_host system_hostname system_ip timezone timezone_country_city 


tests:
	echo \033[0;31m Template tests \033[0;30m
	@$(foreach test,$(TESTS),  echo -n $(test):; make -s $(test);)
	
publickey:
	engines system template '_Engines_System(publickey)' |engines_test_expects text_len gt 10

random:
	engines system template '_Engines_System(random(10))' |engines_test_expects text_len eq 10

default_domain:
	engines system template '_Engines_System(default_domain)' |engines_test_expects text_len gt 4

smtp_host:
	engines system template '_Engines_System(smtp_host)' |engines_test_expects text smtp.engines.internal
 
pgsql_host:
	engines system template '_Engines_System(pgsql_host)' |engines_test_expects text pgsql.engines.internal

mysql_host:
	engines system template '_Engines_System(mysql_host)' |engines_test_expects text mysql.engines.internal

mongo_host:
	engines system template '_Engines_System(mongo_host)' |engines_test_expects text mongo.engines.internal

timezone_country_city:
	engines system template '_Engines_System(timezone_country_city)' |engines_test_expects text Australia/Sydney

timezone:
	engines system template '_Engines_System(timezone)' |engines_test_expects text AEST

hrs_from_gmt:
	engines system template '_Engines_System(hrs_from_gmt)' |engines_test_expects regex ".*10"
	
system_ip:
	engines system template '_Engines_System(system_ip)' |engines_test_expects regex ".*\..*\..*\."
	
docker_ip:
	engines system template '_Engines_System(docker_ip)' |engines_test_expects regex ".*\..*\..*\."
	
mgmt_host:
	engines system template '_Engines_System(mgmt_host)' |engines_test_expects regex ".*\..*\..*\."
	
release:
	engines system template '_Engines_System(release)' |engines_test_expects text `cat /opt/engines/release`
	
system_hostname:
	engines system template '_Engines_System(system_hostname)' |engines_test_expects text `engines system config hostname`
