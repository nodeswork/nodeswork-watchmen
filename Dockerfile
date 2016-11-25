FROM node:7.2.0
# FROM node:argon

RUN mkdir /root/.ssh && chmod 700 /root/.ssh
RUN ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts
RUN ssh-keyscan -t rsa 35.162.34.221 > /root/.ssh/known_hosts

COPY MMM.pem /root/
RUN chmod 600 /root/MMM.pem

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install


# Bundle app source
COPY . /usr/src/app


EXPOSE 5555

# It's kind of hacky, but we need to setup SSH tunnel to database and start the service
CMD ssh -f -i /root/MMM.pem -L 27017:localhost:27017 -N ec2-user@35.162.34.221 -o StrictHostKeyChecking=no && npm start
