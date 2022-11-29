var async_id = null;

function asyncLoop( callback )
{
	let parent_async_id = async_id;
	let id = window.setInterval( function ( ) {
		if( async_id == id && !callback( ) ) {
			window.clearInterval( id );			
			if( parent_async_id == null )
				window.close( );
			else
				async_id = parent_async_id;
		}
	}, 100 );  // 100 ms should be adequate for GUI event handling
	async_id = id;
}

function asyncProcess( procs )
{
	let idx = 0;
	asyncLoop( function ( ) {
		if( idx == procs.length )
			return false;
		procs[ idx++ ]( );
		return true;
	} )
}
