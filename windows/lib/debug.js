function DebugLog( filename, header_id, status_id )
{
	let file = fs.OpenTextFile( 'debug.txt', FS_APPEND, true );
	let header_elem = document.getElementById( header_id );
	let status_elem = document.getElementById( status_id );
	
	this.clear_header = function ( )
	{
		header_elem.innerHTML = '';
	}
	
	this.print_header = function ( text )
	{
		header_elem.innerHTML = text;
		file.WriteLine( strftime( "%Y-%m-%d %H:%M:%S: ", systime( ), TIMEZONE_OFFSET ) + text );
	}
	
	this.print_status = function ( text, is_logged )
	{
		status_elem.innerHTML = text;
		if( is_logged ) {
			file.WriteLine( strftime( "%Y-%m-%d %H:%M:%S: ", systime( ), TIMEZONE_OFFSET ) + text );
		}
	}
	
	return this;
}
