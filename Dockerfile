# Our clusters run Ubuntu and so shall we
FROM ubuntu:16.04
LABEL maintainer="University of Michigan Center for Statistical Genetics"
WORKDIR /code
COPY . /code

# TODO: Vim and tabix can be safely removed as dependencies once shared directories are mounted
#  (will move analysis workflow out of the container)
RUN apt-get update && \
    apt-get -y install apt-utils make gcc g++ gfortran zlib1g-dev vim tabix && \
    make clean && make

# TODO: In future, mount VOLUMEs (eg for mirroring development changes inside the container or capturing results)

# Eventually, we will expect to pass arguments. For now start a shell and keep it running,
#  so user can connect to the shell inside the container for their work
CMD /bin/bash
