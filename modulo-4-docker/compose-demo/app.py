import redis
import os

host = os.environ.get("REDIS_HOST", "localhost")
r = redis.Redis(host=host, port=6379)

r.incr("visitas")
visitas = r.get("visitas").decode("utf-8")
print(f"Total visits: {visitas}")
