## Introduction
This project includes two scripts, bash shell for Linux and PowerShell for Windows.They can translate your input to the another language, both English and Chinese.
At the same time, it will record every valid words you have queried in which named 'record' file.This file is stored in the path where you store the script.

## Eaxmple in Linux
> First, I suggest you to adding a instruction to call the scripte. You can add the following  code to your **.bashrc**.After that, don't forget to reload the .bashrc by ```source .bahsrc```  .
>```shell
>if [ -f (script's path) ]; then
>	alias (the new instruction name)="(script's path)
>fi
>```
>At this section, I use 'tl' to call the script.

A example of query Chinese by English:  
tl help  
A example of query English by Chinese:   
tl 帮助  
Query the record:  
tl -h  
Clear the record:  
tl -c

## Example in Windows
>If you want to get a alias for the powershell script, you should create the profile first.
>Run ```New-Item -Type file -Force $profile``` in any place.Then the profile will be created.>Then edit the profile, add the ```Set-Alias [new name] [old name]```.For more information to query the [Set-Alias](htpps://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-alias?view=powershell-5.1)
The case of query is same as the Linux.  



