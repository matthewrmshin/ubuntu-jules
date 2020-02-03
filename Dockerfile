FROM ubuntu AS base

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y software-properties-common \
    && add-apt-repository universe \
    && apt-get update -y \
    && apt-get install -y bash gfortran libnetcdff-dev \
    && apt-get install -y awscli

FROM base AS build
RUN apt-get install -y curl perl
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
COPY run-jules /usr/local/bin/run-jules
WORKDIR /tmp/jules-run
ENTRYPOINT ["/usr/local/bin/run-jules"]

LABEL description="JULES on Ubuntu" \
      maintainer="matthew.shin@metoffice.gov.uk" \
      version="1"
