/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component{

	this.name = "ColdBox Testing Harness" & hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.setClientCookies = true;
	this.clientManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,10,0);
	this.applicationTimeout = createTimeSpan(0,0,10,0);

	// setup test path
	this.mappings[ "/tests"   ] = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings[ "/testbox" ] = getDirectoryFromPath( getCurrentTemplatePath() ) & "../testbox";
	// setup root path
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	// ColdBox Root path
	this.mappings[ "/coldbox" ] 		= rootPath;
	// harness path
	this.mappings[ "/cbtestharness" ] 	= rootPath & "test-harness";


    _setupDatasource();

    // ORM Settings
    this.ormEnabled 	  = true;
    this.datasource		  = "coolblog";
    this.ormSettings	  = {
    	cfclocation 		= "/cbtestharness/models/entities",
    	logSQL 				= false,
    	flushAtRequestEnd 	= false,
    	autoManageSession 	= false,
    	eventHandling 	  	=  false
    };

	function onRequestStart( required targetPage ){

		//ORMReload();

		return true;
	}

	private void function _setupDatasource() {
		if ( _dsnExists() ) {
			return;
		}

		var dbConfig = {
			  port     = _getEnvironmentVariable( "COLDBOXTEST_DB_PORT"    , "3306" )
			, host     = _getEnvironmentVariable( "COLDBOXTEST_DB_HOST"    , "localhost" )
			, database = _getEnvironmentVariable( "COLDBOXTEST_DB_NAME"    , "coldboxtest" )
			, username = _getEnvironmentVariable( "COLDBOXTEST_DB_USER"    , "travis" )
			, password = _getEnvironmentVariable( "COLDBOXTEST_DB_PASSWORD", "" )
		};

		try {
			this.datasources[ "coolblog" ] = {
				  type     : 'MySQL'
				, port     : dbConfig.port
				, host     : dbConfig.host
				, database : dbConfig.database
				, username : dbConfig.username
				, password : dbConfig.password
				, custom   : {
					  characterEncoding : "UTF-8"
					, useUnicode        : true
				  }
			};
		} catch( any e ) {}
	}

	private boolean function _dsnExists() {
		try {
			var info = "";

			dbinfo type="version" name="info" datasource="coolblog";

			return info.recordcount > 0;
		} catch ( database e ) {
			return false;
		}
	}

	private string function _getEnvironmentVariable( required string variableName, string default="" ) {
		var result = CreateObject("java", "java.lang.System").getenv().get( arguments.variableName );

		return IsNull( result ) ? arguments.default : result;
	}
}