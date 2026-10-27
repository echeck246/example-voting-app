FROM node:18.19.1-alpine3.19
# add curl for healthcheck

WORKDIR /usr/local/app

ENV NODE_ENV=production

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

COPY --chown=node:node . .

USER node

ENV PORT=80
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
