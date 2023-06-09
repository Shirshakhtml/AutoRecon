#!/bin/bash

sudo apt update && sudo apt upgrade
sudo apt install -y curl git python3 python3-pip sqlmap dirb nikto sqlmap nmap golang
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
sudo apt install -y golang-go
go install -v github.com/ffuf/ffuf@latest
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip3 install -r requirements.txt
sudo echo "export sublist3r= /home/rogucker/Sublist3r/sublist3r.py" >> ~/.zshrc
sudo apt install -y default-jre
pip install --upgrade git+https://github.com/Grunny/zap-cli.git

