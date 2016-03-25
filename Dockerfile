FROM base/archlinux:latest

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

RUN curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=6&use_mirror_status=on" && sed -i 's/^#//' /etc/pacman.d/mirrorlist

# Update system and install node.js/npm.
RUN pacman-key --refresh-keys && \
    pacman --sync --refresh --noconfirm --noprogressbar --quiet && \
    pacman --sync --noconfirm --noprogressbar --quiet archlinux-keyring openssl pacman && \
    pacman-db-upgrade && \
    pacman --sync --sysupgrade --noconfirm --noprogressbar --quiet && \
    pacman --sync --noconfirm --noprogressbar --quiet nodejs npm

RUN mkdir /code
WORKDIR /code

ENV HOME /root

# Setup PATH to prioritize local npm bin ahead of system PATH.
ENV PATH node_modules/.bin:$PATH

CMD ["npm", "install"]
