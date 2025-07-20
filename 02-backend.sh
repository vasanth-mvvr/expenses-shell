#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%I:%H:%M-%p)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter the password"
read -s my_sql_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2  $R Failed $N"
    else 
        echo -e "$2 $G Success $N"
        fi
}

if [ $USERID -ne 0 ]
then 
    echo "you are not super user"
else 
    echo "you are super user"
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabled nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabled nodejs version --20" 

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installed nodejs successfully"

id expense &>>$LOGFILE
if [ $id -ne 0 ]
then 
    useradd expense &>>$LOGFILE
    VALIDATE $? "user added successfully"
else
    echo "User is already created $Y Skipping $N"
fi

mkdir -p /app &>>$LOGFILE #Here -p is used for validating if the directory is present it ignores or else it creates a new directory
VALIDATE $? "directory created successfully"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

cd /app
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted file successfully"

npm install &>>$LOGFILE
VALIDATE $? "Installed dependencies"

cp /home/ec2-user/expenses-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "backend.service intiated successfully"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "deamon-reload backend"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Started backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabled backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installed mysql"

mysql -h db.vasanthreddy.space -uroot -p${my_sql_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loaded"

systemctl restart mysql &>>$LOGFILE
VALIDATE $? "Restarted mysql"


