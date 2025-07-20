#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(+date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
LOG=&>>$LOGFILE

R="\e[31m"
G="\[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [$1 -ne 0 ]
    then 
        echo -e "$2 $R Failed $N"
    else
        echo -e "$2 $G Success $N"
    fi
}

if [ $USERID -ne 0 ]
then 
    echo -e " $Y You need to have super user access $N"
else 
    echo "you are super user"
fi


dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enabling mysqld &>>$LOGFILE
VALIDATE $? "Enabling service of mysql-server"

systemctl start mysqld &>>$LOG
VALIDATE $? "Starting service of mysql-server"

#Here the disadvantage is that once we set up the password it cannot be repeated and we should make sure that it is idempotent in nature in the shell script .
#Idempotent means how many ever times you run it should of be the same.

# mysql_secure_installation --set-root-pass ExpenseApp@1 $LOG
# VALIDATE $? "Setting up the root password"

mysql -h 172.31.85.69 -uroot -p${my_sql_password} -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${my_sql_password}
    VALIDATE $? "Password setuped successfully" &>>$LOGFILE
else
    echo -e "Password is already set .. $Y Skipping $N"
fi
