#/bin/bash
release=`cat /opt/engines/release`
images=`docker images |grep engines |grep $release |awk '{print $1}'`

echo $images

      for image in $images
         do
             docker pull $image:$release
         done

         eservices stop 
         eservice recreate dns
         eservices recreate
         
         docker rmi $( docker images -f "dangling=true" -q) > /dev/null