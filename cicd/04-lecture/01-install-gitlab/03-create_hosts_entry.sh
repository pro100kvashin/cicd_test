#!/bin/bash
# TODO: how will this run on students' machine when using cloud VM?
sudo sed -i '/gitlab.example.com/d; /registry.example.com/d' /etc/hosts
echo 127.0.0.1 gitlab.example.com registry.example.com | sudo tee -a /etc/hosts
