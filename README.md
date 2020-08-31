# LISF Docker Image

## Motivation

This image presents an easier way to run [LISF](https://github.com/NASA-LIS/LISF) workflows on your local system. This was developed to avoid having to rebuild binaries and install all the dependencies which can be a few weeks of work.

## Build Details

Currently LDT and LIS are the tools that compile and have been tested against test cases. They are compiled with the following dependencies:

-   ESMF - We use a base docker image from [DockerHub](https://hub.docker.com/r/bekozi/esmf)
-   HDF4
-   HDFEOS 2
-   Jasper v2.0.19
-   ECCodes v2.18.0
-   LISF v7.3.0-rc8-557WW

This repository also automatically builds and publishes the Docker Image to DockerHub using GitHub Actions

## Installation and Running locally

### Prerequisites

The only requirement is having Docker and Docker Compose installed on your machine.

-   Docker - https://docs.docker.com/get-docker/
-   Docker Compose - https://docs.docker.com/compose/install/

Once you have the above installed, you can get this image running locally by following these steps:

```sh
git clone https://github.com/BYU-Hydroinformatics/lisf.git
cd lisf
docker-compose up -d
```

This starts the container that has LISF pre-compiled and also mounts the directory `files` from your `lisf` directory into the container. You can add test case files and retrieve run outputs and logs from this directory.

To run the test cases, follow the below steps

-   Enter the container - `docker exec -it lis bash`
-   Fix the configuration files: When you download the test cases from https://lis.gsfc.nasa.gov/tests/lis, the configuration files expect that your executable for LDT/LIS/LVT is present in the same directory as the test case files. To fix that, you need to update the paths in your `.config` files within the testcase directory. As an example the lines you will change in the `ldt.config.noah36_params` for `Test Case 1` are listed below. Basically, you want to replace `./` with a full path to the files which will always be `/home/files/<test_case_directory_name>`:

```
Processed LSM parameter filename:       /home/files/testcase1_ldt_parms/lis_input.nldas.noah36.d01.nc
LDT diagnostic file:                    /home/files/testcase1_ldt_parms/ldtlog
Landcover file:            /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/igbp.bin
Soil texture map:               /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/topsoil30snew
Elevation map:       	/home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/topo_parms/SRTM30/raw_wgtopo30antarc
Slope map:     		/home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/topo_parms/SRTM30/raw_wgtopo30antarc
Aspect map:       	/home/files/testcase1_ldt_parms/INPUTLS_PARAMETERS/topo_parms/SRTM30/raw_wgtopo30antarc
Albedo map:                 /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/albedo
Max snow albedo map:        /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/maximum_snow_albedo.hdf
Greenness fraction map:        /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/gfrac
Greenness maximum map:         /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/gfrac_max.asc
Greenness minimum map:         /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/gfrac_min.asc
Bottom temperature map:          /home/files/testcase1_ldt_parms/INPUT/LS_PARAMETERS/noah_2dparms/SOILTEMP.60
```

-   Move to the directory containing the binaries: `cd /home/apps`
-   To run LDT: `./LDT <path to the config file>` which for `Test Case 1` would be `./LDT /home/files/testcase1_ldt_parms/ldt.config.noah36_params`
-   To Run LIS: `./LIS <path to the config file>` which for `Test Case 2` would be `./LIS /home/files/testcase2_lis_ol/lis.config_noah36_ol`

### Notes

-   To run test case 2, you will need to download the files using the wget script as mentioned in the documentation. The script by default will download all the years data for 2017. However, to speed up testing, you may choose to download only a few days worth of data by changing the `Date Inputs` (around line 20) in your `wget_gesdisc_nldas2.sh` script. If you do change that, then you need to update the `lis.config_noah36_ol` file as well (lines 28 to 39)
-   While running a test case if you get a `bad write` error, it means that your `.config` file has wrong paths to the input files that the process needs. Ensure that the paths you put in the config files are absolute and the files do exist at that location.

## Future Improvements

-   Get LVT to compile
-   Reduce Image Size
