.PHONY: build test run stop clean deploy health

# Переменные
IMAGE_NAME = user-crud-app
CONTAINER_NAME = user-crud-app
PORT = 8034

# Сборка Docker образа (2-stage build)
build:
	@echo "🔨 Building Docker image with multi-stage build..."
	docker build -t $(IMAGE_NAME) .
	@echo "✅ Image built successfully"
	@docker images $(IMAGE_NAME) --format "📦 Image size: {{.Size}}"

# Запуск тестов в контейнере
test:
	@echo "🧪 Running tests in container..."
	docker run --rm \
		--network host \
		-e DATABASE_URL=postgresql+psycopg://kubsu:kubsu@127.0.0.1:5432/kubsu \
		$(IMAGE_NAME) \
		pytest tests/ -v

# Запуск контейнера
run:
	@echo "🚀 Starting container..."
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(PORT):$(PORT) \
		--restart unless-stopped \
		$(IMAGE_NAME)
	@echo "✅ Container started on port $(PORT)"
	@sleep 3
	@make health

# Остановка контейнера
stop:
	@echo "🛑 Stopping container..."
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

# Очистка
clean: stop
	@echo "🧹 Cleaning up..."
	docker rmi $(IMAGE_NAME) || true
	docker system prune -f

# Проверка health
health:
	@echo "🏥 Health check:"
	curl -f http://localhost:$(PORT)/health || echo "❌ Health check failed"

# Полный деплой (пересборка и запуск)
deploy: stop build run
	@echo "🎉 Deployment completed!"

# Логи
logs:
	docker logs -f $(CONTAINER_NAME)

# Интерактивная оболочка
shell:
	docker run --rm -it $(IMAGE_NAME) /bin/bash

# Проверка размера образа
size:
	@docker images $(IMAGE_NAME) --format "📦 Image size: {{.Size}}"
