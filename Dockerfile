# Используем официальный Node.js образ с pnpm
FROM node:18-alpine AS base

# Устанавливаем pnpm
RUN npm install -g pnpm@9.0.0

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы конфигурации пакетов
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ui/package.json ./packages/ui/
COPY apps/web/package.json ./apps/web/

# Устанавливаем зависимости
RUN pnpm install --frozen-lockfile

# Копируем исходный код
COPY . .

# Собираем только веб-приложение
RUN pnpm --filter=web build

# Этап production
FROM node:18-alpine AS production

# Устанавливаем pnpm
RUN npm install -g pnpm@9.0.0

WORKDIR /app

# Копируем package.json файлы
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ui/package.json ./packages/ui/
COPY apps/web/package.json ./apps/web/

# Устанавливаем зависимости (включая dev для TypeScript)
RUN pnpm install --frozen-lockfile

# Копируем собранное веб-приложение
COPY --from=base /app/apps/web/.next ./apps/web/.next
COPY --from=base /app/apps/web/public ./apps/web/public

# Копируем UI пакет исходники (TypeScript файлы)
COPY --from=base /app/packages/ui/src ./packages/ui/src

# Копируем необходимые конфигурационные файлы
COPY apps/web/next.config.js ./apps/web/
COPY apps/web/tsconfig.json ./apps/web/
COPY packages/ui/tsconfig.json ./packages/ui/

# Устанавливаем переменные окружения
ENV NODE_ENV=production

# Открываем порт только для веб-приложения
EXPOSE 3000

# Создаем скрипт для запуска веб-приложения
RUN echo '#!/bin/sh\n\
cd /app/apps/web && PORT=3000 pnpm start' > /app/start.sh && chmod +x /app/start.sh

# Запускаем веб-приложение
CMD ["/app/start.sh"]