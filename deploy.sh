#!/bin/bash

# exit when any command fails

#####
# 1) get kwargs from command line with: server_name, git_repo, project_name, tier, secrets_file
# 2) generate deploy script
#####

set -e

export SERVER_NAME='mp3drive.co'
export WWW_NAME="www.${SERVER_NAME}"
export GIT_REPO='git@github.com:CITGuru/mp3drive.co.git'
export MAIN_DIR='/root/app'
export STATIC_DIR=$MAIN_DIR/static/
export PROJECT_NAME='mp3drive'
export SOCK_FILE_LOC=${MAIN_DIR}/$PROJECT_NAME.sock
export SERVICE_FILE_LOC=${MAIN_DIR}/${PROJECT_NAME}.service
export TIER=master
export ENV_FILE=/root/mp3drive/envfile_secrets
export VENV_BIN=$HOME/venv-${PROJECT_NAME}/bin
export PYTHONPATH='/usr/bin/python3.6'
echo "Deleting sock file ${SOCK_FILE_LOC}"
rm -f $SOCK_FILE_LOC

cd $HOME;

rm -rf venv-${PROJECT_NAME}
virtualenv venv-${PROJECT_NAME} -p $PYTHONPATH
source $VENV_BIN/activate


rm -rf $MAIN_DIR
mkdir $MAIN_DIR
cd $MAIN_DIR
git clone -b ${TIER} --single-branch $GIT_REPO .

pip install -r $MAIN_DIR/requirements.txt

# pip install -r $MAIN_DIR/requirements_dev.txt
pip install gunicorn
echo "Project home is: ${MAIN_DIR}"
echo "Project name is: ${PROJECT_NAME}"
echo "Sock file is located at ${SOCK_FILE_LOC}"

echo "Writing service file to ${SERVICE_FILE_LOC}"
cat > $SERVICE_FILE_LOC <<EOL
[Unit]
Description=${PROJECT_NAME} daemon
After=network.target

[Service]
User=$USER
Group=www-data
#Type=oneshot
WorkingDirectory=$MAIN_DIR
EnvironmentFile=$ENV_FILE
ExecStartPre=$VENV_BIN/python $MAIN_DIR/manage.py migrate
#ExecStartPre=cd /root/app/frontend_root && npm install
#ExecStartPre=$VENV_BIN/python $MAIN_DIR/manage.py npminstall
ExecStartPre=$VENV_BIN/python $MAIN_DIR/manage.py collectstatic --noinput
ExecStart=$VENV_BIN/gunicorn --access-logfile $HOME/${PROJECT_NAME}_access.log --error-logfile $HOME/${PROJECT_NAME}_error.log --workers 3 --bind 127.0.0.1:8712 mp3drive.wsgi:application
[Install]
WantedBy=multi-user.target
EOL

echo "Done writing ${PROJECT_NAME} service file"
echo "Moving service file to correct location"
sudo mv $SERVICE_FILE_LOC /etc/systemd/system/
echo "File moved to ${SERVICE_FILE_LOC}"

sudo systemctl daemon-reload
echo "Attempting to start service"
sudo systemctl start ${PROJECT_NAME}
sudo systemctl enable ${PROJECT_NAME}
sudo systemctl --no-pager status ${PROJECT_NAME}
# echo "service ${PROJECT_NAME} successfully started."

cat > $HOME/nginxconf <<EOL
server {
    listen 80;
    server_name ${SERVER_NAME} ${WWW_NAME};

    location = /favicon.ico { access_log off; log_not_found off; }

    location /static/ {
        alias $STATIC_DIR;
        gzip_static on;
        #expires max;
    }
    location / {
        include proxy_params;
        proxy_pass   http://127.0.0.1:8712;
        proxy_redirect     off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header  X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_connect_timeout 30;
        proxy_read_timeout 30;
    }
}
EOL
echo $MAIN_DIR/static;
echo "Copying nginx configs"
sudo mv $HOME/nginxconf /etc/nginx/sites-available/$PROJECT_NAME.conf
sudo ln -sf /etc/nginx/sites-available/$PROJECT_NAME.conf /etc/nginx/sites-enabled
sudo nginx -t
sudo service nginx reload
sudo systemctl restart nginx
sudo systemctl restart $PROJECT_NAME
#sudo chown -R :www-data $STATIC_DIR
chmod -R 777 /root/app/static/
# Chnge nginx user to root
sed -ie 's/^user\ www-data.*/user root;/' /etc/nginx/nginx.conf
exit 0

