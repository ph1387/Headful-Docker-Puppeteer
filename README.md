# Headful-Docker-Puppeteer
Headful-Docker-Puppeteer is a combination of [Puppeteer](https://github.com/puppeteer/puppeteer) and [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) used for running headful puppeteer scripts in a docker container.
Creator: P H, ph1387@t-online.de 

---

## Overview

***Note***

If you are only needing the simple chromium version it is better to use [docker-puppeteer](https://github.com/buildkite/docker-puppeteer) since it also provides an image on Docker Hub. This image is mostly intended for edge cases where i.e. videos are required to load. For these you generally need a chrome installation and a "working" display since chromium does not support all media types.

Most of the content in the Dockerfile match the [docker-puppeteer](https://github.com/buildkite/docker-puppeteer) version. [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml) is added in order to enable headful mode. Without it puppeteer crashes since no display is found. [Mocha](https://mochajs.org/) is used for executing the puppeteer scripts.

## Instructions

### How to run
Clone the project, navigate into the Headful-Docker-Puppeteer folder and execute the following command to build the image and run the script via mocha:

```sh
docker-compose -f docker-compose.integration-tests.yml run tests
```

### How to configure
The startup command for the headful version is set directly inside the Dockerfile. The last two entries of it can be changed as desired. Just make sure to wrap the starting command with "xvfb-run" since this starts the fake display:

```sh
CMD xvfb-run --server-args="-screen 0 1024x768x24" mocha --recursive /integration-tests
```

```sh
CMD xvfb-run --server-args="-screen 0 1024x768x24" <YourCustomStartupCommand>
```

The screensize can be changed as well. When doing so remember to also edit the "--window-size=1024,768" parameter in the puppeteer script.

## References
- [docker-puppeteer](https://github.com/buildkite/docker-puppeteer)
- [Puppeteer](https://github.com/puppeteer/puppeteer)
- [Xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
- [Mocha](https://mochajs.org/)

## License
MIT [license](https://github.com/ph1387/Headful-Docker-Puppeteer/blob/master/LICENSE.txt)
