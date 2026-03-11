FROM python:3.11-slim

WORKDIR /app

# Копируем зависимости первыми (кэш Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь проект
COPY . .

# Порт
EXPOSE 5000

# Production: gunicorn вместо flask dev server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "60", "app:app"]
