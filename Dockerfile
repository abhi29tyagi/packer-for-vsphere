FROM ubuntu:20.04
LABEL maintainer="abhi29tyagi@gmail.com"
ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update --fix-missing && apt-get -y install apt-utils tzdata curl gnupg2 lsb-release software-properties-common mkisofs

# install packer
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - &&\
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" &&\
    apt-get update && apt-get install packer

# copy everything to container
COPY http/ /sw-packer/http/
COPY scripts/ /sw-packer/scripts/
COPY *.hcl /sw-packer/

WORKDIR /sw-packer

ARG username
RUN  grep -rwl "USER" . | xargs sed -i "s/USER/${username}/g"

ARG password
RUN  grep -rwl "PASS" . | xargs sed -i "s/PASS/${password}/g"

RUN chmod +x /sw-packer/scripts/startup.sh
ENTRYPOINT ["/sw-packer/scripts/startup.sh"]
CMD ["ubuntu-20.04", "100", ""]
