function ProgressBar( id )
{
	let elem = document.getElementById( id );
	
	this.reset = function ( )
	{
		elem.style.width = '0%';
	}
	
	this.set = function ( val )
	{
		elem.style.width = Math.floor( val ) + '%';
	}
	
	this.reset( );
	return this;
}

function MarkupTemplate( id )
{
	let elem = document.getElementById( id );
	let tmpl = elem.innerHTML;

	if( tmpl.search( /^<!--\s[^]+\s-->$/ ) == -1 )
		return null;
	tmpl = tmpl.slice( 5, -4 );

	this.remove = function ( )
	{
		elem.innerHTML = '';
	}
	
	this.update = function ( )
	{
		let args = [ tmpl ];
		args.push.apply( args, arguments );
		elem.innerHTML = sprintf.apply( null, args );  // workaround to pass through arguments
	}
	
	this.remove( );
	return this;
}
