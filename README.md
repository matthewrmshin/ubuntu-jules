# ubuntu-jules

JULES with netCDF in a Docker container based on the Ubuntu image, with input/output from/to AWS S3 buckets.

## Building the container

Checkout a copy of this project. Change directory to its work tree.

Checkout or export of copy of the JULES source tree under `jules-source/`.

Run `docker build . -t ubuntu-jules`.

## Running the container

Create an AWS S3 bucket for JULES input. E.g. `aws s3 mb s3://jules-nml/`.

Create an AWS S3 bucket for JULES output. E.g. `aws s3 mb s3://jules-out/`.

Upload input namelists and input files to the input bucket.
Ensure that the output directory is set up `./output`.

Run `docker run -e RUN_JULES_INPUT=jules-nml -e RUN_JULES_OUTPUT=jules-out ubuntu-jules`.

On success, the output files will be uploaded to the output bucket.
