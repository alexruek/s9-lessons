# Используем базовый образ Ubuntu
FROM ubuntu:latest

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y ca-certificates kafkacat

# Копируем ваш CA сертификат в контейнер
COPY YandexInternalRootCA.crt /usr/local/share/ca-certificates/Yandex/YandexInternalRootCA.crt

# Обновляем список CA сертификатов в системе
RUN update-ca-certificates

# Дополнительные настройки для kcat / kafkacat, если необходимо
