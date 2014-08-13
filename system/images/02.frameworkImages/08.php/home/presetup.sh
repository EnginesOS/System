#!/bin/bash


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
                                        cd $LOCATION

                                        echo Downloading  $TAR_FILE
                                        wget -q $TAR_FILE -O $ARCHIVE
                                        echo "Extracting to $LOCATION"
                                       $EXTRACT_CMD  $ARCHIVE >/dev/null
                                        echo $EXTRACT_CMD  $ARCHIVE 

                                        rm $ARCHIVE


                                                if test -n $APP_SRC_DIR
                                                        then
                                                        echo "Moving to Destination"
                                                        cp -rp $APP_SRC_DIR/* .
                                                        rm -r $APP_SRC_DIR
                                                fi

                fi

          n=`expr $n + 1`
        done

