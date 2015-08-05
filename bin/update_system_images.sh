#/bin/bash
release=`cat /opt/engines/release`
images=`docker images |grep engines |grep $release |awk '{print $1}'`

echo $images

      for image in $images
         do
             docker pull $image:$release
         done

for service in `find /opt/engines/run/services/  -type d -maxdepth 1 |cut -f 6 -d/` 
	do
		
		rm /opt/engines/run/cid/${service}.cid
	done
  
  	eservices stop
  	eservice recreate dns
  	eservice recreate mgmt
  	eservices recreate
  	/opt/engines/bin/follow_start.sh
         
         docker rmi $( docker images -f "dangling=true" -q) > /dev/null
         
         
         
         