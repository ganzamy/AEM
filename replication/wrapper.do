*******
* project: AEM replication
* paper: Bedard & Deschenes, 2004. "Sex Preferences, Marital Dissolution, and the Economic Status of Women"
* wrapper script that runs both files in order
* Author: A. Ganz
*******

global raw "/Users/amy/Dropbox/1. NYU Wagner/Fall 2016/AEM/replication"
clear all 
cd /* set CD to where files are stored*/ 
*run sample creation script 
do "replication_v1.do"

do 
