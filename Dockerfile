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

# Create a separate user to run npm as.  Root access shouldn't typically be
# necessary.  Specify the uid so that it is unique including from the host.
RUN useradd --uid 59944 --create-home --comment "Build User" build

RUN mkdir /code && chown build:build /code
WORKDIR /code

USER build
ENV HOME /home/build

# Set the umask to 002 so that the group has write access inside and outside the
# container.
ADD umask.sh $HOME/umask.sh

# Setup PATH to prioritize local npm bin ahead of system PATH.
ENV PATH node_modules/.bin:$PATH

ENTRYPOINT ["/home/build/umask.sh"]
CMD ["npm", "install"]
