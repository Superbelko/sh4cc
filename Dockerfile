FROM sh4ctng

ARG NGCONFIG

WORKDIR /home/develop
RUN mkdir /home/develop/src
COPY ${NGCONFIG} crosstool-ng/defconfig
#COPY ${HOST_TRIPLE}.env .env

# wget is way too old to trust new certificates... secuirity issue, but since we're in docker I don't bother too much
RUN echo "check_certificate = off" >> ~/.wgetrc

# grab a patch for glibc https://github.com/crosstool-ng/crosstool-ng/issues/686
# and grab sources from new locations for crosstool-ng as it will unable to get them
RUN cd ~/src && \
    wget https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/longterm/v2.6.27/linux-2.6.27.62.tar.xz && \
    wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz && \
    cd ~/crosstool-ng/patches/glibc/2.10.1 && \
    wget https://raw.githubusercontent.com/crosstool-ng/crosstool-ng/crosstool-ng-1.23.0/patches/glibc/2.25/110-sh-fix-gcc6.patch 

WORKDIR /home/develop/crosstool-ng
RUN ls -lah
RUN ./ct-ng defconfig

#RUN . ./.env; export DEB_TARGET_MULTIARCH=sh4-unknown-linux-gnu; \
#    V=1 ./ct-ng build || { cat build.log && false; }

RUN export DEB_TARGET_MULTIARCH=sh4-unknown-linux-gnu; V=1 ./ct-ng build

#ENV TOOLCHAIN_PATH=/home/develop/x-tools/${DEB_TARGET_MULTIARCH}
#ENV PATH=${TOOLCHAIN_PATH}/bin:$PATH
WORKDIR /home/develop