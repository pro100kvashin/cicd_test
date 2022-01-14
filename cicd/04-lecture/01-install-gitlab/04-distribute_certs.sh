#!/bin/bash
sudo cp pki/ca.pem /usr/local/share/ca-certificates/slurm.example.crt
sudo update-ca-certificates
mkdir -p ssl
cp pki/gitlab.example.com.pem ssl/gitlab.example.com.crt
cp pki/gitlab.example.com-key.pem ssl/gitlab.example.com.key
cp pki/gitlab.example.com.pem ssl/registry.example.com.crt
cp pki/gitlab.example.com-key.pem ssl/registry.example.com.key
chmod 400 ssl/*.key
chmod 444 ssl/*.crt
sudo chown -R root:root ssl
