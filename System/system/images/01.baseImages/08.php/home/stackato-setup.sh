
#!/bin/bash
FS=$STACKATO_FILESYSTEM

###For Docker Envion
SAR=app
#####


. ./setup.env

ARCHIVE_CNT=${#SEDSTRS[@]}

#KLUDGE 
INSTALL_SCRIPT=install.php
CONFIGURED_FILE=$FS/config.php

#INSTALL_SCRIPT=config.sample.inc.php
echo dbname $dbname dbport $dbport dbuser $dbuser dbpass $dbpasswd dbhost $dbhost


echo  h $HOME s $SAR

cd  $SAR
#ls -lRa /usr/lib/php5

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
#ls

  echo "Configured $CONFIGURED_FILE file"
if test ! -z  $CONFIGURED_FILE
 then
        if test ! -f  $CONFIGURED_FILE
         then
           run=1
           echo "Configured $CONFIGURED_FILE file not found"
        fi
 fi

if   [ $run -ne 0 ]
 then
n=0
echo "performing substitutions"
        while test $n -lt $ARCHIVE_CNT
        do
          SED_STR=${SEDSTRS[$n]}
          SED_FILE=${SEDTARGETS[$n]}
        SED_TARGET=${SEDDSTS[$n]}

# cat $SED_FILE | sed --expression="$SED_STR"

          cat $SED_FILE | sed --expression="$SED_STR"  > t.config.$n
        echo "  cat $SED_FILE | sed "\"$SED_STR\"" > t.config.$n"

          cp t.config.$n  $SED_TARGET
          echo cp t.config.$n  $SED_TARGET

          n=`expr $n + 1`

        done
fi


if ! [ -f $FS/$PERSISTANCE_CONFIGURED_FILE ]
  then
echo "no $PERSISTANCE_CONFIGURED_FILE  Creating and setting up persistance"
                for dir in $PERSISTANT_DIRS
                        do
        echo  mkdir -p $FS/$dir
                        mkdir -p $FS/$dir
                         cp -rp ./$dir  $FS/$dir
                        rm -r  ./$dir
                        ln -s $FS/$dir  ./$dir
                        done
                 for file in $PERSISTANT_FILES
                        do
echo  cp $file  $FS/
                          cp $file  $FS/
                          rm $file
                         ln -s $FS/$file .

                        done
else

echo setting up persistance

if test ! -z  $INSTALL_SCRIPT -a ! -z $CONFIGURED_FILE
 then
        echo deleting install
        rm  $INSTALL_SCRIPT
fi

  for dir in $PERSISTANT_DIRS
             do
              rm -r  ./$dir
       echo cp t.config.$n  $SED_TARGET

          n=`expr $n + 1`

        done
fi


if ! [ -f $FS/$PERSISTANCE_CONFIGURED_FILE ]
  then
echo "no $PERSISTANCE_CONFIGURED_FILE  Creating and setting up persistance"
                for dir in $PERSISTANT_DIRS
                        do
        echo  mkdir -p $FS/$dir
                        mkdir -p $FS/$dir
                         cp -rp ./$dir  $FS/$dir
                        rm -r  ./$dir
                        ln -s $FS/$dir  ./$dir
                        done
                 for file in $PERSISTANT_FILES
                        do
echo  cp $file  $FS/
                          cp $file  $FS/
                          rm $file
                         ln -s $FS/$file .

                        done
else

echo setting up persistance

if test ! -z  $INSTALL_SCRIPT -a ! -z $CONFIGURED_FILE
 then
        echo deleting install
        rm  $INSTALL_SCRIPT
fi

  for dir in $PERSISTANT_DIRS
             do
              rm -r  ./$dir
                echo "./$dir"
              ln -s $FS/$dir  .
             done

 for file in $PERSISTANT_FILES
              do
echo rm $file
echo ln -s $FS/$file . 
                   rm $file
                   ln -s $FS/$file .

                done
fi

