## Introduction
Translate.sh is a shell script which can quickly find the words according to the input for English and Chinese.It use the youdao dict page to implemente the function.  
At the same time, it will record every valid words you have queried in which named 'record' file.This file is stored in the path which you store the script.

## Eaxmple
> First, I suggest you to adding a instruction to call the scripte. You can add the following  code to your **.bashrc**.
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


