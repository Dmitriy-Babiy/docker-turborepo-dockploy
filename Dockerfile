FROM node:18.20.2-alpine AS build
WORKDIR /app
COPY . .

RUN pnpm install
RUN pnpm run build

EXPOSE 3000 3001
HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
CMD ["pnpm", "start"]
