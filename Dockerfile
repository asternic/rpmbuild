# Using CentOS 8 as base image to support rpmbuild (packages will be Dist el8)
FROM centos:8

# Copying all contents of rpmbuild repo inside container
#COPY . .
#RUN mkdir /lib
RUN mkdir /src
COPY .gitignore .
COPY .prettierrc.json .
COPY package.json .
COPY tsconfig.json .
COPY jest.config.js .
COPY action.yml .
COPY src/main.ts ./src/
COPY lib/download-release-archive.js ./lib/
COPY lib/main.js ./lib/

RUN sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*

RUN sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*

RUN dnf clean all

# RUN dnf -y swap centos-linux-repos centos-stream-repos

# Installing tools needed for rpmbuild , 
# depends on BuildRequires field in specfile, (TODO: take as input & install)
RUN yum install -y --skip-broken rpm-build rpmdevtools gcc make coreutils python36 git php php-cli yum-utils autoconf gcc-c++ automake m4 libtool libpcap-devel dotconf-devel libnetfilter_queue-devel libnfnetlink-devel openssl-devel ldns-devel

# Setting up node to run our JS file
# Download Node Linux binary
#RUN curl -O https://nodejs.org/dist/v12.16.1/node-v12.16.1-linux-x64.tar.xz
RUN curl -O https://nodejs.org/dist/v18.4.0/node-v18.4.0-linux-x64.tar.xz
#RUN curl -O https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz

# Extract and install
RUN tar --strip-components 1 -xvf node-v* -C /usr/local

# Install all dependecies to execute main.js
RUN npm install typescript
RUN npm i --save-dev @types/node
RUN npm install --production --package-lock-only && npm run-script build
#RUN npm ci 
#RUN npm run-script build

# All remaining logic goes inside main.js , 
# where we have access to both tools of this container and 
# contents of git repo at /github/workspace
ENTRYPOINT ["node", "/lib/main.js"]
