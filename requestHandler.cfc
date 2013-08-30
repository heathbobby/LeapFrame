<cfcomponent extends="object" output="no">
	<cfset variables.udf = createObject('component','udf') />
	<cffunction name="init" access="public" returntype="requestHandler" output="false">
		<cfargument name="action" type="any" required="no" default="#createObject('component','action').init()#"/>
			<cfif NOT structKeyExists(request,'action') >
				<cfset request.action = arguments.action /> 
			</cfif>
			<cfreturn super.init() />
	</cffunction>
	
	<cffunction name="handleRequest" access="public" returntype="void">
		<cfscript>
			var listener = "";
			var i = "";	
			var viewer = "";
			var handler = "";
			var filterer = "";
			var stylesheets = "";
			var scripts = "";
			var args = "";
			var params = "";
			var urlAr = "";
			var plugins = "";
			var tempArray = "";
		</cfscript>
		<cflock name="LeapFrameAppLoading" type="Readonly" timeout="50" throwOnTimeout="true">
		<cfset plugins = application.appManager.getPluginManager().getPlugins() />
		<cftry>
			<cfloop from="1" to="#arrayLen(plugins)#" index="i">
				<cfset plugins[i].onRequestStart(request.action) />
			</cfloop>
			<cfset handler = application.appManager.getHandlerManager().getHandler(request.action.getArg('action')) />
			<cfscript>
				getPageContext().getOut().clearBuffer();
				for(i=1; i LTE arrayLen(handler[1].xmlChildren); i=i+1){
					switch(handler[1].xmlChildren[i].xmlName){
						case 'listener':
								params = structNew();
								tempArray = xmlSearch(handler[1].XmlChildren[i],'param');
								for(j=1; j LTE arrayLen( tempArray ); j=j+1){
									if( structKeyExists(tempArray[ j ].xmlAttributes, "value")){
										params[ '#tempArray[ j ].xmlAttributes.name#' ] = tempArray[ j ].xmlAttributes.value;
									} else {
										params[ '#tempArray[ j ].xmlAttributes.name#' ] = tempArray[ j ].xmlText;
									}
								}
								listener = createObject('component','cmdlistener').init(
									component:handler[1].XmlChildren[i].xmlAttributes.component,
									method:handler[1].XmlChildren[i].xmlAttributes.method
								);
								if(structKeyExists(handler[1].XmlChildren[i].xmlAttributes,'resultVar')){
									listener.setResultVar(handler[1].XmlChildren[i].xmlAttributes.resultVar);
								}
								request.action = listener.execute(request.action, params);
						break; 
						case 'actionArg':
								request.action.setArg(handler[1].XmlChildren[i].xmlAttributes.name,handler[1].XmlChildren[i].xmlAttributes.value);
						break;
						case 'view':
								viewer = createObject('component','view').init(templateName:handler[1].XmlChildren[i].xmlAttributes.templateName);
								if(structKeyExists(handler[1].XmlChildren[i].xmlAttributes,'resultVar')){
									viewer.setResultVar(handler[1].XmlChildren[i].xmlAttributes.resultVar);
								}
								request.action = viewer.invokeView(request.action);
						break;
						case 'filter':
								filterer = createObject('component','filter').init(component:handler[1].XmlChildren[i].xmlAttributes.component, method:handler[1].XmlChildren[i].xmlAttributes.method);
								if(structKeyExists(handler[1].XmlChildren[i].xmlAttributes,'faultAction')){
									filterer.setFaultAction(handler[1].XmlChildren[i].xmlAttributes.faultAction);
								}
								request.action = filterer.execute(request.action);
						break;
						case 'announce':
								request.action.setArg('action',handler[1].XmlChildren[i].xmlAttributes.action);
								handleRequest();
						break;
						case 'redirect':
								request.action.setArg('action',handler[1].XmlChildren[i].xmlAttributes.action);
								handleRequest();
								variables.udf.abort();
						break;
						case 'forward':
								forwarder = createObject('component','cmdForward').init(
									action:handler[1].XmlChildren[i].xmlAttributes.action,
									args: xmlSearch(handler[1].XmlChildren[i],'arg')
								);
								request.action = forwarder.execute(request.action);
						break;
						case 'stylesheets':
								stylesheets = xmlSearch(handler[1],'stylesheets/file');
								for(j=1; j LTE arrayLen(stylesheets); j=j+1){
									request.action.setArg('stylesheets',listAppend(request.action.getArg('stylesheets'),stylesheets[j].XmlText));
								}
						break;
						case 'scripts':
								scripts = xmlSearch(handler[1],'scripts/file');
								for(j=1; j LTE arrayLen(scripts); j=j+1){
									request.action.setArg('scripts',listAppend(request.action.getArg('scripts'),scripts[j].XmlText));
								}
						break;
					}
				}
				if(structKeyExists(handler[1].XmlAttributes,'outputFormat') AND handler[1].XmlAttributes.outputFormat EQ 'json'){
					createObject('component','AjaxGateway').request(request.action);
				}
				if(structKeyExists(handler[1].XmlAttributes,'outputFormat') AND handler[1].XmlAttributes.outputFormat EQ 'xml'){
					createObject('component','xmlGateway').request(request.action);
				}
				if(structKeyExists(handler[1].XmlAttributes,'outputFormat') AND handler[1].XmlAttributes.outputFormat EQ 'ajaxUpload'){
					createObject('component','AjaxUploadGateway').request(request.action);
				}
			</cfscript>
			<cfloop from="1" to="#arrayLen(plugins)#" index="i">
				<cfset plugins[i].onRequestEnd(request.action) />
			</cfloop>
			<cfcatch type="request.Handler.getHandler">
				<cfdump var="#CFCATCH#" />
				<cfabort />
			</cfcatch>
			
			<cfcatch type="request.handler.none">
				<cfdump var="#CFCATCH#" />
				<cfabort />
			</cfcatch>
			<!--- cfcatch type="any">
				<!--- <cfthrow message="Either the handler was not defined, or it was defined more than once." /> --->
				An error occured while processing the XML configuration document.<br />
				<cfdump var="#CFCATCH#" />
				<cfabort />
			</cfcatch --->
			</cftry>
			</cflock>
	</cffunction>
	
</cfcomponent>
