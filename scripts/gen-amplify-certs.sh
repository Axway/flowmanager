#!/bin/bash
#

openssl genpkey -algorithm RSA -out ./configs/catalog-private-key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in ./configs/catalog-private-key.pem -out ./configs/catalog-public-key.pem
