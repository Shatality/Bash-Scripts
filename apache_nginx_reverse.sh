#!/bin/bash
# УСТАНАВЛИВАЕМ NGINX
# Добавьте EPEL-репозиторий# Добавьте EPEL-репозиторий
yes | yum install epel-release
# Импортируем RPM-GPG ключи
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
# Установите Nginx:
yes | yum install nginx
# УСТАНАВЛИВАЕМ APACHE
# Обновляем пакет Apache httpd:
yes | yum update httpd
# Установливаем пакеты Apache:
yes | yum install httpd
# Изменяем порт на 8080, так как на 80 у нас уже работает Nginx
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
# НАСТРАИВАЕМ БАЛАНСИРОВКУ
# Заменяем дефолтный конфиг nginx
cd /etc/nginx/
rm -f nginx.conf
wget https://raw.githubusercontent.com/Shatality/Config-Backups/main/nginx.conf
# Настраиваем upstream
cd /etc/nginx/conf.d
wget https://raw.githubusercontent.com/Shatality/Config-Backups/main/upstream.conf
# Настраиваем virtual hosts
cd /etc/httpd/conf.d
rm -f welcome.conf
wget https://raw.githubusercontent.com/Shatality/Config-Backups/main/welcome.conf
# Создаем файлы index.html
cd /var/www/html
echo "<h1> Welcome 8080 <h1>" > index.html
mkdir /var/www/html1
cd /var/www/html1
echo "<h1> Welcome 8081 <h1>" > index.html
mkdir /var/www/html2
cd /var/www/html2
echo "<h1> Welcome 8082 <h1>" > index.html
# Добавляем error logs
touch /var/log/httpd/error1.log /var/log/httpd/error2.log
# Добавляем права на директории с index файлами
chmod 755 -R /var/www
# Отключаем selinux
setenforce 0
# Остагавливаем firewall
systemctl stop firewalld
# Запускаем Nginx:
systemctl start nginx
# Проверяем статус службы Nginx:
systemctl status nginx
# Настраиваем автозапуск Nginx при перезагрузке системы:
systemctl enable nginx
# Запускаем Apache:
systemctl start httpd
# Проверяем статус службы Apache
systemctl status httpd
# Включаем автозагрузку Apache:
systemctl enable httpd