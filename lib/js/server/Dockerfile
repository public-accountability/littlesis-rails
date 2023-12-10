FROM docker.io/library/node:18
ENV LITTLESIS_JS_HOST 0.0.0.0
ENV LITTLESIS_JS_PORT 8888
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 8888
CMD [ "node", "index.js" ]
