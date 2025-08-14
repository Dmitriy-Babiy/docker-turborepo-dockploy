FROM node:18.20.2-alpine AS build
WORKDIR /app
COPY . .

RUN npm install -g pnpm
RUN pnpm install
RUN pnpm run build

FROM nginx:stable-alpine

COPY --from=build /app/apps/web/.next /apps/web/public
COPY --from=build /app/apps/docs/.next /apps/docs/public
COPY --from=build /app/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000 3001

HEALTHCHECK CMD (curl --fail http://localhost:3000 && curl --fail http://localhost:3001) || exit 1

CMD ["nginx", "-g", "daemon off;"]