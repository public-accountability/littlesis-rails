FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 8888
CMD [ "node", "index.js" ]
