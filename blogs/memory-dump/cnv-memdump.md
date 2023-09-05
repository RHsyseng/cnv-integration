# Creating and Utilizing Virtual Machine Memory Dumps in OpenShift Virtualization  

As any person who works in the technology field will tell you, even the most redundant systems experience outages. A valuable part of learning what happened and how to prevent it from happening again can come from memory and crash dumps, which most operating systems have been able to produce for some time. They can show you what was running at the time of the crash, and allow greater insight into the issue.

Using the ```virtctl memory-dump``` option within OpenShift Virtualization can help you do just that. It allows you to grab the virtual memory directly from system that is experiencing trouble, even if it's not accessible through conventional means. A huge advantage OpenShift Virtualization tools give you is that it is OS independent, and we don't need to rely on waiting for a physical or virtual machine to be accessible again to grab what was running in memory.

In this article, we'll demonstrate how to get a crashed virtual machine's memory and a couple of ways that we can check to see what may be happening. 

## Generating a Virtual Machine Memory Dump Using Virtctl from the CLI

Creating the memory dump and downloading it for use is a relatively simple command, but does require that you have the 'virtctl' command line tool available. This can be acquired directly from the OpenShift UI by selecting the "Command line tools" link in the help menu.

For this demonstration we'll be using a Windows Server 2019 and a RHEL 9 virtual machine, but this process works the same for any OS that OpenShift Virtualization supports. Let's take a look at the vm to get an idea of what we're working with. Since we're only concerned with the size of the memory allocated to it, which will affect the time involved to create and download the dump, we can grep just for the memory in the yaml output. The command used is below:

```
$ oc get vm beehive-win19 -o yaml | grep memory
            memory: 4Gi
```
We're working with 4Gi, so the process overall will complete quickly. Completion times will, of course, vary depending on machine configuration. Now we create and export the memory dump with the following command:

```
$ virtctl memory-dump get beehive-win19 \
> --create-claim --claim-name=beehive-win19-mem \
> --output=windows19-mem.dump.tar.gz
```
Above, we create a memory dump of the beehive-win19 virtual machine and create a new pvc in which to store the dump, giving it the name "beehive-win19-mem". A vm export job is then created, and the memory dump named "windows19-mem.dump.tar.gz" is downloaded to the machine from which we ran the command. The vm export job is then removed. Alternatively, if you have a pvc that is already available, you can simply omit ```--create-claim``` and enter the desired storage instead of creating a new one. Below is a truncated example of the output:

```
PVC beehive-virtual-machines/beehive-win19-mem created
Successfully submitted memory dump request of VM beehive-win19
Waiting for memorydump  to complete, current phase: Associating...
Waiting for memorydump  to complete, current phase: InProgress...
Memory dump completed successfully
VirtualMachineExport 'beehive-virtual-machines/export-beehive-win19-beehive-win19-mem' created successfully
waiting for VM Export export-beehive-win19-beehive-win19-mem status to be ready...
Downloading file: 1.47 GiB [==================>] 3.27 MiB p/s                                                                                                     
Download finished successfully
VirtualMachineExport 'beehive-virtual-machines/export-beehive-win19-beehive-win19-mem' deleted successfully
```
So now that we have the memory dump, what do we do with it? Let's explore a couple examples.

## Obtaining Information from an OpenShift VM Memory Dump

After decompressing the tar files, let's run a couple of commands using the [volatility3 tool](https://github.com/volatilityfoundation/volatility3) on the memory dumps. The output below shows a truncated list of the processes the Windows server was running, its parent processes, and some additional info.

```
$ python3 vol.py -f beehive-win19-beehive-win19-mem-20230808-135236.memory.dump windows.pslist

Volatility 3 Framework 2.5.0

Progress:  100.00		PDB scanning finished                        

PID	PPID	ImageFileName	Offset(V)	Threads	Handles	SessionId	Wow64	CreateTime	ExitTime	File output

4	0	    System	    0x880a18c78040	86	-	N/A	False	2023-07-31 23:36:55.000000 	N/A	Disabled
88	4	    Registry	0x880a18d99040	4	-	N/A	False	2023-07-31 23:36:52.000000 	N/A	Disabled
292	4	    smss.exe	0x880a1c175040	2	-	N/A	False	2023-07-31 23:36:55.000000 	N/A	Disabled
400	388	    csrss.exe	0x880a1d799140	10	-	0	False	2023-07-31 23:37:03.000000 	N/A	Disabled
476	468	    csrss.exe	0x880a1c136080	9	-	1	False	2023-07-31 23:37:04.000000 	N/A	Disabled
496	388	    wininit.exe	0x880a1d9ac080	1	-	0	False	2023-07-31 23:37:04.000000 	N/A	Disabled
```

Now let's look at a RHEL memory dump using a similar command. Below is the truncated output of the RHEL 9 virtual machine's process list. 

*Please note that in order to run these commands on a linux memory dump successfully, you will need to follow the [guide](https://github.com/volatilityfoundation/dwarf2json) the volatility team provides to gather the correct debug symbols for your kernel.*

```
python3 vol.py -v -f cnv-galera-db01-beehive-galeradb01-mem-20230829-184446.memory.dump linux.pslist

Volatility 3 Framework 2.5.0

Progress:  100.00		Stacking attempts finished

OFFSET (V)	    PID	TID	PPID    COMM

0x8b27c0251c80	1	1	0	    systemd
0x8b27c0255580	2	2	0	    kthreadd
0x8b27c0253900	3	3	2	    rcu_gp
0x8b27c0250000	4	4	2	    rcu_par_gp
0x8b27c027b900	5	5	2	    slub_flushwq
0x8b27c0278000	6	6	2	    netns
```

## Connecting the Digital Dots

Whether you require the ability to find out why something went awry, track down malicious software, or analyze what was happening on a system when it was compromised, the memory dump option that comes with the virtctl tools can be an invaluable accessory at your disposal with OpenShift virtual machines.