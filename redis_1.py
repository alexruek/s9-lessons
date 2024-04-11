import redis

def main():
    host = 'c-c9q3a9espn0n9cbpu253.rw.mdb.yandexcloud.net'
    port = 6380
    password = 'victor191146'
    ca_path = '/Users/sasha/.redis/YandexInternalRootCA.crt'

    client = redis.StrictRedis(
            host=host,
            port=port,
            password=password,
            ssl=True,
            ssl_ca_certs=ca_path)

    # Получаем значение для нескольких ключей
    keys = ["ef8c42c19b7518a9aebec106", "626a81ce9a8cd1920641e264"]
    results = client.mget(keys)

    # Проверяем каждый результат и декодируем его
    for result in results:
        if result is not None:
            print(result.decode("utf-8"))
        else:
            print("Запись с указанным ключом не найдена.")

if __name__ == '__main__':
    main()
