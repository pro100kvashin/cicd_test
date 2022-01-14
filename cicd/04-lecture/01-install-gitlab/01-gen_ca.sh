#!/bin/bash
cfssl gencert -config="pki/ca-config.json" -initca=true pki/ca-csr.json | cfssljson -bare pki/ca
