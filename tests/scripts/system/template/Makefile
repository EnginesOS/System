TESTS=publickey random default_domain smtp_host pgsql_host mysql_host mongo_host timezone_country_city hrs_from_gmt


tests:
	$(foreach test,$(TESTS),  make $(test);)
	
publickey:
	engines_tool system template '_Engines_System(publickey)' |engines_test_expects text gt 10

random:
	engines_tool system template '_Engines_System(random(10))' |engines_test_expects text eq 10

default_domain:
	engines_tool system template '_Engines_System(default_domain)' |engines_test_expects text gt 4

smtp_host:
	engines_tool system template '_Engines_System(smtp_host)' |engines_test_expects text smtp.engines.internal
 
pgsql_host:
	engines_tool system template '_Engines_System(pgsql_host)' |engines_test_expects text pgsql.engines.internal

mysql_host:
	engines_tool system template '_Engines_System(mysql_host)' |engines_test_expects text mysql.engines.internal

mongo_host:
	engines_tool system template '_Engines_System(mongo_host)' |engines_test_expects text mongo.engines.internal

timezone_country_city:
	engines_tool system template '_Engines_System(timezone_country_city)' |engines_test_expects text Australia/Sydney

hrs_from_gmt:
	engines_tool system template '_Engines_System(hrs_from_gmt)' |engines_test_expects text +10