#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME$TIMESTAMP.log

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo "$2...FAILURE"
        exit 1
    else
        echo -e " $R $2...SUCCESS"
    fi
}
R="\e[31m"
G="\e[32m"
Y="\e[33m"
C="\e[36m"



#echo "Please enter DB password:"
#read -s mysql_root_password

if [ $USERID -ne 0 ]
then
  echo -e "$R you must run the code as a super user"
  exit 1
else
  echo -e "$Y you are a super user"
fi

dnf install mysql-server -y $>>LOGFILE
VALIDATE $? "installing my sql server"

systemctl enable mysqld $>>LOGFILE
VALIDATE $? "enabling my sql server"

systemctl start mysqld $>>LOGFILE
VALIDATE $? "starting my sql server"


mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up root password"
#
#mysql -h db-dev.devopsb78.tech -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
#
#if [ $? -ne 0 ]
#then
#  mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
#else
#  echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi