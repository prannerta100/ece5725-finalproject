video_id="001"
input_mp4file="video/001_ManUdhanMarathi.mp4"
output_wavfile="Video${video_id}_$(date "+%Y.%m.%d-%H.%M.%S").wav"; 
rm -rf $output_wavfile
rm -rf video_fifo #remove the fifo if it exists
mkfifo video_fifo #create a new fifo
videolen=`ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $input_mp4file`
sudo SDL_VIDEODRIVER=fbcon SDL_FBDEV=/dev/fb1 mplayer -input file=video_fifo -vo sdl -framedrop $input_mp4file  &
arecord -D plughw:2,0 -d $videolen $output_wavfile
#Twinkle.mp4 #bigbuckbunny320p.mp4
#mplayer -ao alsa:device=hw=1.0 Twinkle.mp4
