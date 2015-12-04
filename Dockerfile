# Set node base image
FROM node:0.12

MAINTAINER fpt-softwre

# Define working directory
RUN mkdir -p /var/seniot/
# install node-red from seniot/ repository
WORKDIR /var/seniot
ADD . /var/seniot
RUN mkdir -p /var/seniot/awsCerts
VOLUME ["/var/seniot/awsCerts"]

RUN git clone https://github.com/fpt-software/seniot-data-workflow.git /var/seniot/workflow
#RUN git clone https://github.com/node-red/node-red-nodes.git /var/seniot/workflow/nodes/node-red-nodes
RUN git clone https://github.com/fpt-software/seniot-gateway.git /var/seniot/gateway/

RUN cd /var/seniot/workflow/ \
	&& git pull \
	&& git fetch --tags \
	&& git tag \
	&& git checkout -b v0.1.1 v0.1.1 \
	&& npm install \
	&& npm update \
	&& npm install -g grunt-cli \
	&& grunt build

#RUN cd /var/seniot/workflow/nodes/node-red-nodes/ \
#	&& git pull \
#	&& git fetch --tags \
#	&& git tag \
#	&& git checkout -b v0.1.1 v0.1.1 \
#	&& npm install \
#	&& npm update

#symlink to seniot nodes
RUN ln -s /var/seniot/gateway/nodes /var/seniot/workflow/nodes/seniot-nodes

#install aws-iot
	RUN cd /var/seniot/workflow/nodes/seniot-nodes/aws-iot \
	    && npm install
	    && cd /var/seniot/workflow/nodes/seniot-nodes/azure-iot \
	    && npm install

#install freeboard.io
	RUN cd /var/seniot/workflow \
	    && npm install node-red-contrib-freeboard

# expose port
EXPOSE 1880

# Run app using nodemon
WORKDIR /var/seniot/workflow
CMD ["node", "/var/seniot/workflow/red.js"]
