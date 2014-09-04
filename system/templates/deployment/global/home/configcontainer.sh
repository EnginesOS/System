#!/bin/bash

cd /home
###For Docker Envion
SAR=app


if test -f fs.env
        then
         . ./fs.env
		mkdir -p $CONTFSVolHome
fi



if test -f app.env
        then
         . ./app.env
fi

if test -f stack.env
        then
         . ./stack.env
fi



#####

#Setup Environment vaiables used in substitutions
TZ=`find /usr/share/zoneinfo -type f -exec sh -c "diff -q /etc/localtime '{}' > /dev/null && echo {}" \; | sed "/.*info\//s///"`

#TZ has country/state format and we need to escape the /
state=`echo $TZ |cut -f2 -d/`
country=`echo $TZ |cut -f1 -d/`
TZ="$country\/$state"



top=`pwd`


if test -f ./db.env
 then
echo "reading in db Config"
	. ./db.env
 fi

. ./setup.env
setuppersistance=0


if test -f ./fs.env
 then
echo "reading in fs Config"

        . ./fs.env

	FS=$CONTFSVolHome/$VOLDIR

		if test ! -d $FS
		 then
			setuppersistance=1
			mkdir -p $FS
			echo " mkdir -p $FS"
                elif ! test -f $FS/.persistanceconfigured
                        then
                                touch $FS/.persistanceconfigured
                         setuppersistance=1

		fi
 fi

        if test -n "$CRONJOBS"
                then
                        cnt=${#CRONJOBS[@]}
			
			n=0
                                while test $n -lt $cnt
                                        do
                                                CRONJOB=${CRONJOBS[$n]}
                                                n=`expr $n + 1`
                                                echo $CRONJOB > /home/cron/cron.$n
                                        done
        fi





ARCHIVE_CNT=${#SEDSTRS[@]}

echo dbname $dbname dbport $dbport dbuser $dbuser dbpass $dbpasswd dbhost $dbhost


cd  $SAR

run=0
echo "Install $INSTALL_SCRIPT script"
if test ! -z  $INSTALL_SCRIPT
 then
        if test -f  $INSTALL_SCRIPT  
         then
           if  test -z $CONFIGURED_FILE 
            then
               run=1
                echo "Install $INSTALL_SCRIPT script found "
            elif  test ! -f $CONFIGURED_FILE
                then 
                        run=1
            fi
        fi
 fi
ls
pwd
  echo "Configured $CONFIGURED_FILE file"
if test ! -z  $CONFIGURED_FILE
 then
        if test ! -f  $FS/$CONFIGURED_FILE
         then
           run=1
           echo "Configured $FS/$CONFIGURED_FILE file not found"
        fi
 fi
#FIX ME
	if  test $setuppersistance -eq 1
		then
			run=1
		fi

echo run state $run

if   [ $run -ne 0 ]
 then
n=0
echo "performing  $ARCHIVE_CNT substitutions"
        while test $n -lt $ARCHIVE_CNT
        do
          SED_STR=${SEDSTRS[$n]}
          SED_FILE=${SEDTARGETS[$n]}
        SED_TARGET=${SEDDSTS[$n]}

# cat $SED_FILE | sed --expression="$SED_STR"

          cat $SED_FILE | sed --expression="$SED_STR"  > t.config.$n

        echo "  cat $SED_FILE | sed "\"$SED_STR\"" > t.config.$n"
		if [ $? -eq 0 ]
			then

          		cp t.config.$n  $SED_TARGET
          		echo cp t.config.$n  $SED_TARGET
		  else
			echo "cat $SED_FILE | sed $SED_STR > t.config.$n Failed"
		fi

          n=`expr $n + 1`

        done
echo "config files written"
fi


#if ! [ -f $FS/$PERSISTANCE_CONFIGURED_FILE ]
if [ $setuppersistance -eq 1 ]
  then
echo "Creating and setting up persistance"
                for dir in $PERSISTANT_DIRS
                        do
ls -la $FS
        echo  mkdir -p $FS/$dir
                        mkdir -p $FS/$dir
echo " cp -rp ./$dir/*  $FS/$dir"
                         cp -rp ./$dir/*  $FS/$dir
                        rm -r  ./$dir
                        ln -s $FS/$dir  .
	echo "ln -s $FS/$dir  ."

		ls -l $FS/$dir
                        done
                 for file in $PERSISTANT_FILES
                        do
echo  cp $file  $FS/
#FIX ME as wont work if persistant file is not in /
echo "cp $file  $FS/"

                          cp $file  $FS/
                          rm $file
echo " ln -s $FS/$file ."
                         ln -s $FS/$file .

                        done
else

echo setting up persistance
echo if test ! -z  $INSTALL_SCRIPT -a ! -z $CONFIGURED_FILE

if test ! -z  $INSTALL_SCRIPT 
 then
  if test  ! -z $CONFIGURED_FILE
    then
        echo deleting install
        rm  $INSTALL_SCRIPT
  fi
fi

  for dir in $PERSISTANT_DIRS
             do
		
              rm -r  ./$dir

 		 echo "rm -r ./$dir ; ln -s $FS/$dir  ./$dir"
		ls $FS/$dir
		ls 
		if ! test -e  $dir
			then
              			ln -s $FS/$dir  .
		fi

        done

 for file in $PERSISTANT_FILES
              do
echo rm $file
echo ln -s $FS/$file . 
                   rm $file
                   ln -s $FS/$file .

                done

fi


echo "loading system.env"


if test -f $top/system.env
	then	
		. $top/system.env
fi


if test -z $FRAMEWORK
        then
                FRAMEWORK=php
        fi



if test $FRAMEWORK = rails3 -o $FRAMEWORK = rails4
	then

if test $RUNTIME = ruby2
	then
			/usr/local/rvm/bin/rvm use ruby-2.1.1
#GEM_HOME=/usr/local/rvm/gems/ruby-2.1.1
#GEM_PATH=/usr/local/rvm/gems/ruby-2.1.1:/usr/local/rvm/gems/ruby-2.1.1@global
#MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-2.1.1

#RUBY_VERSION=ruby-2.1.1
#PATH=/usr/local/rvm/gems/ruby-2.1.1/bin:/usr/local/rvm/gems/ruby-2.1.1@global/bin:/usr/local/rvm/rubies/ruby-2.1.1/bin:/usr/local/rvm/bin:$PATH
Bundle_Cmd=/usr/local/rvm/gems/ruby-2.1.1/wrappers/bundle


			ruby -v
	elif test $RUNTIME = ruby19
		then 
		 rvm  use ruby-1.9.3-p547
		
#GEM_HOME=/usr/local/rvm/gems/ruby-1.9.3-p547
#GEM_PATH=/usr/local/rvm/gems/ruby-1.9.3-p547:/usr/local/rvm/gems/ruby-1.9.3-p547@global
#MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-1.9.3-p547
#RUBY_VERSION=ruby-1.9.3-p547
#PATH=/usr/local/rvm/gems/ruby-1.9.3-p547/bin:/usr/local/rvm/gems/ruby-1.9.3-p547@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p547/bin:/usr/local/rvm/bin:$PATH
Bundle_Cmd=/usr/local/rvm/gems/ruby-1.9.3-p547/wrappers/bundle




	 	#	/usr/local/rvm/bin/rvm   use 1.9
		#	ruby -v


fi

DATABASE_URL="mysql2://$dbuser:$dbpasswd@$dbhost/$dbname"

export DATABASE_URL
RAILS_ENV=production
export RAILS_ENV
 . /home/stack.env

HOME=/home/app
export HOME
echo "web: env DATABASE_URL=mysql2://$dbuser:$dbpasswd@$dbhost/$dbname  bundle exec thin -p \$PORT  start

" > Procfile
echo "Procfile Written "
echo "#!/bin/bash
 . /etc/profile.d/rvm.sh



DATABASE_URL=mysql2://$dbuser:$dbpasswd@$dbhost/$dbname 



PATH=$GPATH:$PATH


export DATABASE_URL GEM_HOME GEM_PATH MY_RUBY_HOME RUBY_VERSION PATH
#bundle exec thin -p $PORT  start
HOME=/home/app
export HOME


env DATABASE_URL=$DATABASE_URL bundle exec thin -p $PORT  start



" > Procfile.sh

chmod +x Procfile.sh


echo "login: &login
  adapter: mysql2
  host: localhost
  username: root
  password:


development:
  database: publify_dev
  <<: *login

test:
  database: publify_tests
  <<: *login

production:
  database: publify
  <<: *login
" > config/database.yml

echo "config.database.yml  Written"

echo "gem 'thin'" >> Gemfile
cat Gemfile
echo "Thin added to Gemfile"

cat Gemfile | sed "/https/s//http/" >g
cp g Gemfile

echo running $Bundle_Cmd install --standalone
$Bundle_Cmd install  --standalone


 $Bundle_Cmd	exec rake generate_secret_token



echo "running rake db:"
  $Bundle_Cmd exec  rake db:create
  $Bundle_Cmd exec  rake db:migrate
  $Bundle_Cmd exec rake db:seed


fi
