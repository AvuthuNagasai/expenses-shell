
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB password:"
read -s mysql_root_password

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

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Installing nodejs"

id expense
if [ $? -ne 0 ]
then
  useradd expense &>>LOGFILE
  VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading the code"

cd /app

unzip /tmp/backend.zip &>>LOGFILE
VALIDATE $? "unzipping the content"

cd /app &>>LOGFILE

npm install &>>LOGFILE

cp /home/ec2-user/expenses-shell/backend.service  /etc/systemd/system/backend.service
VALIDATE $? "SystemD Expense Backend Service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "daemon-reload"
systemctl start backend &>>LOGFILE
VALIDATE $? "starting backend"
systemctl enable backend &>>LOGFILE
VALIDATE $? "enabling backend"

mysql -h db-dev.devopsb78.tech -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>LOGFILE
VALIDATE $? "loading schema"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restarting backend"

