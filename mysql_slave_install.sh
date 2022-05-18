#!/bin/bash
yes | yum install https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
# Добавляем ключ
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
# Устанавливаем MySQL
yes | yum install mysql-community-server
# Запускаем MySQL
systemctl start mysqld
# Смотрим временный пароль
grep 'temporary password' /var/log/mysqld.log
# Запускаем скрипт безопасности
mysql_secure_installation
# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld
# НАСТРОЙКА SLAVE
# Добавляем server-id
echo "server-id=2" >> /etc/my.cnf
echo "show_compatibility_56=1" >> /etc/my.cnf
# Добавляем данные клиента чтобы входить без запроса пароля
cat > ~/.my.cnf <<EOF
[client]
user=root
password=JackBob5000@!
EOF
# Перезапускаем сервер
systemctl restart mysqld
# Добавляем MySQL в автозагрузку
systemctl enable mysqld
MasterUser="repl"
MasterPassword="oTUSlave#2020"
read -p "Enter MASTER HOST:" MasterHost
read -p "Enter MASTER LOG FILE:" MasterLogFile
read -p "Enter MASTER LOG POS:" MasterLogPos
mysql -e"CHANGE MASTER TO MASTER_HOST='$MasterHost', MASTER_USER='$MasterUser', MASTER_PASSWORD='$MasterPassword', MASTER_LOG_FILE='$MasterLogFile', MASTER_LOG_POS=$MasterLogPos;"
mysql -e"START SLAVE;"
mysql -e"SHOW SLAVE STATUS\G;"

