TESTS=pubkey random default_domain smtp_host pgsql_host mysql_host mongo_host timezone_country_city hrs_from_gmt


tests:
	$(foreach test,$(TESTS),  make $(test);)
	
publickey:
	engines_tool system template '_Engines_System(publickey)' |engines_test_expects text

random:
	engines_tool system template '_Engines_System(random(10))' |engines_test_expects text

default_domain:
	engines_tool system template '_Engines_System(default_domain)' |engines_test_expects text

smtp_host:
	engines_tool system template '_Engines_System(smtp_host)' |engines_test_expects text
 
pgsql_host:
	engines_tool system template '_Engines_System(pgsql_host)' |engines_test_expects text

mysql_host:
	engines_tool system template '_Engines_System(mysql_host)' |engines_test_expects text

mongo_host:
	engines_tool system template '_Engines_System(mongo_host)' |engines_test_expects text

timezone_country_city:
	engines_tool system template '_Engines_System(timezone_country_city)' |engines_test_expects text

hrs_from_gmt:
	engines_tool system template '_Engines_System(hrs_from_gmt)' |engines_test_expects text