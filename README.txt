RPAN Stream Recap v1.0
By Leslie E. Krause

RPAN Stream Recap provides an efficient and reliable means for RPAN broadcasters to
retrieve their video content directly from Reddit's servers as an HLS stream.

The package consists of the following files:

  /rpan_stream_recap
  |- README.txt
  |- LICENSE.txt
  |- recap.awk
  |- config.awk

This project depends on youtube-dl, which can be downloaded either from the official
homepage or from the GitHub repository:

  https://yt-dl.org/
  https://github.com/ytdl-org/youtube-dl

I also recommend ffmpeg for post-processing of videos. It is available here:

  https://ffmpeg.org/

Before running the script for the first time, you should open 'config.awk' and change
the configuration settings below. Any lines beginning with '#' will be ignored.

  * YOUTUBE_DL
    This is the location of the 'youtube-dl' program, typically under '/usr/local/bin'.

  * TARGET_PATH
    This is the target path where videos are to be stored. Be sure there is sufficient 
    free space on the filesystem (one hour of content requires ~1.0 GB of storage). If
    a backup path is specified, then the target path will serve as a staging area.

  * BACKUP_PATH (optional)
    This is the backup path where videos will be uploaded. For ordinary file transfers 
    over SSH or SFTP, rsync will be used. However, by prepending 'remote:' to the backup 
    path, rclone will be used instead (as required by many cloud hosts). Once the file 
    transfer is completed, the video will be removed from the staging area.

  * MAX_BITRATE
    This controls the bandwidth throttling for captures. I found 5 MB/s to be the most
    reliable. Anything higher runs the risk of Reddit's servers rejecting fragments. You 
    should not need to increase this value.

  * SLEEP_PERIOD (optional)
    This is the delay in seconds between successive captures. I recommend the default of 
    30 seconds so as not to overtax Reddit's servers.

  * TARGET_FILENAME
    This is the target filename for the video with an ".mp4" extension. It should consist
    of one or more tokens to be replaced with dynamic values:

    - %STREAM_ID% will be replaced with the stream ID (yvkxh1)
    - %SUBREDDIT% will be replaced with the subreddit (RedditSets)
    - %POST_TITLE_PC% will be replaced with the post title (PascalCase)
    - %POST_TITLE_SC% will be replaced with the post title (snake_case)
    - %POST_TITLE_KC% will be replaced with the post title (kebab-case)
    - %POST_TITLE_TC% will be replaced with the post title (Train-Case)
    - %POST_DATE1% will be replaced with the post date (2022-04-15)
    - %POST_DATE2% will be replaced with the post date (15-Apr-2022)
    - %POST_DATE3% will be replaced with the post date (04-15-2022)

  * TIMEZONE_OFFSET
    This is the number of hours difference from UTC for your timezone. It is used for 
    calculating the date in the TARGET_FILENAME as well as for setting the modification
    time of the video.

Your show history will be used to process the captures. This is a tab-delimited text file
containing four fields: Subreddit, StreamID, PostDate, and PostTitle. This file can be 
generated automatically by the RPAN Show History tool:

  https://github.com/sorcerykid/rpan_show_history/

To retrieve all of your shows, simply leave this file as-as. However, a limited range of
shows can be retrieved by removing the corresponding lines.

To run the script, you must specify a configuration file and a show history file:

  % ./recap.awk -f config.awk history.txt

Note: You must set the execute permissions for 'recap.awk'.

All output from the script, including that of youtube-dl, will be logged to 'debug.txt'.
If the file doesn't already exist, it will be created.

Occasionally, missing fragments may be encountered. These warnings are often temporary
and can be overcome by retrying the capture from scratch. If the same fragment(s) fail, 
on a subsequent attempt, then that is typically indicative of an interruption during the
original broadcast (i.e. a connection drop).

Be aware that the video will likely be unplayable due audio synchronization issues. This
can be fixed by remuxing the audio and video tracks without re-encoding. The following 
command should solve the problem:

  % ffmpeg -y -i input.mp4 -c copy -f mp4 "-bsf:a" aac_adtstoasc output.mp4

If you find this project useful, then please consider supporting my work:

  https://givebutter.com/sorcerykid

Feel free to check out my other RPAN broadacaster tools on GitHub as well.
