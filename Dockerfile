FROM bekozi/esmf:latest
LABEL maintainer "Rohit Khattar <rohitkhattar11@gmail.com>"

RUN apt-get update && apt-get install -y \
	build-essential \
	python2.7 \
	curl \
	gfortran \
	libjpeg-dev \
	libglu1-mesa-dev freeglut3-dev mesa-common-dev \
	libghc-zlib-dev bison flex file wget bzip2 && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /libs

#Build HDF4
RUN wget https://observer.gsfc.nasa.gov/ftp/edhs/hdfeos/latest_release/hdf-4.2.13.tar.gz; \
    tar zxf hdf-4.2.13.tar.gz; \
    cd hdf-4.2.13; \
    ./configure --prefix=/usr/local/ --enable-fortran --disable-netcdf F77=mpif90; \
    make && make install; \
    cd ..; \
    rm -rf ./hdf-4.2.13 ./hdf-4.2.13.tar.gz; 

#Build HDF-EOS2
RUN wget https://observer.gsfc.nasa.gov/ftp/edhs/hdfeos/latest_release/HDF-EOS2.20v1.00.tar.Z; \
    tar zxf HDF-EOS2.20v1.00.tar.Z; \
    cd hdfeos; \
    ./configure CC='/usr/local/bin/h4cc -Df2cFortran' --prefix=/usr/local/ --enable-install-include --with-hdf4=/usr/local F77=mpif90; \
    make && make install; \
    cd ..; \
    rm -rf ./hdfeos ./HDF-EOS2.20v1.00.tar.Z;


#Build Jasper
RUN curl -L  https://github.com/jasper-software/jasper/archive/version-2.0.19.tar.gz --output jasper.tar.gz &&\
	mkdir jasper-build &&\
	tar -xf jasper.tar.gz &&\
	cmake -G "Unix Makefiles" -H/libs/jasper-version-2.0.19 -B/libs/jasper-build -DJAS_ENABLE_SHARED=true  &&\
	cd /libs/jasper-build &&\
	make clean all &&\
	make install &&\
	cd ..; \
    rm -rf ./jasper.tar.gz; 


#Build eccodes
RUN cd /libs &&\
	curl -L https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.18.0-Source.tar.gz?api=v2 --output eccodes.tar.gz &&\
	mkdir eccodes-build &&\
	tar -xzf eccodes.tar.gz &&\
	cmake -H/libs/eccodes-2.18.0-Source -B/libs/eccodes-build &&\
	cd /libs/eccodes-build &&\
	make clean all &&\
	make install &&\
	cd ..; \
    rm -rf ./eccodes.tar.gz; 

#Download LISF
RUN cd /libs &&\
	curl -L https://github.com/NASA-LIS/LISF/archive/v7.3.0-rc8-557WW.tar.gz --output lisf.tar.gz &&\
	tar -xzf  lisf.tar.gz

# Copy the configuration files for LDT
COPY ./build_configs/configure.ldt /libs/LISF-7.3.0-rc8-557WW/ldt/make
COPY ./build_configs/LDT_NetCDF_inc.h /libs/LISF-7.3.0-rc8-557WW/ldt/make
COPY ./build_configs/LDT_misc.h /libs/LISF-7.3.0-rc8-557WW/ldt/make

# Set ENV variabled for LDT Install

ENV LDT_ARCH=linux_gfortran \
	LDT_FC=/usr/bin/mpif90 \
	LDT_CC=/usr/bin/mpicc \
	LDT_MODESMF=/sandbox/esmf/install/mod \
	LDT_LIBESMF=/sandbox/esmf/install/lib \
	LDT_JASPER=/usr/local/bin/jasper \
	LDT_ECCODES=/usr/local \
	LDT_NETCDF=/sandbox/netcdf-c/4.7.3/install \
	LDT_HDF5=/sandbox/hdf5/1.10.6/install \
	LDT_HDF4=/usr/local \
	LDT_HDFEOS=/usr/local

ENV LD_LIBRARY_PATH=$LDT_HDF4/lib:$LDT_LIBESMF:$LDT_NETCDF/lib:$LDT_ECCODES/lib

# Compile LDT
RUN cd /libs/LISF-7.3.0-rc8-557WW/ldt &&\
	./compile &&\
	mkdir /home/apps &&\
	cp ./LDT /home/apps/

# Copy the configuration files for LIS
COPY ./build_configs/configure.lis /libs/LISF-7.3.0-rc8-557WW/lis/make
COPY ./build_configs/LIS_NetCDF_inc.h /libs/LISF-7.3.0-rc8-557WW/lis/make
COPY ./build_configs/LIS_misc.h /libs/LISF-7.3.0-rc8-557WW/lis/make

# Set ENV variabled for LIS Install

ENV LIS_ARCH=linux_gfortran \
	LIS_FC=/usr/bin/mpif90 \
	LIS_CC=/usr/bin/mpicc \
	LIS_MODESMF=/sandbox/esmf/install/mod \
	LIS_LIBESMF=/sandbox/esmf/install/lib \
	LIS_JASPER=/usr/local/bin/jasper \
	LIS_ECCODES=/usr/local \
	LIS_NETCDF=/sandbox/netcdf-c/4.7.3/install \
	LIS_HDF5=/sandbox/hdf5/1.10.6/install \
	LIS_HDF4=/usr/local \
	LIS_HDFEOS=/usr/local

ENV LD_LIBRARY_PATH=$LIS_HDF5/lib:$LIS_HDF4/lib:$LIS_LIBESMF:$LIS_NETCDF/lib:${LIS_ECCODES}/lib:$LD_LIBRARY_PATH

#Compile LIS
RUN cd /libs/LISF-7.3.0-rc8-557WW/lis &&\
	./compile &&\
	cp ./LIS /home/apps/



# # Copy the configuration files for LVT
# COPY configure.lvt /libs/LISF-7.3.0-rc8-557WW/lvt/make
# COPY LVT_NetCDF_inc.h /libs/LISF-7.3.0-rc8-557WW/lvt/make
# COPY LVT_misc.h /libs/LISF-7.3.0-rc8-557WW/lvt/make

# # Set ENV variabled for LIS Install

# ENV LVT_ARCH=linux_gfortran \
# 	LVT_FC=/usr/bin/mpif90 \
# 	LVT_CC=/usr/bin/mpicc \
# 	LVT_MODESMF=/sandbox/esmf/install/mod \
# 	LVT_LIBESMF=/sandbox/esmf/install/lib \
# 	LVT_JASPER=/usr/local/bin/jasper \
# 	LVT_ECCODES=/usr/local \
# 	LVT_NETCDF=/sandbox/netcdf-c/4.7.3/install \
# 	LVT_HDF5=/sandbox/hdf5/1.10.6/install \
# 	LVT_HDF4=/usr/local \
# 	LVT_HDFEOS=/usr/local

# #Compile LVT
# RUN cd /libs/LISF-7.3.0-rc8-557WW/lvt &&\
# 	./compile &&\
# 	cp ./LVT /home/apps/

# Only for dev
ENTRYPOINT ["tail", "-f", "/dev/null"]
