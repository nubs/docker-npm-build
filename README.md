# docker-npm-build
This is a base image for building [node.js][node.js] [npm][npm] repositories.

## Purpose
This docker image builds on top of a base Alpine Linux image for the purpose
of building projects using npm.  It provides several key features:

* Access to the build location will be in the volume located at `/code`.  This
  directory will be the default working directory.
* The npm bin directory is automatically included in `PATH` using the relative
  `node_modules/.bin` directory.

## Usage
This library is useful with simple `package.json`'s from the command line.
For example:

```bash
docker run --interactive --tty --rm --volume /tmp/my-code:/code nubs/npm-build

# Using short-options:
# docker run -i -t --rm -v /tmp/my-code:/code nubs/npm-build
```

This will execute the default command (`npm install`) and update your code
directory with the result (i.e., `node_modules`).

Other commands can also be executed.  For example, to update dependencies:

```bash
docker run -i -t --rm -v /tmp/my-code:/code nubs/npm-build npm update
```

## Permissions
This image runs as root (PID 0), but for security purposes it is recommended to
use Docker's [user namespace functionality][docker-user-namespaces] to map that
to a non-privileged user on your host system.

If you use volume mounting of your project (e.g., to run `npm install` inside
the container but want to modify the host `node_modules` directory), then you
may run into permission issues.

Without Docker's user namespaces, the container will create files/directories
with root ownership on your host which may cause issues when trying to access
them as a non-root user.

When using Docker's user namespaces, the container will be running under a
different user.  You may have to adjust permissions on the directory to allow
the user to create/modify files.  For example, giving an `/etc/setuid` and
`/etc/subgid` that contains `dockremap:165536:65536` and a docker daemon
running using this default mapping: `docker daemon --userns-remap=default`,
you would need to run the following to give the container access to run `npm
install` and yourself access to do so on the host:

```bash
groupadd --gid 165536 subgid-root
chmod -R g+w node_modules
chgrp -R subgid-root node_modules
usermod -a -G subgid-root "$(whoami)"
```

### Dockerfile build
Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM nubs/npm-build

RUN pacman --sync --noconfirm --noprogressbar --quiet somepackage
```

You can then build this docker image and run it against your `package.json`
volume like normal (this example assumes the `package.json` and `Dockerfile` are
in your current directory):

```bash
docker build --tag my-code .
docker run -i -t --rm -v "$(pwd):/code" my-code
docker run -i -t --rm -v "$(pwd):/code" my-code npm update
```

## License
docker-npm-build is licensed under the MIT license.  See [LICENSE] for the full
license text.

[node.js]: http://nodejs.org/
[npm]: https://www.npmjs.org/
[docker-use-namespaces]: https://docs.docker.com/engine/reference/commandline/daemon/#daemon-user-namespace-options
[LICENSE]: https://github.com/nubs/docker-npm-build/blob/master/LICENSE
