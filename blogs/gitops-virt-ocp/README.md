This repository is a companion to the Learning Path for using GitOps with OpenShift Virtualization. While it is designed specifically for following along, much of the content should be usable elsewhere with some customization. A brief rundown of the directory structure follows.


Base: Contains the generic yaml files that will provide the basis for the building of our virtual machines.


    - *base-vm-disk.yaml* defines the basic storage that will be used for the virtual machine and utilizing volume import populators.
    - *base-vm-import-source.yaml* is the file used to pull the specified RHEL image for our VM.
    - *base-vm.yaml* contains the basic specifications for our virtual machine configuration.

Overlays: Contains the subdirectories "dev" and "prod" which provide the customizations for a hypothetical development and production environment. 

    - *base-vm-import-source.yaml* which dev and prod will use to import the RHEL image
    - *kustomization.yaml* which defines the resources to be used.

Dev and Prod subdirectories: Each contains files to be used to customize environments. 

    - *config.yaml* is used to change the names of resources based on the virtual machine names.
    - **-vm-patch.yaml* files contain some simple patches to modify the specs of the VMs. It also sets running=true so the machine start up after creation.

