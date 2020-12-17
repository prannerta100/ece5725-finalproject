import sys, re, 
import soundfile as sf
import pandas as pd
import numpy as np

#src_file: user recording
#ref_file: video from the user
#to run the program, type "python3 score.py $output_wavfile $input_mp4file" on the command line or in the Shell script

#min 3 arguments needed
if len(sys.argv) < 3:
    sys.exit()
#if >=3 arguments, great! Read the src_file (arg1) and ref_file (arg2)
else:
    src_file = 'user_recordings/' + sys.argv[1]
    ref_file = re.sub('\.mp4', '.wav', sys.argv[2])

#print the file names, before starting the scoring process
print('Input file: 'src_file, ' Output File: ', ref_file)

#read the source and reference files
data_src, samplerate_src = sf.read(src_file)
data_ref, samplerate_ref = sf.read(ref_file)

#choose the first channel from the reference audio, discard the rest
data_ref = data_ref[:,0]

#define pandas dataframes with the appropriate time index
data_ref_df = pd.DataFrame({'ref':data_ref}, index = np.arange(len(data_ref)) / samplerate_ref)
data_src_df = pd.DataFrame({'src':data_src}, index = np.arange(len(data_src)) / samplerate_src)

#"outer" join the 2 data frames and then interpolate to fill in the gaps
df = data_ref_df.join(data_src_df, how='outer').apply(pd.Series.interpolate)

#find the max run times of each video, take the minimum
#we calculate the score based on the minimum of the song time and the user's recording duration
#nominally these times should be the same
run_time = min(max(data_ref_df.index), max(data_src_df.index))
df = df.loc[df.index <= run_time]

#correlation score
correlation = 50 * min(np.abs(df.corr().iloc[0,1]), 0.03) / 0.03
#persistence score
persistence = 50 * df.loc[np.abs(df['src']) > 0.1 * np.max(np.abs(df['src']))].shape[0] / \
                   df.loc[np.abs(df['ref']) > 0.1 * np.max(np.abs(df['ref']))].shape[0]
#sum the 2 scores (total is out of 100)
score = int(round(correlation + persistence))
print(score)
