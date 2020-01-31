FROM matthewrmshin/ubuntu-gfortran-fcm-make-netcdf AS build
COPY jules-source /opt/jules
COPY etc/fcm-make/platform/ubuntu.cfg /opt/jules/etc/fcm-make/platform/ubuntu.cfg
WORKDIR /opt/jules
RUN env JULES_PLATFORM=ubuntu fcm make -f './etc/fcm-make/make.cfg' 'build.target=jules.exe'

FROM matthewrmshin/ubuntu-gfortran-fcm-make-netcdf AS run
COPY --from=build /opt/jules/build/bin/jules.exe /usr/local/bin/jules.exe
WORKDIR /tmp/jules-run
ENTRYPOINT ["/usr/local/bin/jules.exe"]
