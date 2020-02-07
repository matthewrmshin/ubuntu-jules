FROM ubuntu AS base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y curl g++ gfortran make perl

# Build and install netCDF libraries.
ENV ZLIB_VN=1.2.11
ENV HDF5_VN=1.10.2
ENV NC_VN=4.6.1
ENV NF_VN=4.4.4
WORKDIR /opt
ENV PREFIX=/usr/local
RUN curl -L "http://www.zlib.net/zlib-${ZLIB_VN}.tar.gz" | tar -xz
RUN curl -L "https://www.hdfgroup.org/package/source-gzip-2/?wpdmdl=11810&refresh=5b3b3b8b256791530608523" | tar -xz
RUN curl -L "https://github.com/Unidata/netcdf-c/archive/v${NC_VN}.tar.gz" | tar -xz
RUN curl -L "https://github.com/Unidata/netcdf-fortran/archive/v${NF_VN}.tar.gz" | tar -xz
WORKDIR /opt/zlib-${ZLIB_VN}
RUN ./configure --prefix=${PREFIX} && make install
WORKDIR /opt/hdf5-${HDF5_VN}
RUN ./configure --with-zlib=${PREFIX} --prefix=${PREFIX} --enable-hl \
    && make install
WORKDIR /opt/netcdf-c-${NC_VN}
RUN env CPATH=${PREFIX}/include LD_LIBRARY_PATH=${PREFIX}/lib \
    CPPFLAGS=-I${PREFIX}/include LDFLAGS=-L${PREFIX}/lib \
    ./configure --prefix=${PREFIX} && make install --disable-dap \
    && ${PREFIX}/bin/nc-config --all
WORKDIR /opt/netcdf-fortran-${NF_VN}
RUN env CPATH=${PREFIX}/include LD_LIBRARY_PATH=${PREFIX}/lib \
    CPPFLAGS=-I${PREFIX}/include LDFLAGS=-L${PREFIX}/lib \
    ./configure --prefix=${PREFIX} && make install \
    && ${PREFIX}/bin/nf-config --all

# Install FCM Make
ENV FCM_VN=2019.09.0
WORKDIR /opt
RUN curl -L "https://github.com/metomi/fcm/archive/${FCM_VN}.tar.gz" | tar -xz
RUN ln -s "fcm-${FCM_VN}" '/opt/fcm' \
    && cp -p '/opt/fcm/usr/bin/fcm' '/usr/local/bin/fcm'

COPY jules-source /opt/jules
COPY etc/fcm-make/platform/ubuntu.cfg /opt/jules/etc/fcm-make/platform/ubuntu.cfg
WORKDIR /opt/jules
RUN env JULES_PLATFORM=ubuntu \
    fcm make -f './etc/fcm-make/make.cfg' 'build.target=jules.exe'

FROM base
COPY --from=build /opt/jules/build/bin/jules.exe /usr/local/bin/jules.exe
ENTRYPOINT ["/usr/local/bin/jules.exe"]

LABEL description="JULES on Ubuntu" \
      maintainer="matthew.shin@metoffice.gov.uk" \
      version="1"
