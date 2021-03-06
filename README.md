# Minikube and OAuth2
This repository contains sources for a related 
[medium.com](https://medium.com/@klaushofrichter/minikube-and-oauth2-a2a383f4d531) article with more details. 
It explains how to configure OAuth2 for an existing Kubernetes Application running on Minikube. 

There are configured scripts and yaml files in this repository. You will need to adjust `config.sh` and the 
first few lines of the `start.sh` script to your needs. As a pre-requisite, you will need to have access to a 
certificate, which can be generated by checking out [another repository](https://github.com/klaushofrichter/Minikube-and-LetsEncrypt). 

There are two bash scripts: `start.sh` sets up the Minikube cluster, and `check-cert.sh <certfile>` shows the validity
of the certificate. 
