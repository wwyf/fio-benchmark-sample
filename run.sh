#!/bin/bash

./bench.sh  2>&1 | tee bench1.log
./bench.sh  2>&1 | tee bench2.log
./bench.sh  2>&1 | tee bench3.log