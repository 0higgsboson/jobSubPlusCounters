#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./customer_package.sh sherpa.tar.gz sherpa.properties"
    exit
fi

#Extract the tar file
echo "Extract the sherpa package"

tar -xzvf $1

echo "Replace the standard sherpa.properties file"
cp $2 sherpa/sherpa.properties

echo "Creating the customer package"
tar -czvf custom_sherpa.tar.gz sherpa/

rm -rf sherpa/
echo "Done packaging sherpa artifacts for customer..."
