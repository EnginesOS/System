#!/bin/bash
DOWNLOADCACHE=/opt/dl_cache
Engines_HOME=/home/app

if test `pwd` == "/"
	then
		cd /home
	fi

if test -f app.env
	then
	 . ./app.env
fi

if test -f stack.env
        then
         . ./stack.env
fi

if test "$FRAMEWORK" == "tomcat"
	then
	mkdir -p /home/app/webapps/ 
	rm -r /usr/share/tomcat7/webapps
	ln -s /home/app/webapps /usr/share/tomcat7/
fi

if test "$FRAMEWORK" == "php"
	 if test -f $Engines_HOME/pear.list
        			then
        			  wget http://pear.php.net/go-pear.phar	
        			  	if test -f  /etc/php5/conf.d/suhosin.ini
        			  		then
        			  			echo "suhosin.executor.include.whitelist = phar" >>/etc/php5/conf.d/suhosin.ini
        			    fi
        			  php go-pear.phar
        			  
        			  for module = `cat $Engines_HOME/pear.list`
        			  	do
        			  		pear install $module
        			  done
    fi
fi

. ./presettings.env

###needed for DOCKER Env
mkdir app
cd app
HOME=./
#########

n=0
ARCHIVE_CNT=${#ARCHIVES[@]}

while test $n -lt $ARCHIVE_CNT
do
        TAR_FILE=${ARCHIVES[$n]}
        EXTRACT_CMD=${ARCHEXTRACTCMDS[$n]}
        ARCHIVE=${ARCHIVENAMES[$n]}
        LOCATION=$HOME/${ARCHLOCATIONS[$n]}
        APP_SRC_DIR=${ARCHDIRS[$n]}


echo "$EXTRACT_CMD $ARCHIVE to $LOCATION from $TAR_FILE  and move from $APP_SRC_DIR"


    if test -n "$TAR_FILE"
            then

		if test "$EXTRACT_CMD" = "git"
			then
				git clone $TAR_FILE
	
			else
				pd=`pwd`
				
					if test ! -d $LOCATION
						then
							mkdir $LOCATION
					fi
					
	            cd $LOCATION
	
					if ! test -f $DOWNLOADCACHE/$ARCHIVE
						then
	                           echo Downloading  $TAR_FILE
	                           wget -q $TAR_FILE -O $ARCHIVE
							cp $ARCHIVE $DOWNLOADCACHE
						else
							echo "Using download cache"
							cp  $DOWNLOADCACHE/$ARCHIVE .
	
					fi
					
				    if ! test "$EXTRACT_CMD" = "none"
					then
	                		echo "Extracting to $LOCATION"
	                		echo $EXTRACT_CMD  $ARCHIVE 
	               			$EXTRACT_CMD  $ARCHIVE >/dev/null
	                		rm $ARCHIVE
				    fi
	
				cd $pd	
			fi

			if test ! -z $APP_SRC_DIR
			  then
                    if test -n $APP_SRC_DIR 
                            then
                            echo "Moving to Destination"                                                        
                            cp -rfp $APP_SRC_DIR/* .
                            cp -rfp $APP_SRC_DIR/.g* .
                            rm -fr $APP_SRC_DIR
                    fi
			   fi
        fi

  	n=`expr $n + 1`
done

	if test -f /home/engines/configs/php/71-custom.ini
		then
		echo "cp /home/engines/configs/php/71-custom.ini /etc/php5/apache2/conf.d/"
			cp /home/engines/configs/php/71-custom.ini /etc/php5/apache2/conf.d/
	fi
	
	if test -f /home/engines/configs/apache2/extra.conf
		then
			cp /home/engines/configs/apache2/extra.conf /etc/apache2/conf.d/
	fi
	
	if test -f /home/engines/configs/apache2/site.conf
		then
			cp /home/engines/configs/apache2/site.conf /etc/apache2/sites-enabled/000-default.conf
	fi
	
	
	if test -f /home/uid
	then
		cont_user=`cat /home/uid`
	else
		cont_user="www-data"
	fi
	
	if test -f /home/gid
	then
		cont_grp=`cat /home/gid`
	else
		cont_grp="www-data"
	fi
	
	
chown -R ${cont_user}.${cont_grp} /home/app/


