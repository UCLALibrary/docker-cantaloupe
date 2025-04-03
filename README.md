## A Docker image for the Cantaloupe IIIF image server
[![Maven Build](https://github.com/uclalibrary/docker-cantaloupe/actions/workflows/nightly.yml/badge.svg)](https://github.com/UCLALibrary/docker-cantaloupe/actions) [![Known Vulnerabilities](https://snyk.io/test/github/uclalibrary/docker-cantaloupe/badge.svg)](https://snyk.io/test/github/uclalibrary/docker-cantaloupe)

This project builds a Docker image for the [Cantaloupe IIIF image server](https://cantaloupe-project.github.io/cantaloupe). If you're interested in using a prebuilt image, you can find one on [UCLA Library's DockerHub account](https://hub.docker.com/repository/docker/uclalibrary/cantaloupe).

Historical note: We used to build this project using Ruby, but to simplify our process we've recently switched to using Maven. One result of this change is that the Dockerfile no longer stands on its own, independent of the Maven build. We could save a filtered Dockefile to disk if there is interest in that, though.

### Create the Docker image

To build the current stable version of Cantaloupe (i.e., 5.x), run:

    mvn verify

_We use `verify` instead of `package` because there are tests in the verify stage that will be run against the newly build container to make sure it's built and configured like it should be._

_Hint: If the build fails, it may be because a package in the Docker image has been recently updated. To work around this, see the [Working with Pinned OS Packages](https://github.com/uclalibrary/docker-cantaloupe#working-with-pinned-os-packages) section at the bottom of this document._

To build Cantaloupe using the latest code on [the upstream `develop` branch](https://github.com/cantaloupe-project/cantaloupe/tree/develop) (i.e., our "nightly" build), use the following:

    mvn verify -Dcantaloupe.version=dev

The stable version of the build creates a Docker container with pinned versions of the pre-requisite software. The development build uses whatever the latest versions are in the base container that's used. This means, when the stable build no longer works (because the pinned versions are obsolete), the development version can still be run. Once that image is built, a person can shell into the container, see what the current versions are, and update the pinned versions in the Maven POM file accordingly.

To build an older version of Cantaloupe, you can specify a commit hash:

    mvn verify -Dcantaloupe.version=dev -Dcantaloupe.commit.ref=fff5425

To apply your own patches to the Cantaloupe source, create patchfiles with a Git diff, put them into the directory `src/main/docker/patches`:

    mvn verify -Dcantaloupe.version=dev -Dcantaloupe.apply.patchfiles=true

Patching an older version of Cantaloupe is possible as well.

_Hint: If you want to run a build without a Docker cache, add `-Ddocker.noCache` to your mvn command; for instance: `mvn verify -Ddocker.noCache`_

### Run the Cantaloupe container

The simplest way to run the newly built Cantaloupe container (for development purposes) is to use the Maven Docker plugin. To do that, run:

    mvn docker:start

This will output logging that will tell you what random port Cantaloupe has been started on (e.g. http://localhost:32772). If you visit the URL found in the logging output in your browser, you will see the Cantaloupe landing page; and, if you haven't changed the default `image.root` location, you can test the server by visiting:

    http://localhost:[YOUR_PORT]/iiif/2/test.tif/info.json

or

    http://localhost:[YOUR_PORT]/iiif/2/test.tif/full/full/0/default.jpg

If you'd like to change the location where Cantaloupe will look for images (to your own test images), you can start the container with a custom `image.root` location:

    mvn docker:start -Dimage.root=/path/to/your/imageroot

To stop the Cantaloupe container, when you are done testing, you should run:

    mvn docker:stop

If you would like to access the administrative user interface while running in test mode, start the server with this additional argument (supplying your own password):

    mvn docker:start -Dadmin.password=SecretPassword

This method is only intended for testing. When running Cantaloupe on a server, the administrative password, if used, should be supplied via an environmental property that overrides the value in Cantaloupe's [configuration file](https://github.com/UCLALibrary/docker-cantaloupe/tree/main/src/main/docker/configs).

In addition to running a test Cantaloupe server using the Maven Docker plugin, you can also run the container through the standard `docker run` method. To do this, use environmental variables to override properties from the configuration file. An example of doing this looks like:

    docker run -d -p 8182:8182 \
      -e "CANTALOUPE_ENDPOINT_ADMIN_SECRET=secret" \
      -e "CANTALOUPE_ENDPOINT_ADMIN_ENABLED=true" \
      --name melon -v /path/to/your/images:/imageroot cantaloupe:5.0.7-0  # or latest version

Here is another, more complex, example:

    docker run -d -p 8182:8182 \
      -e "CANTALOUPE_ENDPOINT_ADMIN_SECRET=secret" \
      -e "CANTALOUPE_ENDPOINT_ADMIN_ENABLED=true" \
      -e "CANTALOUPE_S3SOURCE_LOOKUP_STRATEGY=BasicLookupStrategy" \
      -e "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX=.jpx" \
      -e "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME=getyourown" \
      -e "CANTALOUPE_S3SOURCE_SECRET_KEY=getyourown" \
      -e "CANTALOUPE_S3SOURCE_ACCESS_KEY_ID=getyourown" \
      -e "CANTALOUPE_S3SOURCE_ENDPOINT=s3.amazonaws.com" \
      -e "CANTALOUPE_LOG_APPLICATION_FILEAPPENDER_ENABLED=true" \
      -e "CANTALOUPE_LOG_APPLICATION_FILEAPPENDER_PATHNAME=/var/log/cantaloupe/cantaloupe.log" \
      --name melon -v /path/to/your/images:/imageroot cantaloupe:5.0.7-0  # or latest version

You may also pass the `JAVA_OPTS` variable to fine-tune JVM options. This will be passed to the `java` command as-is.

There are, of course, other ways to run Docker without having to supply all these environmental variables on the command line. One might want to use a Docker Compose file, Terraform configs, or Kubernetes.

### Using Kakadu for JPEG-2000 support

This project also enables you to build a new Cantaloupe image with the Kakadu JPEG 2000 libraries. This requires that you have a license to use Kakadu, and that you have the Kakadu source code accessible from a different Git repository (this should be private since the code is proprietary). This additional repository must have the versioned directory name, that Kakadu Software Pty Ltd distributes to licensees, at its root (e.g., something like: `v7_A_7-01642E`).

To build an image that includes Kakadu, supply two additional build parameters: the repository and the version number; this should look something like:

    mvn verify -Dkakadu.git.repo=scm:git:git@github.com:uclalibrary/kakadu.git -Dkakadu.version=v7_A_7-01642E

Once you've done this, you'll get the following warning:

    warning: adding embedded git repository: src/main/docker/kakadu
    hint: You've added another git repository inside your current repository.
    hint: Clones of the outer repository will not contain the contents of
    hint: the embedded repository and will not know how to obtain it.
    hint: If you meant to add a submodule, use:
    hint: 
    hint:   git submodule add <url> src/main/docker/kakadu
    hint: 
    hint: If you added this path by mistake, you can remove it from the
    hint: index with:
    hint: 
    hint:   git rm --cached src/main/docker/kakadu
    hint: 
    hint: See "git help submodule" for more information.

This is what you want. You do not want to add your Kakadu code as a submodule since the repository is private and should not be linked to this project's code.

UCLA developers only need to supply the correct `kakadu.version` v7 value. The build is set up to use our private Kakadu GitHub repository by default. Non-UCLA developers should not supply `kakadu.version` without also supplying `kakadu.git.repo`, since the UCLA Kakadu repository is a private repository that cannot be accessed by others.

It's important to remember that if you build a Docker container with `kakadu.version`, you must also supply that same argument when you run the `mvn docker:start` and `mvn docker:stop` commands. They will look something like:

    mvn docker:start -Dkakadu.version=v7_A_7-01903E

and

    mvn docker:stop -Dkakadu.version=v7_A_7-01903E

You do not need to supply the `kakadu.git.repo` argument when just starting or stopping your previously built Kakadu-enabled containers. That's only needed at the point of building them.

### Deploying with Kubernetes

Locally, we deploy Cantaloupe with Kubernetes. We're working on some documentation to fill in here with instructions on how you, too, can do this.

### Working with Pinned OS Packages

We pin the versions of packages that we install into our base image. What this means is that periodically a pinned version will become obsolete and the build will break. We have a nightly build that should catch this issues for us, but in the case that you find the breakage before us, there is a handy way to tell which pinned version has broken the build. To see the current versions inside the base image, run:

    mvn validate -Dversions -Ddocker.noCache

This will output a list of current versions, which can be compared to the pinned versions defined in the project's POM file (i.e., pom.xml).

### Acknowledgments

This project started as a fork of the [docker-cantaloupe](https://github.com/MITLibraries/docker-cantaloupe) project from MIT Libraries. It's changed dramatically since we forked it from the upstream, but we still want to acknowledge the source from which we started. Thanks!

### Contact
We use an internal ticketing system, but we've left the GitHub [issues queue](https://github.com/UCLALibrary/docker-cantaloupe/issues) open (in case you'd like to file a bug ticket). If you have a question or a general suggestion, you might prefer to use the project's [discussion board](https://github.com/UCLALibrary/docker-cantaloupe/discussions). Feel free to use either route to contact us.
