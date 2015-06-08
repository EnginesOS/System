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
		rm /opt/engines/run/${service}.cid
	done
         eservices stop 
         eservice recreate dns
         eservice create dns
         eservice recreate nginx
         eservice create nginx
         eservice recreate auth
         eservice create auth
         eservices recreate
         
         docker rmi $( docker images -f "dangling=true" -q) > /dev/null