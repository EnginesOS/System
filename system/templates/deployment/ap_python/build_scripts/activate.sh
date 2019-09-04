 if test -f /home/app/venv/bin/activate
  then
   echo Activating virtual env
   . /home/app/venv/bin/activate
   else
    virtualenv --system-site-packages --python=python3.7 /home/app/venv
    echo Creating virtualenv
    echo Activating virtual env
   . /home/app/venv/bin/activate
 fi