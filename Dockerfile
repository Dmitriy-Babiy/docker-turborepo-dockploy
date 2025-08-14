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

# Собираем только веб-приложение и UI пакет
RUN pnpm --filter=web build
RUN pnpm --filter=@repo/ui build

# Этап production
FROM node:18-alpine AS production

# Устанавливаем pnpm
RUN npm install -g pnpm@9.0.0

WORKDIR /app

# Копируем package.json файлы
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ui/package.json ./packages/ui/
COPY apps/web/package.json ./apps/web/

# Устанавливаем только production зависимости
RUN pnpm install --frozen-lockfile --prod

# Копируем собранное приложение
COPY --from=base /app/apps/web/.next ./apps/web/.next
COPY --from=base /app/apps/web/public ./apps/web/public

# Копируем UI пакет
COPY --from=base /app/packages/ui/dist ./packages/ui/dist

# Копируем необходимые конфигурационные файлы
COPY apps/web/next.config.js ./apps/web/
COPY apps/web/tsconfig.json ./apps/web/

# Устанавливаем переменные окружения
ENV NODE_ENV=production
ENV PORT=3000

# Открываем порт
EXPOSE 3000

# Переходим в директорию веб-приложения
WORKDIR /app/apps/web

# Запускаем приложение
CMD ["pnpm", "start"]