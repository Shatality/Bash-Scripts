#!/bin/bash
# Добавляем модуль мониторнга статуса сервера Apache
cat > /etc/httpd/conf.d/server_status.conf <<EOF
<IfModule mod_status.c>
    ExtendedStatus On
  <Location /server-status>
    SetHandler server-status
    Allow from all
  </Location>
</IfModule>
EOF
# Перезапускаем Apache
systemctl restart httpd
# Далее загружаем Apache Exporter
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.11.0/apache_exporter-0.11.0.linux-amd64.tar.gz
# Распаковываем
tar xvf apache_exporter-0.11.0.linux-amd64.tar.gz
sudo cp apache_exporter-0.11.0.linux-amd64/apache_exporter /usr/local/bin
# Создаем systemd unit
cat > /etc/systemd/system/apache_exporter.service <<EOF
[Unit]
Description=ApacheExporter
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/apache_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
# Изменяем владельца файла:
chown -R prometheus:prometheus /usr/local/bin/apache_exporter
# Перечитываем конфигурацию systemd:
systemctl daemon-reload
# Разрешаем автозапуск:
systemctl enable apache_exporter
#Запускаем службу:
systemctl start apache_exporter
# Добавляем в файл
# Добавляем в файл
# sudo vi /etc/prometheus/prometheus.yml
#
#  - job_name: 'apache_exporter'
#    scrape_interval: 5s
#    static_configs:
#      - targets: ['localhost:9117']
# Далее в панели Grafana > Import добавляем Apache Exporter ID: 3894