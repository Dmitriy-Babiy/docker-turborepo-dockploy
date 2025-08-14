FROM node:18.20.2-alpine AS build
WORKDIR /app

# Устанавливаем необходимые зависимости
RUN apk add --no-cache curl

# Копируем файлы конфигурации
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json ./apps/web/
COPY apps/docs/package.json ./apps/docs/
COPY packages/ui/package.json ./packages/ui/
COPY packages/eslint-config/package.json ./packages/eslint-config/
COPY packages/typescript-config/package.json ./packages/typescript-config/

# Устанавливаем pnpm и зависимости
RUN npm install -g pnpm
RUN pnpm install

# Копируем исходный код
COPY . .

# Собираем приложения
RUN pnpm run build

# Создаем production образ
FROM node:18.20.2-alpine AS production
WORKDIR /app

# Устанавливаем curl для healthcheck
RUN apk add --no-cache curl

# Копируем собранные приложения и зависимости
COPY --from=build /app/apps/web/.next ./apps/web/.next
COPY --from=build /app/apps/web/public ./apps/web/public
COPY --from=build /app/apps/docs/.next ./apps/docs/.next
COPY --from=build /app/apps/docs/public ./apps/docs/public
COPY --from=build /app/package.json ./
COPY --from=build /app/apps/web/package.json ./apps/web/
COPY --from=build /app/apps/docs/package.json ./apps/docs/
COPY --from=build /app/pnpm-lock.yaml ./
COPY --from=build /app/pnpm-workspace.yaml ./

# Устанавливаем только production зависимости
RUN npm install -g pnpm
RUN pnpm install --prod

# Копируем скрипт запуска
COPY start.sh ./
RUN chmod +x start.sh

# Открываем порты
EXPOSE 3000 3001

# Healthcheck для проверки доступности приложений
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl --fail http://localhost:3000 && curl --fail http://localhost:3001 || exit 1

# Запускаем скрипт
CMD ["./start.sh"]
