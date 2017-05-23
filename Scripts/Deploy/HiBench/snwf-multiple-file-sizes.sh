HIBENCH_CONF_DIR=/root/HiBench/HiBench/conf

cp $HIBENCH_CONF_DIR/99-user_defined_properties.conf-005percent $HIBENCH_CONF_DIR/99-user_defined_properties.conf
./snowflake1.sh FS25MB

cp $HIBENCH_CONF_DIR/99-user_defined_properties.conf-020percent $HIBENCH_CONF_DIR/99-user_defined_properties.conf
./snowflake1.sh FS100MB

cp $HIBENCH_CONF_DIR/99-user_defined_properties.conf-050percent $HIBENCH_CONF_DIR/99-user_defined_properties.conf
./snowflake1.sh FS250MB

cp $HIBENCH_CONF_DIR/99-user_defined_properties.conf-100percent $HIBENCH_CONF_DIR/99-user_defined_properties.conf
./snowflake1.sh FS500MB

cp $HIBENCH_CONF_DIR/99-user_defined_properties.conf-default $HIBENCH_CONF_DIR/99-user_defined_properties.conf

