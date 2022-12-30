FROM ubuntu:trusty as ct-ng

# libtool-bin is not available in 14.04 trusty
# Install dependencies to build toolchain
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends\
        gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
        python3-dev libtool automake gawk wget rsync git patch \
        unzip xz-utils bzip2 ca-certificates build-essential && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add a user called `develop` and add him to the sudo group
RUN useradd -m develop && \
    echo "develop:develop" | chpasswd && \
    adduser develop sudo

USER develop
WORKDIR /home/develop

# Install autoconf
#RUN wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz -O- | tar xz && \
#    cd autoconf-2.71 && \
#    ./configure --prefix=/home/develop/.local && \
#    make -j$(nproc) && \
#    make install && \
#    cd .. && \
#    rm -rf autoconf-2.71
#ENV PATH=/home/develop/.local/bin:$PATH

# Download and install crosstool-ng
RUN git clone https://github.com/crosstool-ng/crosstool-ng.git
WORKDIR /home/develop/crosstool-ng

# switch to crosstool-ng v1.20.0, unlike latest versions it should be built in source directory
RUN git show --summary && \
    git checkout 0c647595 && \
    ./bootstrap && \
# doesn't seems to work with v1.20, so build directly in source root
#    mkdir build && cd build && \
    ./configure --prefix=/home/develop/.local && \
    make -j$(($(nproc) * 2)) && \
    make install
# no, don't remove, v1.20 has this inside the source root...
#    cd .. && rm -rf build


#ENV PATH=/home/develop/.local/bin:$PATH
#WORKDIR /home/develop 
