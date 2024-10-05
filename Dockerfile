FROM alpine:3.16.9

# Set up insecure default key
RUN mkdir -m 0750 /root/.android
ADD files/insecure_shared_adbkey /root/.android/adbkey
ADD files/insecure_shared_adbkey.pub /root/.android/adbkey.pub
ADD files/update-platform-tools.sh /usr/local/bin/update-platform-tools.sh
RUN chmod +x /usr/local/bin/update-platform-tools.sh

RUN set -xeo pipefail && \
    apk update && \
    apk add wget ca-certificates tini && \
    wget -O "/etc/apk/keys/sgerrand.rsa.pub" \
      "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
     wget -O "/tmp/glibc.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk" && \
     wget -O "/tmp/glibc-bin.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-bin-2.35-r1.apk" && \
     apk add "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
     rm "/etc/apk/keys/sgerrand.rsa.pub" && \
     rm "/root/.wget-hsts" && \
     rm "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
     rm -r /var/cache/apk/APKINDEX.* && \
    mkdir -p /lib64 && \
    ln -sf /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2 && \
    /usr/local/bin/update-platform-tools.sh

# Expose default ADB port
EXPOSE 5037

# Set up PATH
ENV PATH $PATH:/opt/platform-tools

# Change workdir
WORKDIR /opt

# Install open ssh
RUN apk add --update --no-cache openssh
ADD files/sshd_config /etc/ssh/.

# Volume ssh key
RUN mkdir ssh
VOLUME /opt/ssh

# Expose openssh server
EXPOSE 22

# Install node
RUN apk add --update --no-cache git nodejs npm

# Install ws-scrcpy
RUN git clone --depth 1 --branch feat_m2mrem_hbs https://github.com/widhaprasa/ws-scrcpy.git
RUN apk add --no-cache --virtual .gyp python3 make g++ && \
  cd ws-scrcpy && npm install && \
  apk del .gyp
RUN cd ws-scrcpy && npm run dist

# Expose ws-scrcpy server
EXPOSE 8000

# Add docker-entrypoint to image
ADD files/docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Entrypoint adb server
ENTRYPOINT "./docker-entrypoint.sh"
