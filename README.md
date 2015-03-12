# docker-npm-build
This is a base image for building [node.js][node.js] [npm][npm] repositories.

## Purpose
This docker image builds on top of Arch Linux's base/archlinux image for the
purpose of building projects using npm.  It provides several key features:

* A non-root user (`build`) for executing the image build.  This is important
  for security purposes and to ensure that the package doesn't require root
  permissions to be built.
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
This image uses a build user to run npm  This means that your file permissions
must allow this user to write to certain folders like `node_modules`.  The
easiest way to do this is to create a group and give that group write access to
the necessary folders.

```bash
groupadd --gid 59944 npm-build
chmod -R g+w node_modules
chgrp -R npm-build node_modules
```

You may also want to give your user access to files created by the build user.

```bash
usermod -a -G 59944 "$(whoami)"
```

### Dockerfile build
Alternatively, you can create your own `Dockerfile` that builds on top of this
image.  This allows you to modify the environment by installing additional
software needed, altering the commands to run, etc.

A simple one that just installs another package but leaves the rest of the
process alone could look like this:

```dockerfile
FROM nubs/npm-build

USER root

RUN pacman --sync --noconfirm --noprogressbar --quiet somepackage

USER build
```

You can then build this docker image and run it against your `package.json`
volume like normal (this example assumes the `package.json` and `Dockerfile` are
in your current directory):

```bash
docker build --tag my-code .
docker run -i -t --rm -v "$(pwd):/code" my-code
docker run -i -t --rm -v "$(pwd):/code" my-code npm update
```

[node.js]: http://nodejs.org/
[npm]: https://www.npmjs.org/
