# WVD automation script to logoff all user sessions and shutdown all VMs from a hostpool

## DISCLAIMER
This script is provided as sample and must not be used in production environment without previous customizations and tests.
**IMPORTANT:** *This script will shutdown all VMs in the WVD host pool. If you don't want to shutdown all VMs, you need to customize the script first!*

## Overview

This powershell script list all WVD Virtual Machines and for each VM, it lists the connected user sessions and send a message to each user warning about session logoff. 
After a pre-defined time, it disconnect the user session and then shutdown the VM.

## How to Use this template
This script is ready to be used in Azure Automation with Azure RunAs Account created.
Before creating Azure Automation runbook you must install the following modules on Azure Automation:
- Go to Modules, then Browse Gallery and install this modules on the following order:
     1.	Az.Accounts
     2.	Az.Compute
     3.	Az.DesktopVirtualization

- After installing the modules, you can just import WVD-AUTOSHUTDOWN.ps1 file as runbook and create the schedule to shutdown the VMs.

- To start-up the VMs you can use any script from the runbook gallery.



