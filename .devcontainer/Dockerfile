FROM alpine:3.20.1

RUN apk update

#Install required tools for terraform
RUN apk add wget unzip libc6-compat

#Install terraform
ENV TERRAFORM_VERSION=1.9.1
RUN wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/
RUN chmod +x /usr/local/bin/terraform
RUN rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

#Install AWS CLI
RUN apk add aws-cli

RUN apk add nodejs
RUN apk add npm

CMD tail -f /dev/null