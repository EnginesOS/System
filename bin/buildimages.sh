#/bin/sh

. /opt/engines/etc/scripts.env

if test -f /opt/engines/release
then
	release=`cat /opt/engines/release`
else
	release=latest
fi

export release

cd $MasterImagesDir




	for class in `ls $MasterImagesDir`
		do 
			cd $class
			for dir in `ls .`
			  do
				cd $MasterImagesDir/$class/$dir
					if test -f TAG
						then 
							tag_r=`cat TAG`
							tag=$(eval "echo $tag_r")
							echo "----------------------"
							echo "Building $tag"
								if test -f setup.sh
									then 
										./setup.sh
									fi
							 cat Dockerfile |  sed "/\$release/s//$release/" > Dockerfile.$release
							 docker build --rm=true -t $tag -f Dockerfile.$release .
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





