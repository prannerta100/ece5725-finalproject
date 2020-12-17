#video id
video_id="001"

#input mp4 file from video/ folder
input_mp4file="video/001_ManUdhanMarathi.mp4"

#output file with time stamp; this will contain the user recording .wav
output_wavfile="Video${video_id}_$(date "+%Y.%m.%d-%H.%M.%S").wav"; 

#remove video_fifo if exists 
rm -rf video_fifo #remove the fifo if it exists

#create a new fifo, for emergency control of the mplayer 
#(not needed, unless you try to stop the karaoke song midway)
mkfifo video_fifo 

#calculate length of the video
videolen=`ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $input_mp4file`

#run the lyrical video through mplayer 
sudo SDL_VIDEODRIVER=fbcon SDL_FBDEV=/dev/fb1 mplayer -input file=video_fifo -vo sdl -ao alsa:device=hw=1.0 -framedrop $input_mp4file  &

#record the user song
arecord -D plughw:2,0 -f S32_LE -d `printf "%.0f" $(echo scale=3;$videolen | bc)` user_recordings/$output_wavfile


#upload folder on Drive
rclone copy user_recordings/$output_wavfile remote:backup/user_recordings/


#misc, ignore!
#Twinkle.mp4 #bigbuckbunny320p.mp4
#mplayer -ao alsa:device=hw=1.0 Twinkle.mp4
