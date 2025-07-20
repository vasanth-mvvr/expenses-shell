#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%I:%H:%M-%p)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2  $R Failed $N"
        exit 1
    else 
        echo -e "$2 $G Success $N"
        fi
}

if [ $USERID -ne 0 ]
then 
    echo "you are not super user"
    exit 1
else 
    echo "you are super user"
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installed nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabled nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Started nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removed the default content"

curl -o /home/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Received frontend file"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /home/frontend.zip &>>$LOGFILE
VALIDATE $? "unzipped the files"

cp /home/ec2-user/expenses-shell/expense.conf /etc/nginx/system.d/expense.conf  &>>$LOGFILE
VALIDATE $? " copied"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarted successfully"