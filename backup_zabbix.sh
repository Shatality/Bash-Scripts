#!/bin/bash

#Создаем каталог Backup со вложенными каталогами и назначаем права
sudo mkdir -p /backup/zabbix_server/etc_zabbix/ /backup/zabbix_server/usr_share_zabbix && chmod -R 777 /backup

#Копируем конфигурационные файлы Zabbix
sudo cp -a /etc/zabbix/ /backup/zabbix_server/etc_zabbix
sudo cp -a /usr/share/zabbix/ /backup/zabbix_server/usr_share_zabbix
 
#Останавливаем zabbix server
sudo systemctl stop zabbix-server

#Даем zabbix server остановиться
sleep 5
 
#Делаем выгрузку mysql dump
sudo mysqldump -u root -p zabbix > /backup/zabbix_server/zabbix_dump.sql
 
#Запускаем zabbix server
sudo systemctl start zabbix-server