# Docker инструкции для izifinance-monorepo

## Сборка и запуск

### Способ 1: Docker Compose (рекомендуется)

```bash
# Собрать и запустить приложение
docker-compose up --build

# Запустить в фоновом режиме
docker-compose up -d --build

# Остановить приложение
docker-compose down
```

### Способ 2: Docker команды

```bash
# Собрать образ
docker build -t izifinance-web .

# Запустить контейнер
docker run -p 3000:3000 --name izifinance-web izifinance-web

# Остановить и удалить контейнер
docker stop izifinance-web
docker rm izifinance-web
```

## Особенности Dockerfile

- **Многоэтапная сборка**: Использует два этапа для оптимизации размера образа
- **pnpm**: Использует pnpm для управления зависимостями (как указано в package.json)
- **Turbo**: Поддерживает монорепозиторий с Turbo
- **Next.js**: Оптимизирован для Next.js приложения
- **Production**: Настроен для production окружения

## Переменные окружения

- `NODE_ENV=production`
- `PORT=3000`

## Порт

Приложение доступно на порту 3000 (http://localhost:3000)

## Health Check

Docker Compose включает health check, который проверяет доступность приложения каждые 30 секунд.

## Оптимизация

- `.dockerignore` исключает ненужные файлы
- Используется Alpine Linux для уменьшения размера образа
- Кэширование слоев Docker для ускорения повторных сборок
