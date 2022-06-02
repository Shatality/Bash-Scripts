# Для отображения событий в правильное время, необходимо настроить его синхронизацию. Для этого установим chrony:
yes | yum install chrony
systemctl enable chronyd
systemctl start chronyd
# PROMETHEUS
# Скачиваем последнюю версию
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0-rc0/prometheus-2.35.0-rc0.linux-amd64.tar.gz
# Создаем каталоги для Prometheus
mkdir /etc/prometheus /var/lib/prometheus
# Распакуем наш архив
tar zxvf prometheus-*.linux-amd64.tar.gz
# Перейдем в каталог с распакованными файлами:
cd prometheus-*.linux-amd64
# Распределяем файлы по каталогам:
cp prometheus promtool /usr/local/bin/
cp -r console_libraries consoles prometheus.yml /etc/prometheus
# Назначение прав
# Создаем пользователя, от которого будем запускать систему мониторинга:
useradd --no-create-home --shell /bin/false prometheus
# Мы создали пользователя prometheus без домашней директории и без возможности входа в консоль сервера.
# Задаем владельца для каталогов, которые мы создали на предыдущем шаге:
chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
# Задаем владельца для скопированных файлов:
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
# Создаем systemd unit для удобного запуска Prometheus
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus Service
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
# Перечитываем конфигурацию systemd:
systemctl daemon-reload
# Разрешаем автозапуск:
systemctl enable prometheus
# После ручного запуска мониторинга, который мы делали для проверки, могли сбиться права на папку библиотек — снова зададим ей владельца:
chown -R prometheus:prometheus /var/lib/prometheus
# Запускаем службу:
systemctl start prometheus
# Проверяем, что она запустилась корректно:
systemctl status prometheus
# ALERTMANAGER
# Скачаем последнюю версию с официального сайта
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
# Установка
# Создаем каталоги для alertmanager:
mkdir /etc/alertmanager /var/lib/prometheus/alertmanager
# Распакуем наш архив:
tar zxvf alertmanager-*.linux-amd64.tar.gz
# Перейдем в каталог с распакованными файлами:
cd alertmanager-*.linux-amd64
# Распределяем файлы по каталогам:
cp alertmanager amtool /usr/local/bin/
cp alertmanager.yml /etc/alertmanager
# Назначение прав
# Создаем пользователя, от которого будем запускать alertmanager:
useradd --no-create-home --shell /bin/false alertmanager
# Мы создали пользователя alertmanager без домашней директории и без возможности входа в консоль сервера.
# Задаем владельца для каталогов, которые мы создали на предыдущем шаге:
chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/prometheus/alertmanager
# Задаем владельца для скопированных файлов:
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
# Автозапуск
# Создаем файл alertmanager.service в systemd:
cat > /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Alertmanager Service
After=network.target

[Service]
EnvironmentFile=-/etc/default/alertmanager
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
          --config.file=/etc/alertmanager/alertmanager.yml \
          --storage.path=/var/lib/prometheus/alertmanager \
          $ALERTMANAGER_OPTS
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
# Запускаем и проверяем статус alertmanager
systemctl start alertmanager
systemctl status alertmanager
systemctl enable alertmanager
# NODE EXPORTER
# Для получения метрик от операционной системы, установим и настроим node_exporter на тот же сервер
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
# Установка
# Распакуем скачанный архив:
tar zxvf node_exporter-*.linux-amd64.tar.gz
# Перейдем в каталог с распакованными файлами:
cd node_exporter-*.linux-amd64
# Копируем исполняемый файл в bin:
cp node_exporter /usr/local/bin/
# Назначение прав
# Создаем пользователя nodeusr:
useradd --no-create-home --shell /bin/false nodeusr
# Задаем владельца для исполняемого файла:
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter
# Создаем файл node_exporter.service в systemd:
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
# Далее изменяем главный конфигурационный файл
cat > /etc/prometheus/prometheus.yml <<EOF
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:9090']


  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']


  - job_name: 'apache_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9117']
EOF
# Перечитываем конфигурацию systemd:
systemctl daemon-reload
# Разрешаем автозапуск:
systemctl enable node_exporter
#Запускаем службу:
systemctl start node_exporter
systemctl status node_exporter
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
# Далее в панели Grafana > Import добавляем Apache Exporter ID: 3894
# Открываем веб-браузер и переходим по адресу http://<IP-адрес сервера или клиента>:9100/metrics — мы увидим метрики, собранные node_exporter
# GRAFANA
# Создаем файл конфигурации репозитория для Grafana:
cat > /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
# Импортируем gpg-key
rpm --import https://packages.grafana.com/gpg.key
# Теперь можно устанавливать:
yes | yum install grafana
# Запуск сервиса
# Разрешаем автозапуск:
systemctl enable grafana-server
# Запускаем:
systemctl start grafana-server