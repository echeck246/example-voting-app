FROM node:18.19.1-alpine3.19

# Install tini and curl for health checks
RUN apk add --no-cache tini curl

WORKDIR /usr/local/app

ENV NODE_ENV=production

COPY package*.json ./

RUN npm ci && \
    npm cache clean --force && \
    mv /usr/local/app/node_modules /node_modules

COPY --chown=node:node . .

USER node

ENV PORT=80
EXPOSE 80

CMD ["node", "server.js"]
