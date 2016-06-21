FROM ubuntu:14.04

WORKDIR /opt/data-geo

# essential libs
RUN apt-get update \
	&& apt-get install -y build-essential \
	&& apt-get install -y python-pip python-dev wget \
	&& apt-get install -y vim \
	&& apt-get install -y curl \
	&& apt-get install -y cython \
	&& apt-get install -y mercurial software-properties-common \
	&& apt-get install -y git-all


# install GEOS, PROJ4, TIFF 
RUN add-apt-repository ppa:ubuntugis/ppa \
	&& apt-get update \
	&& apt-get install -y libfreetype6-dev libpng-dev \
	&& apt-get install -y gdal-bin python-gdal libgdal-dev libgeos-dev libproj-dev libtiff4-dev libgeotiff-dev \
	&& apt-get install -y gsl-bin libgsl0-dev \
	&& add-apt-repository ppa:george-edison55/cmake-3.x \
	&& apt-get update

# skimage
RUN apt-get install -y python-skimage

# matplotlib and basemap
RUN apt-get install -y python-matplotlib \
	&&  apt-get install -y python-mpltoolkits.basemap

# rsgislib
RUN apt-get -y install cmake \
	&& apt-get install -y libboost-filesystem-dev \
	&& apt-get install -y libgmp3-dev \
	&& apt-get install -y libmpfr-dev \
	&& apt-get install -y libgeos++-dev \
	&& apt-get install -y libmpfr-doc libmpfr4 libmpfr4-dbg \
	&& apt-get install -y libcgal-dev \
	&& apt-get install -y libatlas-base-dev gfortran

RUN pip install --upgrade pip 

WORKDIR /tmp
RUN hg clone https://bitbucket.org/chchrsc/kealib
WORKDIR /tmp/kealib/trunk
RUN cmake .
RUN make
RUN make install

RUN apt-get install -y libmuparser-dev

WORKDIR /tmp
RUN hg clone https://bitbucket.org/petebunting/rsgislib rsgislib-code 
WORKDIR /tmp/rsgislib-code
RUN cmake CMakeLists.txt 
RUN CPATH=/usr/include/gdal make  
RUN make install 

WORKDIR /tmp
COPY requirements.txt ./
RUN pip install -r requirements.txt
# tensor flow
RUN export TF_BINARY_URL=https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl
RUN pip install --upgrade $TF_BINARY_URL
RUN git clone git://github.com/Theano/Theano.git
WORKDIR /tmp/Theano
RUN python setup.py develop

WORKDIR /tmp
RUN jupyter notebook --generate-config 
RUN git clone https://github.com/ipython-contrib/IPython-notebook-extensions.git
RUN mkdir ~/.local
RUN mkdir ~/.local/share
RUN mkdir ~/.local/share/jupyter

WORKDIR /tmp/IPython-notebook-extensions
RUN python setup.py install 

WORKDIR /opt/data-geo
CMD jupyter-notebook --no-browser --port 8888 --ip=0.0.0.0

