FROM aesoper/ubuntu-s6-overlay:1.0.4
MAINTAINER "aesoper" <weilanzhuan@163.com>


ARG OPENLDAP_PACKAGE_VERSION=2.5.13

ARG LDAP_OPENLDAP_GID
ARG LDAP_OPENLDAP_UID

#RUN if [ -z "${LDAP_OPENLDAP_GID}" ]; then groupadd -g 911 -r openldap; else groupadd -r -g ${LDAP_OPENLDAP_GID} openldap; fi \
#    && if [ -z "${LDAP_OPENLDAP_UID}" ]; then useradd -u 911 -r -g openldap openldap; else useradd -r -g openldap -u ${LDAP_OPENLDAP_UID} openldap; fi


# set s6-overlay environment variables
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0

ENV LDAP_ORGANISATION="Example Inc" \
    LDAP_DOMAIN=example.org \
    LDAP_BASE_DN="" \
    LDAP_ADMIN_PASSWORD=admin \
    LDAP_CONFIG_PASSWORD=admin \
    LDAP_READONLY_USER=true \
    LDAP_READONLY_USER_USERNAME=readonly \
    LDAP_READONLY_USER_PASSWORD=readonly \
    LDAP_BACKEND=mdb \
    LANG=C.UTF-8 \
    LDAP_TLS_ENABLED=true \
    LDAP_TLS_CRT_FILENAME=cert.crt \
    LDAP_TLS_KEY_FILENAME=cert.key \
    LDAP_TLS_CA_CRT_FILENAME=ca.crt \
#    LDAP_TLS_CA_KEY_FILENAME=ca.key \
    LDAP_TLS_DH_PARAM_FILENAME=dhparam.pem \
    LDAP_HOSTNAME=ldap


RUN apt-get update

# install openldap \
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip \
    net-tools \
    slapd \
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
    openssh-server \
    schema2ldif && \
    pip3 install shyaml && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/lib/ldap /etc/ldap/slapd.d

#FROM python:3
#RUN pip install --upgrade pip && pip install shyaml

ADD ./rootfs /



#VOLUME ["/etc/ldap/slapd.d", "/etc/ldap/ssl", "/var/lib/ldap", "/var/run/slapd", "/etc/ldap/schema", /assets/tls]

EXPOSE 389 636

