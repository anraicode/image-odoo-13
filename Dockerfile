FROM debian:buster-slim
MAINTAINER AnraiNun <enriquenun95@gmail.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libc-dev \
            libssl-dev \
            libsasl2-dev \
            libxslt-dev  \
            libldap2-dev \
            libevent-dev\
            libffi-dev \
            openssl \
            node-less \
            npm \
            build-essential \
            python3-num2words \
            python3-dev \
            python3-pip \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-slugify \
            python3-vobject \
            python3-watchdog \
            python3-xlrd \
            python3-xlwt \
            unzip \
            xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
        && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb


RUN pip3 install --upgrade pip
RUN pip3 install wheel setuptools cryptography pyOpenSSL
# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
        && GNUPGHOME="$(mktemp -d)" \
        && export GNUPGHOME \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install --no-install-recommends -y postgresql-client \
        && rm -f /etc/apt/sources.list.d/pgdg.list \
        && rm -rf /var/lib/apt/lists/*



# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

RUN useradd -m odoo
WORKDIR /home/odoo
RUN mkdir -p src/extra-addons src/odoo web-data bin config

#RUN curl -o odoo-13.0.zip https://codeload.github.com/odoo/odoo/zip/refs/heads/13.0 && unzip odoo-13.0.zip -d src/ && rm -rf odoo-13.0.zip && mv src/odoo-13.0 src/odoo
COPY requirements.txt /home/odoo/bin
RUN pip3 install -r bin/requirements.txt
VOLUME ["/home/odoo/web-data/", "/home/odoo/src/extra-addons", "/home/odoo/src/odoo"]

EXPOSE 8069 8071 8072
USER odoo