#!/bin/bash -ex
registry=casp/site-php7.1
time docker build $1 -t $registry . &&  time docker push $registry

