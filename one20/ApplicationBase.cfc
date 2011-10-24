component {
	this.name = 'one20';
	this.applicationTimeout = createTimeSpan(2, 0, 0, 0);
	this.sessionManagement = true;
	this.sessionType = 'j2ee';
	
	this.mappings['/root'] = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings['/plugins'] = this.mappings['/root'] & "plugins/";
	
	public void function onApplicationEnd(required string applicationScope) {
		// Start the application
		arguments.applicationScope.sparkplug.end(arguments.applicationScope);
	}
	
	public boolean function onApplicationStart() {
		var appConfigFile = expandPath('config/project.json.cfm');
		
		application.sparkplug = createObject('component', 'algid.inc.resource.application.sparkplug').init( this.mappings['/root'] );
		
		// Start the application
		application.sparkplug.start(application);
		
		return true;
	}
	
	public void function onRequestEnd(required string targetPage) {
		// End the request
		return request.sparkplug.end( application, session, request, arguments.targetPage );
	}
	
	public boolean function onRequestStart(required string targetPage) {
		request.sparkplug = createObject('component', 'algid.inc.resource.request.sparkplug').init();
		
		// Start the request
		return request.sparkplug.start( application, session, request, url, form, arguments.targetPage );
	}
	
	public void function onSessionEnd(required struct sessionScope, required struct applicationScope) {
		// End the session
		arguments.sessionScope.sparkplug.end( arguments.applicationScope, arguments.sessionScope );
	}
	
	public void function onSessionStart() {
		session.sparkplug = createObject('component', 'algid.inc.resource.session.sparkplug').init();
		
		// Start the session
		session.sparkplug.start( application, session );
	}
	
	private numeric function __determineSessionTimeout(array shortPaths = [], numeric days = 0, numeric hours = 0, numeric minutes = 30, numeric seconds = 0, numeric milliseconds = 0) {
		local.shortSession = createTimeSpan(0, 0, 0, 10);
		
		local.scriptLen = len(cgi.script_name);
		
		for (local.i = 1; local.i <= arrayLen(arguments.shortPaths); local.i++) {
			local.pathLen = len(arguments.shortPaths[local.i]);
			
			if(local.scriptLen >= local.pathLen
					&& left(cgi.script_name, local.pathLen) == arguments.shortPaths[local.i]
					&& !structKeyExists(getHttpRequestData().headers, 'x-requested-with')) {
				return local.shortSession;
			}
		}
		
		local.bots = [
			"80legs",
			"Bot",
			"Accoona-AI-Agent",
			"Arachmo",
			"alexa",
			"appie",
			"spider",
			"Ask Jeeves",
			"crawl",
			"FAST",
			"Firefly",
			"froogle",
			"InfoSeek",
			"inktomi",
			"looksmart",
			"NationalDirectory",
			"rabaz",
			"Scooter",
			"Slurp",
			"Spade",
			"TECNOSEEK",
			"Teoma",
			"WebBug",
			"www.galaxy.com",
			"Yahoo! Slurp",
			"ZyBorg"
		];
		
		local.agent = cgi.http_user_agent;
		
		for (local.i = 1; local.i <= arrayLen(bots); local.i++) {
			if(findNoCase(bots[local.i], local.agent)) {
				return local.shortSession;
			}
		}
		
		return createTimeSpan(arguments.days, arguments.hours, arguments.minutes, arguments.seconds, arguments.milliseconds);
	}
}
