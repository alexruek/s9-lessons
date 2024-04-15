import json
from typing import Dict
import redis


class RedisClient:
    def __init__(self, host: str, port: int, password: str, cert_path: str) -> None:
        self._client = redis.StrictRedis(
            host=host,
            port=port,
            password=password,
            ssl=True,
            ssl_ca_certs=cert_path
        )

    def set(self, k: str, v: dict) -> None:
            """Сериализует словарь в строку JSON и сохраняет в Redis."""
            try:
                v_json = json.dumps(v)
                self._client.set(k, v_json)
            except TypeError as e:
                print(f"Ошибка при сериализации данных: {e}")

    def get(self, k: str) -> dict:
        """Извлекает строку из Redis, десериализует её в словарь и возвращает."""
        v_json = self._client.get(k)
        if v_json:
            try:
                return json.loads(v_json)
            except json.JSONDecodeError as e:
                print(f"Ошибка при десериализации данных: {e}")
                return {}  # Возвращаем пустой словарь в случае ошибки
        else:
            return {}  # Если ключ не найден, возвращаем пустой словарь