FROM aesoper/ubuntu-s6-overlay:v1.0.7
MAINTAINER "aesoper" <weilanzhuan@163.com>


ARG PQCHECKER_VERSION=2.0.0
ARG PQCHECKER_MD5=c005ce596e97d13e39485e711dcbc7e1


ARG OPENLDAP_PACKAGE_VERSION=2.5.13

ARG LDAP_OPENLDAP_GID
ARG LDAP_OPENLDAP_UID

# set s6-overlay environment variables
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_LOGGING=1 \
    S6_VERBOSITY=0


ENV YQ_VERSION=v4.30.5 \
    YQ_BINARY=yq_linux_amd64

RUN if [ -z "${LDAP_OPENLDAP_GID}" ]; then groupadd -g 911 -r openldap; else groupadd -r -g ${LDAP_OPENLDAP_GID} openldap; fi \
    && if [ -z "${LDAP_OPENLDAP_UID}" ]; then useradd -u 911 -r -g openldap openldap; else useradd -r -g openldap -u ${LDAP_OPENLDAP_UID} openldap; fi


# install openldap \
RUN apt-get update && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y  \
    wget \
    python3 \
    python3-pip \
    net-tools \
    slapd \
    slapd-contrib \
    ldap-utils \
    ldapscripts \
    inotify-tools \
    libsasl2-modules \
    libsasl2-modules-db \
    libsasl2-modules-gssapi-mit \
    libsasl2-modules-ldap \
    libsasl2-modules-otp \
    libsasl2-modules-sql \
    krb5-kdc-ldap \
    krb5-admin-server \
    schema2ldif && \
    wget --no-check-certificate https://meddeb.net/pub/pqchecker/deb/8/pqchecker_${PQCHECKER_VERSION}_amd64.deb -O pqchecker.deb && \
    echo "${PQCHECKER_MD5} pqchecker.deb" | md5sum -c && \
    dpkg -i pqchecker.deb && \
    rm pqchecker.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/lib/ldap /etc/ldap/slapd.d

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
      tar xz && mv ${YQ_BINARY} /usr/bin/yq

ADD ./rootfs /

#VOLUME ["/assets/config"]
#VOLUME ["/etc/ldap/slapd.d", "/var/lib/ldap", "/var/run/slapd", "/etc/ldap/schema", "/assets/certs", "/assets/config"]

EXPOSE 389 636

