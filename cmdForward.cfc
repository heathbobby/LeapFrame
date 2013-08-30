<cfcomponent extends="command" output="no">
	<cfset variables.udf = createObject('component','udf') />
	<cfset variables.args = "" />
	<cfset variables.argString = "" />
	
	<cffunction name="init" access="public" returntype="cmdForward" output="false">
		<cfargument name="action" type="string" required="yes" />
		<cfargument name="args" type="array" required="no" default="" />
		<cfset setAction(arguments.action) />
		<cfset setArgs(arguments.args) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="action" output="false">
		<cfargument name="action" required="yes" type="action">
			<cfscript>
				var argString = "";
				request.action.setArg('action',getAction());
				try{
					variables.udf.location('?action=' & getAction() & getArgString(),false);
				}
				catch(any e){
						variables.udf.dump(e,true);
				}
			</cfscript>
		<cfreturn arguments.action />
	</cffunction> 
	
	<cffunction name="getAction" access="public" returntype="string" output="false">
		<cfreturn variables.action />
	</cffunction>
	<cffunction name="setAction" access="public" returntype="void" >
		<cfargument name="action" type="string" required="yes" /> 
		<cfset variables.action = arguments.action />
	</cffunction>	
	
	<cffunction name="getArgs" access="public" returntype="array" output="false">
		<cfreturn variables.args />
	</cffunction>
	<cffunction name="setArgs" access="public" returntype="void" >
		<cfargument name="args" type="array" required="yes" /> 
		<cfset variables.args = arguments.args />
	</cffunction>
	
	<cffunction name="getArgString" access="public" returntype="String" output="true">
		<cfscript>
			var i = 0;
			var args = getArgs();
			var attributes = structNew();
			var value = "";
			
			for(i=1; i LTE arrayLen(args); i=i+1){
				
				if( structKeyExists( args[ i ], 'xmlAttributes' ) ) {
					attributes = args[ i ].xmlAttributes;
				}
				else {
					attributes = args[ i ];
				}

				value = request.action.getArg(attributes.name);
				if(structKeyExists(attributes,'translate')){
					value = request.action.getArg(attributes.translate);
				}
				if(structKeyExists(attributes,'value')){
					value = attributes.value;
				}
				
				try{
					variables.argString = variables.argString & "&" & attributes.name & "=" & value;
				}
				catch(any e){
					continue;
				}
			}
		</cfscript>
		<cfreturn variables.argString />
	</cffunction>
	
	
</cfcomponent>