FROM  engines/python:alpha
ADD home home
ADD engines home/engines

RUN apt-get update -y;\
	chowns=`find /var /usr/share /usr/local /home -user www-data`;\
	/usr/sbin/usermod -u 22671 www-data;\
	if test `echo $chowns | sed "/ /s///g" | wc -c` -gt 1 ;\
	then\
		chown www-data $chowns;\
		fi 
		
CMD /home/start.bash