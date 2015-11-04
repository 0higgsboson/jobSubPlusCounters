#!/bin/sh

# Assumptions
# 1. Run as root

mkdir ~/shakespeare
cd ~/shakespeare/
wget http://www.gutenberg.org/cache/epub/100/pg100.txt
mv pg100.txt a
cat a a a a a a a a a a > b
cat b b b b b b b b b b > a
cat a a a a a a a a a a > c
cp b b1 b2 b3 b4 b5 b6
cp b b1; cp b b2; cp b b3; cp b b4; cp b b5; cp b b6; cp b b7; cp b b8; cp b b9; cp b b10;
ls -altr
hadoop fs -ls
source /etc/environment 
cat /etc/environment 
hadoop fs -ls
cd ~/jobSubPlusCounters/Scripts/Setup/
