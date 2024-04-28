
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
1. Install [Oracle VirtualBox](https://www.virtualbox.org/).
2. Download the VM Image [(P4 Tutorial 2019-08-15)](https://drive.google.com/open?id=1mfk-BiLQP3YHcOznaHoeio1fWHSNBnKw).
3. Import _P4 Tutorial 2019-08-15.ova_ appliance in VirtualBox.
4. Start the VM in VirtualBox and execute the following: 
   * Change to ```/home/vagrant``` directory.
     ```
     vagrant@p4:~$ cd /home/vagrant
     ```
   * Clone the ```p4lang/tutorials``` repository.
     ```
     vagrant@p4:~$ git clone https://github.com/p4lang/tutorials.git
     ```
   * Uninstall ```python-scapy``` and its dependent packages.
     ```
     vagrant@p4:~$ sudo apt-get remove --auto-remove python-scapy
     ```
   * Download and install Scapy 2.4.3.
     ```
     vagrant@p4:~$ git clone https://github.com/secdev/scapy.git 
     vagrant@p4:~$ cd scapy
     vagrant@p4:~/scapy$ sudo python setup.py install
     ```
   * Set environment ```PATH``` to scapy directory.
     ```
     vagrant@p4:~/scapy$ gedit ~/.bashrc
     ```
     * Add the following line to ```.bashrc``` file, save and exit. 
       ```
       export PATH="/home/vagrant/scapy:$PATH" 
       ```
     * Source ```.bashrc``` file.
       ```
       vagrant@p4:~/scapy$ source ~/.bashrc
       ```
   * Install ```tcpreplay``` package which is needed for executing ```sendpfast()``` scapy function.
     ```
     vagrant@p4:~$ sudo apt-get install tcpreplay
     ```
     
   * Change to the exercises directory.
     ```
     vagrant@p4:~/scapy$ cd ../tutorials/exercises/
     ```
   * Clone the burstradar repository and move to that directory.
     ```
     vagrant@p4:~/tutorials/exercises$ git clone https://github.com/harshgondaliya/burstradar.git
     vagrant@p4:~/tutorials/exercises$ cd burstradar
     vagrant@p4:~/tutorials/exercises/burstradar$
     
     ```

### B. Running BurstRadar
1. In the ```/home/vargrant/tutorials/exercises/burstradar/``` directory, execute:
   ```
   vagrant@p4:~/tutorials/exercises/burstradar$ sudo make run
   ```
   BMv2 Mininet CLI starts.
2. Open a new terminal and execute the following:
   * Start CLI
     ```
     vagrant@p4:~$ simple_switch_CLI
     ```
     Connection to the BMv2 simple_switch through thrift-port is started.
   * Set default values of ```bytesRemaining``` and ```index``` registers
     ```
     vagrant@p4:~$ simple_switch_CLI
     Obtaining JSON from switch...
     Done
     Control utility for runtime P4 table manipulation
     RuntimeCmd: register_write bytesRemaining 0 0
     RuntimeCmd: register_write index 0 0
     ```
   * Set mirror port for a given session id (In our case, session id = 11)
     ```
     RuntimeCmd: mirroring_add 11 4
     ```
3. In BMv2 Mininet CLI, execute:
   ```
   mininet> xterm h1 h2 h3 h4 h3
   ```
   Note: Two xterm displays for ```h3``` are started.
   * In ```h4```'s xterm display, execute:
     ```
     ./receive.py
     ```
   * In the first xterm display of ```h3```, execute:
     ```
     ./receive.py
     ```
   * In the second xterm display of ```h3```, execute:
     ```
     iperf -s -w 2m
     ```
   * In ```h2```'s xterm display, execute:
     ```
     iperf -c 10.0.3.3 -w 2m -t 35
     ```
     This ensures that approx. 4-4.5 Mbps background traffic is running between host 2 and host 3.
   * In ```h1```'s xterm display, execute:
     ```
     ./send.py 10.0.3.3 6700 300
     ```
     This ensures that approx. 10 Mbps burst traffic is sent from host 1 to host host 3.
   * A few packets that causes microburst will be marked and received at the monitoring server (```h4```). 
   * Similarly, burst traffic can be sent concurrently to multiple egress ports and the BurstRadar system will give desired results.

## Result Screenshots
![results](https://github.com/harshgondaliya/burstradar/blob/master/results-screenshot.PNG)
