#!/bin/bash

sudo apt update -y; sudo apt upgrade -y;
sudo tasksel install desktop gnome-desktop -y
sudo systemctl set-default graphical.target;
sudo reboot;
