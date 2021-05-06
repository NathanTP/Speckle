#!/bin/bash

#defaults TODO: Make = number of harts?
copies=1

function usage
{
    echo "usage: intrate.sh <benchmark-name> [-H | -h | --help] [--copies <int>] [--workload <int>]"
    echo "   benchmark-name: the spec17 run directory with binary and inputs"
    echo "   copies: number of rate instances to run (2GiB each) Default: ${copies}"
}

if [ $# -eq 0 -o "$1" == "--help" -o "$1" == "-h" -o "$1" == "-H" ]; then
    usage
    exit 3
fi

bmark_name=$1
shift

while test $# -gt 0
do
   case "$1" in
        --copies)
            shift;
            copies=$1
            ;;
        -h | -H | --help)
            usage
            exit
            ;;
        --*) echo "ERROR: bad option $1"
            usage
            exit 1
            ;;
        *) echo "ERROR: bad argument $1"
            usage
            exit 2
            ;;
    esac
    shift
done

mkdir -p ~/output
work_dir=$PWD

runscript="run.sh"
echo "Starting rate $bmark_name run with $copies copies"

echo "Creating run directories"
for i in `seq 0 $[ ${copies} - 1 ]`; do
    cp -al $work_dir/$bmark_name ${work_dir}/copy-$i
done

for i in `seq 0 $[ ${copies} - 1 ]`; do
    cd $work_dir/copy-$i
    echo "name,RealTime,UserTime,KernelTime,copy" >> ~/output/${bmark_name}_${i}.csv
    /usr/bin/time -a -o ~/output/${bmark_name}_${i}.csv -f "${bmark_name},%e,%U,%S,${i}" \
       ./run.sh > ~/output/${bmark_name}_${i}.out 2> ~/output/${bmark_name}_${i}.err &
done
sleep 10
while pgrep -f run.sh > /dev/null; do sleep 10; done
