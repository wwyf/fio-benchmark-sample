#!/bin/bash

set -x
current=`date "+%Y-%m-%d-%H-%M-%S"`
LOGPATH=logs/${current}
mkdir -p ${LOGPATH}


function fio_latency_randr {
    bench_name=latency.randr
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randread \
    --bs=4k \
    --ioengine=libaio \
    --iodepth=1 \
    --numjobs=1 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 --readonly \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    latency=`cat ${log_path}/${store_type}.${bench_name}.log | grep -P ' +lat.*avg=(\d+.\d+),.*' -o | awk '{print $5}' | grep -P '\d+\.\d+' -o `
    echo ${bench_name},${store_type},${dev_name},${latency} >> ${log_path}/results.csv
}

function fio_latency_randw {
    bench_name=latency.randw
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randwrite \
    --bs=4k \
    --ioengine=libaio \
    --iodepth=1 \
    --numjobs=1 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    latency=`cat ${log_path}/${store_type}.${bench_name}.log | grep -P ' +lat.*avg=(\d+.\d+),.*' -o | awk '{print $5}' | grep -P '\d+\.\d+' -o `
    echo ${bench_name},${store_type},${dev_name},${latency} >> ${log_path}/results.csv
}

function fio_latency_randrw {
    bench_name=latency.randrw
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randrw \
    --bs=4k \
    --ioengine=libaio \
    --iodepth=1 \
    --numjobs=1 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    latency=`cat ${log_path}/${store_type}.${bench_name}.log | grep -P ' +lat.*avg=(\d+.\d+),.*' -o | awk '{print $5}' | grep -P '\d+\.\d+' -o `
    echo ${bench_name},${store_type},${dev_name},${latency} >> ${log_path}/results.csv
}


function fio_bandwidth_randr {
    bench_name=bandwidth.randr
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randread \
    --bs=64k \
    --ioengine=libaio \
    --iodepth=64 \
    --numjobs=4 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 --readonly \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    bandwidth=`cat ${log_path}/${store_type}.${bench_name}.log | grep "IOPS" | grep -P '(?<=MiB/s \()\d+\.*\d+.*/s' -o`
    echo ${bench_name},${store_type},${dev_name},${bandwidth} >> ${log_path}/results.csv
}

function fio_bandwidth_randw {
    bench_name=bandwidth.randw
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randwrite \
    --bs=64k \
    --ioengine=libaio \
    --iodepth=64 \
    --numjobs=4 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    bandwidth=`cat ${log_path}/${store_type}.${bench_name}.log | grep "IOPS" | grep -P '(?<=MiB/s \()\d+\.*\d+.*/s' -o`
    echo ${bench_name},${store_type},${dev_name},${bandwidth} >> ${log_path}/results.csv
}

function fio_throughput_randr {
    bench_name=throughput.randr
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randread \
    --bs=4k \
    --ioengine=libaio \
    --iodepth=256 \
    --numjobs=4 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 --readonly \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    tp=`cat cat ${log_path}/${store_type}.${bench_name}.log| grep "IOPS" | grep -P '(?<=IOPS=)\d+\.*\d+k*' -o`
    echo ${bench_name},${store_type},${dev_name},${tp} >> ${log_path}/results.csv

}

function fio_throughput_randw {
    bench_name=throughput.randw
    store_type=$1
    dev_name=$2
    log_path=$3

    fio --filename=${dev_name} \
    --rw=randwrite \
    --bs=4k \
    --ioengine=libaio \
    --iodepth=256 \
    --numjobs=4 \
    --direct=1 \
    --time_based --group_reporting --runtime=120 --eta-newline=1 \
    --name=${bench_name} | tee  ${log_path}/${store_type}.${bench_name}.log
    tp=`cat cat ${log_path}/${store_type}.${bench_name}.log| grep "IOPS" | grep -P '(?<=IOPS=)\d+\.*\d+k*' -o`
    echo ${bench_name},${store_type},${dev_name},${tp} >> ${log_path}/results.csv
}


# # devs=(/mnt/nvme/test-kljasnoi)
# names=(HDD SSD NVMe)
# devs=(/dev/sdb  /dev/nvme0n1)

store_index=(0 1 2)
store_types=(NVME_SSD SSD HDD)
devs=( /dev/nvme0n1 /dev/sdb /dev/sda  )


metrics=(throughput bandwidth latency )

bench_types=(randr randw)

for bench_type in ${bench_types[*]}
do
    for metric in ${metrics[*]}
    do
        for dev_id in ${store_index[*]}
        do
            fio_${metric}_${bench_type} ${store_types[${dev_id}]} ${devs[${dev_id}]} ${LOGPATH}
        done
    done
done