#!/usr/bin/bash

echo "Welcome to Recon"
read -p "Enter a Domain: " domain

echo "Start Amass"
amass enum --passive -silent -tr 1.1.1.1 -o amass_$domain.txt -d $domain

echo "Start Subfinder"
subfinder -d $domain -r 1.1.1.1 -silent -t 50 -o subfinder_$domain.txt

echo "Start Findomain"
findomain -t $domain -q --threads 50 -u $domain.txt 

echo "Remove Duplicates"
cat amass_$domain.txt subfinder_$domain.txt findomain_$domain.txt > domains.txt | sort -u | tee domains.txt
cat domains.txt |  httpx-toolkit -r 1.1.1.1 -o alive_domains.txt -silent

echo "Subdomain Takeover"
sed 's/https\?:\/\///' alive_domains.txt | tee takeover_testing.txt
subjack -c fingerprints.json -w takeover_testing.txt -t 50
