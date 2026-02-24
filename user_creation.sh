#!/bin/bash

# Make sure /kasmdata exists
mkdir -p /kasmdata

# Create directories user1 ... user20
for i in $(seq 1 20); do
    mkdir -p /mnt/kasm-nfs/user$i
done

echo "20 user directories created inside /kasmdata/"
