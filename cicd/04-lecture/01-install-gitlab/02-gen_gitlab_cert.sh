#!/bin/bash
cfssl gencert \
  -ca="pki/ca.pem" \
  -ca-key="pki/ca-key.pem" \
  -config="pki/ca-config.json" \
  -profile=slurm \
  pki/gitlab-csr.json | cfssljson -bare pki/gitlab.example.com

