TESTS=prepare cron_job cron_jobs schedules run_cron_job schedule clean_up

tests:
	echo -n "\033[0;31m Engine Cron tests \033[0;30m"
	@$(foreach test,$(TESTS), echo -n $(test):; make -s $(test);)
	
prepare:
	cat prosody_build_params.json | engines engines build
	engines engine_builder follow >/dev/null

schedules:
	engines schedule engine  prosody schedules | engines_test_expects array  

cron_job:

run_cron_job:

schedule:


clean_up:
	engines engine prosody stop 
	engines engine prosody destroy 
	engines engine prosody delete all
