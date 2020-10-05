FROM node:14.10.1-alpine3.11
WORKDIR /uniroster-server
COPY . .
EXPOSE 80
CMD ["npm", "start"]