component extends="plugins.error.inc.resource.application.error" {
	this.name = 'one20';
	this.applicationTimeout = createTimeSpan(2, 0, 0, 0);
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0, 0, 30, 0);
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
}
