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
COPY apps/docs/package.json ./apps/docs/

# Устанавливаем зависимости (как обычно pnpm install)
RUN pnpm install --frozen-lockfile

# Копируем исходный код
COPY . .

# Собираем все приложения (как обычно pnpm build)
RUN pnpm build

# Этап production
FROM node:18-alpine AS production

# Устанавливаем pnpm
RUN npm install -g pnpm@9.0.0

WORKDIR /app

# Копируем package.json файлы
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ui/package.json ./packages/ui/
COPY apps/web/package.json ./apps/web/
COPY apps/docs/package.json ./apps/docs/

# Устанавливаем зависимости (включая dev для TypeScript)
RUN pnpm install --frozen-lockfile

# Копируем собранные приложения
COPY --from=base /app/apps/web/.next ./apps/web/.next
COPY --from=base /app/apps/web/public ./apps/web/public
COPY --from=base /app/apps/docs/.next ./apps/docs/.next
COPY --from=base /app/apps/docs/public ./apps/docs/public

# Копируем UI пакет исходники (TypeScript файлы)
COPY --from=base /app/packages/ui/src ./packages/ui/src

# Копируем необходимые конфигурационные файлы
COPY apps/web/next.config.js ./apps/web/
COPY apps/web/tsconfig.json ./apps/web/
COPY apps/docs/next.config.js ./apps/docs/
COPY apps/docs/tsconfig.json ./apps/docs/
COPY packages/ui/tsconfig.json ./packages/ui/

# Устанавливаем переменные окружения
ENV NODE_ENV=production

# Открываем порты для обоих приложений
EXPOSE 3000 3001

# Запускаем оба приложения
CMD ["pnpm", "start"]
