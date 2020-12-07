#!/bin/bash
for file in `ls *.mp4`
do
	ffmpeg -i $file `sed 's/\(.*\.\)mp4/\1wav/'`
done
exit
for file in `ls *.mp4`
do
	ffmpeg -i $file -vf scale=320:240,setsar=1:1 output.mp4
	mv output.mp4 $file
done
