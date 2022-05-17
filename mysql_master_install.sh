#!/bin/bash
yes | yum install https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
# Добавляем ключ
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
# Устанавливаем MySQL
yes | yum install mysql-community-server
# Запускаем MySQL
systemctl start mysqld
# Добавляем MySQL в автозагрузку
systemctl enable mysqld
# Смотрим временный пароль
grep 'temporary password' /var/log/mysqld.log
# Запускаем скрипт безопасности
yes | mysql_secure_installation
# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld
# Меняем server-id и влючаем bin-log
echo "server-id=1" >> /etc/my.cnf
echo "log-bin=mysql-bin" >> /etc/my.cnf
# Заходим в MySQL с новым паролем
cat > ~/.my.cnf << EOF
[client]
user=root
password=JackBob5000@!
EOF
# НАСТРОЙКА MASTER
# Создаём пользователя для реплики
mysql -e"CREATE USER repl@'%' IDENTIFIED WITH 'mysql_native_password' BY 'oTUSlave#2020';"
# Даём ему права на репликацию
mysql -e"GRANT REPLICATION SLAVE ON *.* TO repl@'%';"
# Перезапускаем сервер
systemctl restart mysqld
# Смотрим статус Мастера
mysql -e"SHOW MASTER STATUS;"