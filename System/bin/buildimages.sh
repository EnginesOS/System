#/bin/sh

. /opt/engos/etc/scripts.env



cd $MasterImagesDir



	for class in `ls $MasterImagesDir`
		do 
			cd $class
			for dir in `ls .`
			  do
				cd $MasterImagesDir/$class/$dir
					if test -f TAG
						then 
							tag=`cat TAG`
							echo "----------------------"
							echo "Building $tag"
							docker build --rm=true -t $tag .
								if test $? -eq 0
									then
										echo "Built $tag"
									else
										echo "Failed to build $tag in $class/$dir"
										exit
								fi
							echo "======================"
					fi
			done
		cd $MasterImagesDir
			 
		
		done





