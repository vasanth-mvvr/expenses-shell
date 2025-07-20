#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%I:%M:%S-%p)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

# echo "please enter the password"
# read -s my_sql_password

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 $R Failed $N"
    else
        echo -e "$2 $G Success $N"
    fi
}

if [ $USERID -ne 0 ]
then 
    echo -e " $Y You need to have super user access $N"
    exit 1
else 
    echo "you are super user"
fi


dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling service of mysql-server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting service of mysql-server"

#Here the disadvantage is that once we set up the password it cannot be repeated and we should make sure that it is idempotent in nature in the shell script .
#Idempotent means how many ever times you run it should of be the same.

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "Setting up the root password"

# mysql -h db.vasanthreddy.space -uroot -p${my_sql_password} -e 'SHOW DATABASES;' &>>$LOGFILE
# if [ $? -ne 0 ]
# then 
#     mysql_secure_installation --set-root-pass ${my_sql_password}
#     VALIDATE $? "Password setup " &>>$LOGFILE
# else
#     echo -e "Password is already set .. $Y Skipping $N"
# fi
