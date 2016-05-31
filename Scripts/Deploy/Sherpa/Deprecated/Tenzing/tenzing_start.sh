#!/bin/bash
tenzing_install_dir=/opt/sherpa/Tenzing/
tenzing_executable_file=Tenzing-1.0-jar-with-dependencies.jar
nohup java -cp  ${tenzing_install_dir}/${tenzing_executable_file} com.sherpa.tenzing.remoting.TenzingService    >> ${tenzing_install_dir}/tenzing.log &