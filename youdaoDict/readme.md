## Introduction
This project has a python script.It can translate your input to the another language, both English and Chinese.
At the same time, it will record every valid words you have queried in which named 'histroy' file.This file is stored in the path where you store the script.

## Set Script Alias

### Alias in Linux
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

### Alias in Windows
>If you want to get a alias for the script, you should create the profile first.
>Run ```New-Item -Type file -Force $profile``` in any place.Then the profile will be created.
>Then edit the profile, add the ```Set-Alias [new name] [old name]```.For more information to query the [Set-Alias](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-alias?view=powershell-7.3)

exp:  
```powershell
Set-Alias -Name tl -Value translate

function translate () {
    param($words)
    py -3 D:\code\ShareTools\youdaoDict\translate.py --words $words
}
```

The case of query is same as the Linux.  

## Change Log
### 2023.9.19
- feat: recode script with python and fit new youdao dict web
