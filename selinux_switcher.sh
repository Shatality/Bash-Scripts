#!/bin/bash

Condition=$(/usr/sbin/getenforce)
ConditionConf=/etc/selinux/config
File=/home/adminroot/test

echo -en "\033[37;1;41m Selinux Switcher \033[0m"
echo ""

#Проверяем является ли владельцем файла текущий пользователь
if [ -O $File ]
then
  echo "Вы являетесь владельцем скрипта. Только владелец может запускать данный скрипт."
else
  echo "Вы не являетесь владельцем скрипта. Только владелец может запускать данный скрипт. Попросите владельца выдать вам права на чтение и выполнение"
fi

#Поверяем включена ли Selinux
echo ""
if [ $Condition = Disabled ]
then
  echo "Selinux выключена"
elif [ $Condition = Permissive ]
then
  echo "Selinux в режиме permissive"
else
  echo "Selinux включена"
fi

#Проверяем включена ли Selinux в конфигурационном файле
if cat $ConditionConf | grep -iq "SELINUX=disabled"
then
  echo "Selinux выключена в конфигурационном файле"
else
  echo "Selinux включена в конфигурационном файле"
fi

#Режим диалога с пользователем
echo ""
echo "1. Включить Selinux?"
echo "2. Включить Selinux в конфигурационном файле?"
echo "3. Выключить Selinux?"
echo "4. Выключить Selinux в конфигурационном файле?"

echo ""
echo "Введите значение:"
read Value
if [ $Value = "1" ]
then
  sudo setenforce 1
  echo "Selinux включен"
elif [ $Value = "2" ]
then
  sudo sed -i 's/SELINUX=disabled/SELINUX=enforcing/' $ConditionConf
  echo "Selinux включена в конфигурационном файле"
elif [ $Value = "3" ]
then
  sudo setenforce 0
  echo "Selinux выключен"
elif [ $Value = "4" ]
then
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' $ConditionConf
  echo "Selinux выключена в конфигурационном файле"
else
  exit
fi
