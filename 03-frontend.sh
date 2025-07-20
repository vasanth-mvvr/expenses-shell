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
}

if [ $USERID -ne 0 ]
then 
    echo "you are not super user"
    exit 1
else 
    echo "you are super user"
fi

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabled nginx"

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installed nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Started nginx"

rm -rf /usr/share/nginx/html* &>>$LOGFILE
VALIDATE $? "Removed the default content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Received frontend file"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "unzipped the files"

cp /home/ec2-user/repos/expense.conf /etc/nginx/system.d/expense.conf  &>>$LOGFILE
VALIDATE $? "Proxy Created"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarted successfully"