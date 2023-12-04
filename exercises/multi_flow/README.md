# 


### Environment Setup
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

### How to Run it 

