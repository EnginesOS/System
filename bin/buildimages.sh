#/bin/sh

. /opt/engines/etc/scripts.env

if test -f /opt/engines/release
	RELEASE=`cat /opt/engines/release`
else
	RELEASE=latest
fi


cd $MasterImagesDir




	for class in `ls $MasterImagesDir`
		do 
			cd $class
			for dir in `ls .`
			  do
				cd $MasterImagesDir/$class/$dir
					if test -f TAG
						then 
							tag=`env release=$RELEASE cat TAG`
							echo "----------------------"
							echo "Building $tag"
								if test -f setup.sh
									then 
										./setup.sh
									fi
							docker build --rm=true -t $tag .
								if test $? -eq 0
									then
										echo "Built $tag"
										if test $# -gt 0
										then
											if test $1 = "-p"
											then
												docker push ${tag}
											fi
										fi
										
										touch last_built
									else
										echo "Failed to build $tag in $class/$dir"
										exit
								fi
							echo "======================"
					fi
			done
		cd $MasterImagesDir
			 
		
		done





