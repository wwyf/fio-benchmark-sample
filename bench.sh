#!/bin/bash

set -x

# devs=(/mnt/nvme/test-kljasnoi)
names=(HDD SSD NVMe)
devs=(/dev/sda /dev/sdb  /dev/nvme0n1)

for dev in ${devs[*]}
do

# fio latency/fiorandomreadlatency.fio
fio --filename=${dev} --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=1 --numjobs=1 --time_based --group_reporting --name=readlatency-test-job --runtime=120 --eta-newline=1 --readonly
# fio latency/fiorandomrwlatency.fio
fio --filename=${dev} --direct=1 --rw=randrw --bs=4k --ioengine=libaio --iodepth=1 --numjobs=1 --time_based --group_reporting --name=rwlatency-test-job --runtime=120 --eta-newline=1 --readonly

# fio bandwidth/fiorandomread.fio
fio --filename=${dev} --direct=1 --rw=randread --bs=64k --ioengine=libaio --iodepth=64 --runtime=120 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1 --readonly

# fio bandwidth/fiorandomread.fio
fio --filename=${dev} --direct=1 --rw=randrw --bs=64k --ioengine=libaio --iodepth=64 --runtime=120 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1

# fio bandwidth/fioread.fio
fio --filename=${dev} --direct=1 --rw=read --bs=64k --ioengine=libaio --iodepth=64 --runtime=120 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1 --readonly



# fio iops/fiorandomread.fio
fio --filename=${dev} --direct=1 --rw=randread --bs=4k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1 --readonly

# fio iops/fiorandomreadwrite.fio
fio --filename=${dev} --direct=1 --rw=randrw --bs=4k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1

# fio iops/fioread.fio
fio --filename=${dev} --direct=1 --rw=read --bs=4k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1 --readonly



done