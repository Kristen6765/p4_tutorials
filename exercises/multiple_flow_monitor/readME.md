
# Monitoring Network Flows using P4
This repository contains implementation of BurstRadar system using P4 _V1Model Architecture_ on _simple_switch target_. 

This project allows users to configure and add flows they want to monitor at runtime using P4Runtime. The P4 program will truncate x bytes of the payload of routed messages in the selected flows and aggregate them with packet metrics and flow metrics (Ethernet Header, IPv4 Header, TCP Header, Source IP, Destination IP, Source Port, Destination Port, Ingress Timestamp, and Egress Timestamp) into the monitoring packets and send them out to the monitoring service.

<p align="center">
  <img src="https://github.com/Kristen6765/p4_tutorials/blob/master/exercises/multiple_flow_monitor/img/P4_Structure_Diagram.png">
</p>

A monitoring packet is limited by the standard Maximum Transmission Unit (MTU) for Ethernet, which is 1500 bytes. Thus, the number of truncated routed messages is also constrained. For example, if we want to aggregate 36 bytes from the routed messages' payloads into the monitoring packet, then the monitoring packet can contain at most 34 of them. (1500-50-12)/(36+6) = 34.

<p align="center">
  <img src="https://github.com/Kristen6765/p4_tutorials/blob/master/exercises/multiple_flow_monitor/img/P4_Monitoring_Packet.png">
</p>

## Environment Setup
### Option1 : Setup in a VM
Details are provoded in [p4_tutorial repository](https://github.com/p4lang/tutorials/edit/master/README.md)

- [Vagrant](https://vagrantup.com)
- [VirtualBox](https://virtualbox.org)
- At least 12 GB of free disk space, otherwise the installation can fail in unpredictable ways.

#### Installation Steps

1. Install Vagrant and VirtualBox on your system.
2. Clone the repository
   
   ```
   git clone https://github.com/p4lang/tutorials.git
   ```
3. Navigate to the cloned directory :
   
   ```
   cd vm-ubuntu-20.04
   ```
4. Start the virtual machine using Vagrant:
   ```
   vagrant up
   ```
   *Note* : The time for this step depends on your computer and Internet speed. On a 2015 MacBook Pro with a 50 Mbps download speed, it took approximately 20 minutes. Ensure a stable Internet connection throughout the process.


### Option2: Setup on local Machine
If you want to setup the P4 environment on you local machine instead of within a VM, follow the instruction below.

1. Clone the repo to your home directory
```
sudo su 
cd 
git clone https://github.com/p4lang/tutorials.git

```
2. Create a new user called, p4
```
New password:    p4                                                                                               
Retype new password:   p4                                                                                     
passwd: password updated successfully                                                                              
Changing the user information for vagrant                                                                          
Enter the new value, or press ENTER for the default                                                                              Full Name []:                                                                                            
Room Number []:                                                                                            
Work Phone []:                                                                                             
Home Phone []:                                                                                          
Other []:
```
3. Copy files to vagrant user
```
cd tutorials/vm-ubuntu-20.04
cp p4_16-mode.el  /home/vagrant/
cp p4.vim  /home/vagrant/
mkdir /home/vagrant/patches
cp patches/mininet-patch-for-2023-jun.patch /home/vagrant/patches/mininet-patch-for-2023-jun.patch
```

4. If you use Ubuntu 22.04, run the following cmd. If don't need to replace the root-release-bootstrap.sh if you are using Ubuntu20.04. For other version, you can check and change the configuration yourself. Replace the root-release-bootstrap.sh with the [root-release-bootstrap.sh](https://drive.google.com/drive/folders/19-deKM2I77z3q52bY6irn13Q1CbACP4s)

5. Change the user to vagrant and replace user-common-bootstrap.sh with [user-common-bootstrap.sh](https://drive.google.com/drive/folders/19-deKM2I77z3q52bY6irn13Q1CbACP4s)
```
usermod -aG sudo vagrant 
cp  user-common-bootstrap.sh /home/vagrant/ 
su vagrant      
cd
bash user-common-bootstrap.sh
```
6. Reboot your machine

```
sudo reboot
```

### Option3: Setup in a VM and Put Client, Server, and Monitor in to Dockers

## Test and Run the Project 

## Example Result 
![results](https://github.com/harshgondaliya/burstradar/blob/master/results-screenshot.PNG)
