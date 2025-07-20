#!/bin/bash

# USERID=$(id -u)
# TIMESTAMP=$(date +%F-%I:%H:%M-%p)
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
# LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# echo "Please enter the password"
# read -s my_sql_password

# VALIDATE(){
#     if [ $1 -ne 0 ]
#     then 
#         echo -e "$2  $R Failed $N"
#         exit 1
#     else 
#         echo -e "$2 $G Success $N"
#     fi
# }

# if [ $USERID -ne 0 ]
# then 
#     echo "you are not super user"
#     exit 1
# else 
#     echo "you are super user"
# fi

# dnf module disable nodejs -y &>>$LOGFILE
# VALIDATE $? "Disabled nodejs"

# dnf module enable nodejs:20 -y &>>$LOGFILE
# VALIDATE $? "Enabled nodejs version --20" 

# dnf install nodejs -y &>>$LOGFILE
# VALIDATE $? "Installed nodejs successfully"

# id=expense &>>$LOGFILE
# if [ $id -ne 0 ]
# then 
#     useradd expense &>>$LOGFILE
#     VALIDATE $? "user added successfully"
# else
#     echo -e "User is already created $Y Skipping $N"
# fi

# mkdir -p /app &>>$LOGFILE #Here -p is used for validating if the directory is present it ignores or else it creates a new directory
# VALIDATE $? "directory created successfully"

# curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
# VALIDATE $? "Extracted backend code"

# cd /app
# rm -rf /app/* &>>$LOGFILE
# unzip /tmp/backend.zip &>>$LOGFILE
# VALIDATE $? "Extracted file successfully"

# npm install &>>$LOGFILE
# VALIDATE $? "Installed dependencies"

# cp /home/ec2-user/expenses-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
# VALIDATE $? "backend.service intiated successfully"

# systemctl daemon-reload &>>$LOGFILE
# VALIDATE $? "deamon-reload backend"

# systemctl start backend &>>$LOGFILE
# VALIDATE $? "Started backend"

# systemctl enable backend &>>$LOGFILE
# VALIDATE $? "Enabled backend"

# dnf install mysql -y &>>$LOGFILE
# VALIDATE $? "Installed mysql"

# mysql -h db.vasanthreddy.space -uroot -p${my_sql_password} < /app/schema/backend.sql &>>$LOGFILE
# VALIDATE $? "Schema loaded"

# systemctl restart backend &>>$LOGFILE
# VALIDATE $? "Restarted mysql"


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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

#check your repo and path
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Client"

mysql -h db.daws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"