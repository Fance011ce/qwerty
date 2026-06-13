#!/bin/bash

echo "🚀 Deploying without Docker..."

# Устанавливаем зависимости
pip3 install --user fastapi uvicorn sqlalchemy asyncpg psycopg2-binary pytest

# Останавливаем старый процесс
pkill -f "uvicorn src.main:app" || true

# Запускаем приложение
cd ~/tasks/docker
nohup python3 -m uvicorn src.main:app --host 0.0.0.0 --port 8034 > app.log 2>&1 &

sleep 3

# Проверяем
curl http://localhost:8034/health

echo "✅ Deployed!"
