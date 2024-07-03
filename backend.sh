
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

dnf module disable nodejs -y
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enable nodejs:20"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"

id expense
if [ $? -ne 0 ]
then
  useradd expense &>>LOGFILE
  VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi





mkdir /app