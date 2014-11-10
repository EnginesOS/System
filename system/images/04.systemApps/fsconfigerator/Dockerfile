FROM busybox
ADD setup_vols.sh /home/
VOLUME /client/var/log
VOLUME /client/log
VOLUME /client/state
VOLUME /client/fs
VOLUME /dest/fs
CMD /home/setup_vols.sh