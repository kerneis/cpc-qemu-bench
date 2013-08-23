#!/bin/bash

wget http://www.ctshepherd.com/testbedhdd.img.bz2
bunzip2 testbedhdd.img.bz2

# We need to set the correct permissions on the private key, as ssh doesn't
# like it being open but git won't remember how the correct permissions.
chmod 0600 cpc-test.rsa
