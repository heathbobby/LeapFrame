<cfparam name="request.LeapFrameConfig" default="#structNew()#" />
<cfscript>
	createObject('component','ApplicationLoader').init(request.LeapFrameConfig);
	structDelete(request,'LeapFrameConfig');
	variables.params = structNew();
	structAppend(variables.params,url,true);
	structAppend(variables.params,form,true);
	createObject('component','leapframe.requestHandler').init(createObject('component','leapframe.action').init(args:params)).handleRequest();
</cfscript>