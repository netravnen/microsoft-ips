#!/bin/bash

uri=https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a7
dir=$(dirname $0)/microsoft-ips
jsonfile=${dir}/ms-endpoints.json
textfile=${dir}/ms-endpoints-ips-all.list

# Check if dir exists, else create it
if [ ! -d ${dir} ]; then
  mkdir -p ${dir}
fi

# Ensure blank file upon re-run
printf '' > ${textfile}

# Fetch json file from ms website
curl -snGL -o ${jsonfile} -z ${jsonfile} ${uri}

for id in $(cat ${jsonfile} | jq '.[] | select(.ips) | .id'); do
  cat ${jsonfile} |
    jq ".[] | select(.id == ${id}) | .ips[]" |
    sed 's/^"//;s/"$//' |
    tee ${dir}/ms-endpoint-${id}-ips.txt

  cat ${jsonfile} |
    jq ".[] | select(.id == ${id}) | .ips[]" |
    sed 's/^"//;s/"$//' |
    tee -a ${textfile}
done

for id in $(cat ${jsonfile} | jq '.[] | select(.urls) | .id'); do
  cat ${jsonfile} |
    jq ".[] | select(.id == ${id}) | .urls[]" |
    sed 's/^"//;s/"$//' |
    tee ${dir}/ms-endpoint-${id}-urls.txt
done

for id in $(cat ${jsonfile} | jq '.[] | select(.tcpPorts) | .id'); do
  cat ${jsonfile} |
    jq ".[] | select(.id == ${id}) | .tcpPorts | split(\",\")[]" |
    sed 's/^"//;s/"$//' |
    tee ${dir}/ms-endpoint-${id}-tcpports.txt
done

for id in $(cat ${jsonfile} | jq '.[] | select(.udpPorts) | .id'); do
cat ${jsonfile} |
    jq ".[] | select(.id == ${id}) | .udpPorts | split(\",\")[]" |
    sed 's/^"//;s/"$//' |
    tee ${dir}/ms-endpoint-${id}-udpports.txt
done

git add microsoft-ips/*
git commit -m "Updates files - $(date -uR)"
