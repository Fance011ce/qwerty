#!/bin/bash

set -e  # Останавливаемся при ошибке

echo "========================================="
echo "🚀 Starting deployment process..."
echo "========================================="

# Проверяем Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    exit 1
fi

# Проверяем PostgreSQL доступность
echo "📡 Checking PostgreSQL..."
if ! pg_isready -h localhost -p 5432 -U kubsu; then
    echo "⚠️  PostgreSQL is not running, trying to start..."
    sudo service postgresql start || echo "Please start PostgreSQL manually"
fi

# Собираем образ
echo "🔨 Building Docker image (multi-stage)..."
docker build -t user-crud-app:latest .

# Проверяем размер
echo "📦 Image size:"
docker images user-crud-app:latest --format "{{.Size}}"

# Запускаем тесты
echo "🧪 Running tests..."
docker run --rm \
    --network host \
    -e DATABASE_URL=postgresql+psycopg://kubsu:kubsu@127.0.0.1:5432/kubsu \
    user-crud-app:latest \
    pytest tests/ -v

if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Deployment aborted."
    exit 1
fi

# Останавливаем старый контейнер
echo "🛑 Stopping old container..."
docker stop user-crud-app || true
docker rm user-crud-app || true

# Запускаем новый
echo "🚀 Starting new container..."
docker run -d \
    --name user-crud-app \
    -p 60080:60080 \
    --restart unless-stopped \
    user-crud-app:latest

# Ждем запуска
sleep 5

# Проверяем health
echo "🏥 Checking health..."
if curl -f http://localhost:60080/health; then
    echo "✅ Application is healthy!"
else
    echo "❌ Health check failed!"
    docker logs user-crud-app --tail 20
    exit 1
fi

echo "========================================="
echo "🎉 Deployment successful!"
echo "🌐 App is running at: http://kubsu.tyvik.ru:60080"
echo "========================================="

# Показываем логи
docker logs user-crud-app --tail 10
