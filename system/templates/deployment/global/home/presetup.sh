#!/bin/bash
DOWNLOADCACHE=/opt/dl_cache

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
	 



. ./presettings.env

###needed for DOCKER Env
mkdir app
cd app
HOME=./
##########

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

chown -R www-data /home/app/
