#!/bin/awk -f
BEGIN {
	print( "-------------------------------------------------" );
	print( " RPAN Stream Recap v1.0" );
	print( " By Leslie E. Krause" );
	print( " https://github.com/sorcerykid/rpan_stream_recap" );
	print( "-------------------------------------------------" );
	print_log( "Process started for " ARGV[ 1 ] );

	NIL = "";
	FS = "\t";

	load_config( );
	if( YOUTUBE_DL == NIL || TARGET_FILENAME == NIL || TARGET_PATH == NIL || MAX_BITRATE == NIL || TIMEZONE_OFFSET == NIL ) {
		print( "Missing configuration settings, aborting!" );
		exit( 1 );
	}
}

function to_timestamp( str )
{
	return mktime( sprintf( "%d %d %d %d %d %d",
		substr( str, 1, 4 ), substr( str, 6, 2 ), substr( str, 9, 2 ), substr( str, 12, 2 ), substr( str, 15, 2 ), substr( str, 18, 2 ) ) );
}

function print_log( output )
{
	print output;
	print strftime( "%Y-%m-%d %H:%M:%S" ) ": " output >> "debug.txt";
}

{
	if( NR > 1 && SLEEP_PERIOD ) {
		print_log( sprintf( "Sleeping for %d seconds...", SLEEP_PERIOD ) );
		system( "sleep " SLEEP_PERIOD );
	}

	#================#
	# Prepare Stream #
	#================#

	subreddit = $1;
	stream_id = $2;
	post_created = to_timestamp( $3 ) + TIMEZONE_OFFSET * 3600;
	post_title = $4;

	filespec = TARGET_FILENAME;

        gsub( /%STREAM_ID%/, stream_id, filespec );
        gsub( /%SUBREDDIT%/, substr( subreddit, 3 ), filespec );
        gsub( /%POST_TITLE_PC%/, gensub( /[^A-Za-z0-9.,-_]/, "", "g", post_title ), filespec );
        gsub( /%POST_TITLE_SC%/, gensub( /[^a-z0-9().,-_]/, "_", "g", tolower( post_title ) ), filespec );
        gsub( /%POST_TITLE_KC%/, gensub( /[^a-z0-9().,-_]/, "-", "g", tolower( post_title ) ), filespec );
        gsub( /%POST_TITLE_TC%/, gensub( /[^A-Za-z0-9().,-_]/, "-", "g", post_title ), filespec );
        gsub( /%POST_DATE1%/, strftime( "%Y-%m-%d", post_created ), filespec );
        gsub( /%POST_DATE2%/, strftime( "%d-%b-%Y", post_created ), filespec );
        gsub( /%POST_DATE3%/, strftime( "%m-%d-%Y", post_created ), filespec );

	#================#
	# Capture Stream #
	#================#

	print_log( sprintf( "Capturing stream '%s' (%s) from '%s/%s'...",
		post_title, strftime( "%d-%b-%Y", post_created ), subreddit, stream_id ) );

	ctime = systime( );
	cmd = sprintf( "%s -r %s -o '%s' --newline --hls-prefer-native https://www.reddit.com/rpan/%s/%s",
		YOUTUBE_DL, MAX_BITRATE, TARGET_PATH "/" filespec, subreddit, stream_id );
	while( cmd | getline res ) {
		if( match( res, /^\[download\] +[0-9]+\.[0-9]%/ ) ) {
			# clear current line and reset cursor position
			printf( "\33[2K\r%s", res );
		}
		else {
			print_log( res );
			fflush( "debug.txt" );
		}
	}
	close( cmd );
	dtime = systime( ) - ctime;
	print_log( sprintf( "Capture completed (%d min %d sec).",
		int( dtime / 60 ), dtime % 60 ) );

	print_log( sprintf( "Calculating checksum of '%s'...", filespec ) );

	cmd = sprintf( "md5sum '%s'", TARGET_PATH "/" filespec );
	while( cmd | getline res ) {
		print_log( "MD5: " substr( res, 1, 32 ) );
	}
	close( cmd )

	system( sprintf( "touch -d @%d '%s'", post_created, TARGET_PATH "/" filespec ) );
	print_log( sprintf( "Changed timestamp of '%s' to %s.",
		filespec, strftime( "%d-%b-%Y %Z", post_created ) ) );

	#===============#
	# Upload Stream #
	#===============#

	if( BACKUP_PATH != NIL ) {
		print_log( sprintf( "Uploading '%s' to '%s' via %s...",
			filespec, BACKUP_PATH, match( BACKUP_PATH, /^remote:/ ) ? "rclone" : "rsync" ) );

		ctime = systime( );
		if( match( BACKUP_PATH, /^remote:/ ) ) {
			system( sprintf( "rclone -P copy '%s' %s", TARGET_PATH "/" filespec, BACKUP_PATH ) );
		}
		else {
			system( sprintf( "rsync -Pt '%s' %s", TARGET_PATH "/" filespec, BACKUP_PATH ) );
		}
		dtime = systime( ) - ctime;
		print_log( sprintf( "Upload completed (%d min %d sec).",
			int( dtime / 60 ), dtime % 60 ) );

		system( sprintf( "rm '%s'", TARGET_PATH "/" filespec ) );
	}
}

END {
	print_log( "Process stopped for " ARGV[ 1 ] );
}
