FROM base/archlinux

MAINTAINER Spencer Rinehart <anubis@overthemonkey.com>

# Update system and install node.js/npm.
RUN pacman --sync --refresh --sysupgrade --noconfirm --noprogressbar --quiet && pacman --sync --noconfirm --noprogressbar --quiet nodejs

# Create a separate user to run npm as.  Root access shouldn't typically be
# necessary.  Specify the uid so that it is unique including from the host.
RUN useradd --uid 59944 --create-home --comment "Build User" build

USER build
ENV HOME /home/build

# Set the umask to 002 so that the group has write access inside and outside the
# container.
ADD umask.sh $HOME/umask.sh

# Setup PATH to prioritize local npm bin ahead of system PATH.
ENV PATH node_modules/.bin:$PATH

WORKDIR /code

ENTRYPOINT ["/home/build/umask.sh"]
CMD ["npm", "install"]
