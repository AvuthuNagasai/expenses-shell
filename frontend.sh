#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install nginx -y &>>LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx
VALIDATE $? "enable nginx"

systemctl start nginx
VALIDATE $? "sart nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOGFILE
VALIDATE $? "downloading frontend content"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>LOGFILE
VALIDATE $? "Extract the frontend content."

cp /home/ec2-user/expenses-shell/frontend.service /etc/nginx/default.d/expense.conf &>>LOGFILE
VALIDATE $? "Create Nginx Reverse Proxy Configuration."

systemctl restart nginx
VALIDATE $? "Starting nginx"
