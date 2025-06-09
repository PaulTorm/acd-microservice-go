FROM node:alpine AS build

WORKDIR /frontend
COPY . .

RUN corepack enable
RUN pnpm install
RUN pnpm build:production

FROM nginx:latest

COPY --from=build /frontend/dist/frontend /usr/share/nginx/html
COPY /nginx.conf /etc/nginx/conf.d/default.conf
