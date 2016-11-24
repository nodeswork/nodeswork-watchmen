FROM node:7.2.0
# FROM node:argon

RUN mkdir /root/.ssh && chmod 700 /root/.ssh
RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

EXPOSE 5555
CMD [ "npm", "start" ]
