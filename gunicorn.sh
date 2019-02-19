NAME="mp3drive"                                   # Name of the application
DJANGODIR=/root/mp3driveapp                       # Django project directory
SOCKFILE=/root/mp3driveapp/gunicorn.sock          # we will communicte using this unix socket
USER=root                                        # the user to run as
GROUP=www-data                                     # the group to run as
NUM_WORKERS=3                                     # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=mp3drive.settings             # which settings file should Django use
DJANGO_WSGI_MODULE=mp3drive.wsgi  