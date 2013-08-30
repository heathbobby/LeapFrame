<cfcomponent extends="object" output="no">
	<cfset variables.configFile = "leapframe.xml" />
	<cfset variables.configDir = "" />
	<cfset variables.configDTDPath  = ExpandPath('/leapframe/leapframe.dtd') />
	<cfset variables.xmlConfig = "" />
	<cfset variables.handlers = "" />
	
	
	<cffunction name="init" access="public" returntype="ApplicationLoader" output="false">
		<cfargument name="appConfig" type="struct" required="no" default="#structNew()#" />
		<cfset var i = 0 />
		<cfset var plugins = "" />
		<cfparam name="arguments.appConfig.isProd" type="boolean" default="false" />
		<cfif NOT StructKeyExists(application, 'appManager') OR arguments.appConfig.isProd EQ false>
			<cflock timeout="0" name="LeapFrameAppLoading" type="exclusive" throwontimeout="false">
				<cftry>
					<cfset structDelete(application,'appManager') />
					<cfset application.appManager = createObject('component','AppManager').init(arguments.appConfig) />
					<cfparam name="arguments.appConfig.configFile" default="leapframe.xml" />
					<cfset variables.configFile = arguments.appConfig.configFile />
					<cfset variables.configDir = arguments.appConfig.configdir />
					<cfset processConfig("#variables.configDir#/#variables.configFile#") />
					<cfset plugins = application.appManager.getPluginManager().getPlugins() />
					<cfloop from="1" to="#arrayLen(plugins)#" index="i">
						<cfset plugins[i].onApplicationLoad() />
					</cfloop>
					<cfset application.appManager.setLoaded(true) />
					<cfcatch type="any">
					<cfrethrow />
					</cfcatch>
				</cftry>
			</cflock>
		</cfif>
		<cfreturn super.init() />
	</cffunction>
	
	<cffunction name="processConfig" access="private" returntype="void" output="false">
		<cfargument name="configPath" type="String" required="yes" />
		<cfset var includes = arrayNew(1) />
		<cfset var j = 0 />
		<cfset var xmlConfig = "" />
		<cftry>
			<cftry>
				<cflock name="configFile#arguments.configpath#" type="exclusive" timeout="40" throwontimeout="yes">
					<cffile action="read" file="#arguments.configPath#" variable="xmlConfig" />
				</cflock>
				<cfcatch type="any">
					<cfthrow type="config.xml.fileNotFound" message="Config file not found." />
				</cfcatch>
			</cftry>
			<cfset validateConfig(xmlConfig) />
			<cfset loadProperties(xmlSearch(xmlConfig,'/leapframe/properties/property')) />
			<cfset loadHandlers(xmlConfig) />
			<cfset loadPlugins(xmlSearch(xmlConfig,'/leapframe/plugins/plugin')) />
			<cfset includes = xmlSearch(xmlConfig,'/leapframe/includes/include') />
			<cfloop from="1" to="#arrayLen(includes)#" index="j">
				<cfset processConfig("#variables.configDir##includes[j].xmlAttributes['xml']#.xml") />
			</cfloop>
			<cfcatch type="config.xml.invalid">
				<cfdump var="#CFCATCH#" label="config.xml.invalid" />
				<cfabort />
			</cfcatch>
			<cfcatch type="config.xml.handlers.include">
				<cfdump var="#CFCATCH#" label="config.xml.handlers.include" />
				<cfabort />
			</cfcatch>
			<cfcatch type="config.xml.fileNotFound">
				<cfdump var="#CFCATCH#" label="config.xml.fileNotFound" />
				<cfabort />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="validateConfig" access="public" returntype="void" output="false">
		<cfargument name="xmlConfig" type="xml" required="yes" />
		<cfset var results = xmlValidate("#arguments.xmlConfig#",variables.configDTDPath) />
		<cfif results.status NEQ 'YES'>
			<cfdump var="#results#" /><cfabort />
			<cfthrow message="Invalid xml Configuration" type="config.xml.invalid" />
		</cfif>
	</cffunction>
	
	<cffunction name="loadProperties" access="public" returntype="void" output="false">
		<cfargument name="arProperties" type="array" required="yes" />
		<cflock type="exclusive" scope="application" timeout="0">
			<cftry>
				<cfloop from="1" to="#ArrayLen(arProperties)#" index="i">
					<cfset application.appManager.setProperty(arProperties[i].xmlAttributes['name'],arProperties[i].xmlAttributes['value']) />
				</cfloop>
				<cfcatch type="any">
				</cfcatch>
			</cftry>
		</cflock>
	</cffunction>
	
	<cffunction name="loadHandlers" access="public" returntype="void" output="false">
		<cfargument name="xml" required="yes" type="xml" />
		<cfset var tempHandlers = xmlSearch(arguments.xml,'/leapframe/handlers/handler') />
		<cfset var i = 0 />
		<cftry>
			<cfloop from="1" to="#arrayLen(tempHandlers)#" index="i"> 
				<cfset arrayAppend(application.appManager.getHandlermanager().getHandlers(),tempHandlers[i]) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow message="Error Occurred appending handlers">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="loadPlugins" access="public" returntype="void" output="false">
		<cfargument name="plugins" required="yes" type="array" />
		<cfset var tempPlugins = arguments.plugins />
		<cfset var plugin = '' />
		<cfset var pluginDir = '' />
		<cfset var i = 0 />

		<cftry>
			<cfloop from="1" to="#arrayLen(tempPlugins)#" index="i">
				<cfset plugin = createObject('component','#application.appManager.getProperty('componentRoot')#plugins.'&tempPlugins[i].xmlAttributes['plugin']&'.'&tempPlugins[i].xmlAttributes['plugin']) />
					<cfif structKeyExists(tempPlugins[i].xmlAttributes,'config')>
						<cfset plugin.setProperty("config",tempPlugins[i].xmlAttributes['config']&'.xml') />
						<cfset plugin.setProperty("pluginName",tempPlugins[i].xmlAttributes['plugin']) />
						<cfif len(tempPlugins[i].xmlAttributes['config']) GT 0>
							<cfset processPluginConfig(plugin) />
						</cfif>
					</cfif>
					<cfset arrayAppend(application.appManager.getPluginManager().getPlugins(),plugin) />
			</cfloop>
			<cfcatch type="any">
				<cfthrow message="Error Occurred appending plugins">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="processPluginConfig" access="private" returntype="void" output="true">
		<cfargument name="plugin" type="any" required="yes" />
		
		<cfset var includes = arrayNew(1) />
		<cfset var j = 0 />
		<cfset var pluginConfigDir = "#ExpandPath(application.appManager.getProperty('pluginsDir','plugins\'))#\#plugin.getProperty('pluginName')#\config\" />
		<cfset var pluginConfig = "" />
		<cftry>
			<cftry>
				<cffile action="read" file="#pluginConfigDir##arguments.plugin.getProperty('config')#" variable="pluginConfig" />
				<cfcatch type="any">
					<cfdump var="#cfcatch#" /><cfabort />
					<cfthrow type="config.xml.fileNotFound" message="Config file not found." />
				</cfcatch>
			</cftry>
			
			<cfset validateConfig(pluginConfig) />
			<cfset loadPluginProperties(xmlSearch(pluginConfig,'/leapframe/properties/property'),arguments.plugin) />
			<cfset loadHandlers(pluginConfig) />
			<cfset includes = xmlSearch(pluginConfig,'/leapframe/includes/include') />
			<cfloop from="1" to="#arrayLen(includes)#" index="j">
				<cfset processConfig("#pluginConfigDir##includes[j].xmlAttributes['xml']#.xml") />
			</cfloop>
			<cfcatch type="config.xml.invalid">
				<cfdump var="#cfcatch#" />
				<cfabort />
			</cfcatch>
				
			<cfcatch type="config.xml.handlers.include">
				<cfdump var="#CFCATCH#" />
				<cfabort />
			</cfcatch>
				
			<cfcatch type="config.xml.fileNotFound">
				<cfdump var="#CFCATCH#" />
				<cfabort />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="loadPluginProperties" access="public" returntype="void" output="false">
		<cfargument name="arProperties" type="array" required="yes" />
		<cfargument name="plugin" type="any" required="yes" />
		<cfloop from="1" to="#ArrayLen(arProperties)#" index="i">
			<cfset arguments.plugin.setProperty(arProperties[i].xmlAttributes['name'],arProperties[i].xmlAttributes['value']) />
		</cfloop>
	</cffunction>
</cfcomponent>