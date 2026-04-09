import os
nombre = os.environ.get("NOMBRE", "mundo")
print(f"Hola desde Docker, {nombre}!")
