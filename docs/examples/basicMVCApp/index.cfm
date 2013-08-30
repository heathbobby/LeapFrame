<cfif NOT structKeyExists(application,'appmanager') OR structKeyExists(url,'reloadApp')>
	<cfset request.LeapFrameConfig = StructNew() />
	<cfset request.LeapFrameConfig['configDir'] = ExpandPath('config/') />
	<cfset request.LeapFrameConfig['configFile'] = 'LeapFrame.xml' />
	<cfset request.LeapFrameConfig['isProd'] = false />
<cfelse>
	<cfset request.LeapFrameConfig['isProd'] = true /> <!--- This will be true normally --->
</cfif>

<cfinclude template="/leapframe/leapframe.cfm" />