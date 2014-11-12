FROM busybox
ADD setup_vols.sh /home/
VOLUME /client/var/log
VOLUME /client/log
VOLUME /client/state
VOLUME /client/fs
VOLUME /dest/fs
RUN adduser -q --ingroup www-data --uid 22672 --home /home/ruby --disabled-password  ruby;\
 	adduser -q --ingroup www-data --uid 22671 www-data;\
	adduser -q --ingroup www-data --uid 22673 node;\
	adduser -q --ingroup www-data --uid 22674
	
CMD /home/setup_vols.sh