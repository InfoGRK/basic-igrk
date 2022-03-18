#!/bin/bash
## WRF installation with parallel process.
# Download and install required library and data files for WRF.
# License: LGPL
# Jamal Khan <jamal.khan@legos.obs-mip.fr>
# Tested in Ubuntu 18.04 LTS
ftp_server=182.16.248.177
ftp_user=wrfuser
ftp_pass=wrfpass

# basic package management
sudo apt update
sudo apt upgrade
sudo apt install gcc gfortran g++ libtool automake autoconf make m4 grads default-jre csh

## Directory Listing
export HOME=`cd;pwd`
mkdir $HOME/WRF
cd $HOME/WRF
mkdir Downloads
mkdir Library

## Downloading Libraries
cd Downloads
wget -c --auth-no-challenge=on --keep-session-cookies --no-check-certificate --user=$ftp_user --password=$ftp_pass --content-disposition ftp://$ftp_server/tarballs/*
# wget -c https://www.zlib.net/zlib-1.2.11.tar.gz
# wget -c https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz
# wget -c https://github.com/Unidata/netcdf-c/archive/v4.7.1.tar.gz
# wget -c https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.5.1.tar.gz
# wget -c http://www.mpich.org/static/downloads/3.3.1/mpich-3.3.1.tar.gz
# wget -c https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
# wget -c https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip

# Compilers
export DIR=$HOME/WRF/Library
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran

# zlib
cd $HOME/WRF/Downloads
tar -xvzf zlib-1.2.11.tar.gz
cd zlib-1.2.11/
./configure --prefix=$DIR
make
make install

# # hdf5 library for netcdf4 functionality
cd $HOME/WRF/Downloads
tar -xvzf hdf5-1.10.5.tar.gz
cd hdf5-1.10.5
./configure --prefix=$DIR --with-zlib=$DIR --enable-hl --enable-fortran
make check
make install

export HDF5=$DIR
export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH

## Install NETCDF C Library
cd $HOME/WRF/Downloads
tar -xvzf netcdf-c-4.7.1.tar.gz
cd netcdf-c-4.7.1/
export CPPFLAGS=-I$DIR/include 
export LDFLAGS=-L$DIR/lib
./configure --prefix=$DIR --disable-dap
make check
make install

export PATH=$DIR/bin:$PATH
export NETCDF=$DIR

## NetCDF fortran library
cd $HOME/WRF/Downloads
tar -xvzf netcdf-fortran-4.5.1.tar.gz
cd netcdf-fortran-4.5.1/
export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH
export CPPFLAGS=-I$DIR/include 
export LDFLAGS=-L$DIR/lib
export LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lz" 
./configure --prefix=$DIR --disable-shared
make check
make install

# ## MPICH
cd $HOME/WRF/Downloads
tar -xvzf mpich-3.3.1.tar.gz
cd mpich-3.3.1/
./configure --prefix=$DIR
make
make install

# export PATH=$DIR/bin:$PATH

# # libpng
cd $HOME/WRF/Downloads
export LDFLAGS=-L$DIR/lib
export CPPFLAGS=-I$DIR/include
tar -xvzf libpng-1.6.37.tar.gz
cd libpng-1.6.37/
./configure --prefix=$DIR
make
make install

# # JasPer
cd $HOME/WRF/Downloads
unzip jasper-1.900.1.zip
cd jasper-1.900.1/
autoreconf -i
./configure --prefix=$DIR
make
make install
export JASPERLIB=$DIR/lib
export JASPERINC=$DIR/include

############################ WRF 4.3.2 #################################
## WRF v4.3.2
########################################################################
cd $HOME/WRF/downloads
tar -xvzf v4.3.2.tar.gz -C $HOME/WRF
cd $HOME/WRF/WRF-4.3.2
cd ..
cp -r WRF-4.3.2 WRF
cd WRF
export WRF_CHEM=1
export WRF_KPP=1
export FLEX_LIB_DIR="/usr/lib/x86_64-linux-gnu/"
export YACC='/usr/bin/yacc -d'
export NETCDF_classic=1
./clean
echo "34 1" | ./configure # 34, 1 for gfortran and distributed memory
./compile em_real
./compile emi_conv

export WRF_DIR=$HOME/WRF/WRF

## WPSV4.3.1
cd $HOME/WRF/Downloads
tar -xvzf v4.3.1.tar.gz -C $HOME/WRF
cd $HOME/WRF/WPS-4.3.1
cd ..
cp -r WPS-4.3.1 WPS
cd WPS
echo "3" | ./configure
./compile >& com.pile

######################## Post-Processing Tools ####################
## ARWpost
cd $HOME/WRF/Downloads
tar -xvzf ARWpost_V3.tar.gz -C $HOME/WRF
cd $HOME/WRF/ARWpost
./clean
sed -i -e 's/-lnetcdf/-lnetcdff -lnetcdf/g' $HOME/WRF/ARWpost/src/Makefile
echo "3" | ./configure #3
sed -i -e 's/-C -P/-P/g' $HOME/WRF/ARWpost/configure.arwp
./compile

######################## Model Setup Tools ########################
## DomainWizard
cd $HOME/WRF/Downloads
mkdir $HOME/WRF/WRFDomainWizard
unzip WRFDomainWizard.zip -d $HOME/WRF/WRFDomainWizard
chmod +x $HOME/WRF/WRFDomainWizard/run_DomainWizard

######################## Static Geography Data ####################
# http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html
cd $HOME/WRF/Downloads
tar -xvzf geog_high_res_mandatory.tar.gz -C $HOME/WRF


## export PATH and LD_LIBRARY_PATH
echo "export PATH=$DIR/bin:$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export WRF_PROJ_HOME=/home/bik/WRF" >> ~/.bashrc
echo "export WRF_exec=$WRF_PROJ_HOME" >> ~/.bashrc
echo "export WRF_libs=$WRF_PROJ_HOME/Libraries" >> ~/.bashrc
echo "export WRF_run_dir=$WRF_exec/WRF/run" >> ~/.bashrc
echo "export WRF_chem_dir=$WRF_exec/WRF/chem" >> ~/.bashrc
echo "export WPS_run_dir=$WRF_exec/WPS" >> ~/.bashrc
echo "export prep_chem_dir=$WRF_PROJ_HOME/PREP_CHEM/PREP-CHEM-SRC-1.5/bin" >> ~/.bashrc