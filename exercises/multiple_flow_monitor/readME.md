
# Monitoring Network Flows using P4
This repository contains implementation of BurstRadar system using P4 _V1Model Architecture_ on _simple_switch target_. 

This project allows users to configure and add flows they want to monitor at runtime using P4Runtime. The P4 program will truncate x bytes of the payload of routed messages in the selected flows and aggregate them with packet metrics and flow metrics (Ethernet Header, IPv4 Header, TCP Header, Source IP, Destination IP, Source Port, Destination Port, Ingress Timestamp, and Egress Timestamp) into the monitoring packets and send them out to the monitoring service.

<p align="center">
  <img src="https://github.com/Kristen6765/p4_tutorials/blob/master/exercises/multiple_flow_monitor/img/P4_Structure.png">
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


### Option2: Setup on Your Local Machine
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

4. If you use Ubuntu 22.04, replace the root-release-bootstrap.sh with the [root-release-bootstrap.sh](https://drive.google.com/drive/folders/1rG9Tbu0P64-LJdb2ESjVIWjQmZtJSo11), then run the following cmd.
```
bash root-release-bootstrap.sh 
```
You don't need to replace the root-release-bootstrap.sh if you are using Ubuntu20.04. For other versions, you can check and change the configuration in this file first.

6. Change the user to vagrant and replace user-common-bootstrap.sh with [user-common-bootstrap.sh](https://drive.google.com/drive/folders/1rG9Tbu0P64-LJdb2ESjVIWjQmZtJSo11)
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
Before proceeding with Option 3, please check if you have already installed Mininet using Option 1 or Option 2. If the installation has been completed, remove Mininet from the previous installation first to avoid conflicts. Alternatively, you can set up Mininet on a different machine.
1. Clone the FOP4.
```
git clone https://github.com/ANTLab-polimi/FOP4.git
```

2. Flow the instructions from [FOP4](https://github.com/ANTLab-polimi/FOP4/tree/master/P4_examples) to install and test their program.

3. Download the [fop4.zip](https://drive.google.com/drive/folders/1rG9Tbu0P64-LJdb2ESjVIWjQmZtJSo11), unzip it and placce it in the directory FOP4/tree/master/P4_examples.


## Test and Run the Project 
### For Option1 and Option2
1. In the project directory, for example the current directory, then run
```
sudo make run
```

2. Specify the flow that you want to monitor by adding the entries to the table, flow_register, in the P4 program. The examples below will monitor 2 flows.

10.0.3.3 (h3, server) -> 10.0.1.1 (h1, client1)
    
10.0.3.3 (h3, server) -> 10.0.1.2 (h1, client2)
```
simple_switch_CLI
mirroring_add 11 4
table_add flow_register registerFlowAction 10.0.3.3&&&255.255.255.255 10.0.1.1&&&255.255.255.255 3333&&&65535 0&&&0 => 1 0
table_add flow_register registerFlowAction 10.0.3.3&&&255.255.255.255 10.0.2.2&&&255.255.255.255 3333&&&65535 0&&&0 => 2 0

```
3. You can check the entries in a table by running
```
table_dump flow_register
```
4. You can remove an entry from the table, for example remove the first entry, by running
```
table_delete flow_register 0
```

### For Option3 with YCSB
1. To run with YCSB we need to first get all the dockers setup and then used Option3. 
Dockers are listed in the [google drive](https://drive.google.com/drive/folders/1rG9Tbu0P64-LJdb2ESjVIWjQmZtJSo11)

2. Re-config the docker images in the start.py. For example, replace the current dimage to the image you want to use a different docker.
```
dsql = net.addDocker('dsql', cls=P4DockerHost, ip='172.17.0.2/24',
                   dimage="sqln", mac="00:00:00:00:00:02")
```
3. Run start.py
```
python3 start.py
```
4. Follow the instructions printed out in the terminal.
5. If you have trouble starting the services in the dockers.
For SQL docker, to start the service by running
```
su mysql 
/usr/sbin/mysqld --skip-grant-tables --general-log &
```
For Memcache Docker, to start the service by running
```
su memcache 
$ memcached &
```
For Server Docker, to start the service by running
```
bash ./bin/catalina.sh run &
bash ./bin/catalina.sh stop 
```
For other references of how to run the YCSB docker, check this [documentation](https://docs.google.com/document/d/187HpxOOeDQnsVq4m6vORfAjuiwciMNLbZ7lzsBjfh5A/edit#heading=h.nuqhosrglcir)

## Example Result 
H4 contains the trucnated TCPpayloads from the flow (server -> client1). The current one that is displayed on the screenshot is the 36th one. 
<p align="center">
  <img src="https://github.com/Kristen6765/p4_tutorials/blob/master/exercises/multiple_flow_monitor/img/result.png">
</p>


## Contact
Developer: Jiahui (Kristen) Peng

Email: jiahui(dot)peng(at)mail(dot)mcgill(dot)ca

Developer: Mona Elsaadawy 

Email: mona(dot)elsaadawy(at)mcgill(dot)ca
