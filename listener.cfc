<cfcomponent extends="object" output="no">

	<cffunction name="announce" access="public" returntype="void">
		<cfargument name="action" type="string" required="yes" />
		<cfif NOT StructKeyExists( request, 'action' )>
			<cfset request.action = createObject( 'component', 'action' ).init( args : arguments ) />
		</cfif>
		<cfset request.action.setArg('action',arguments.action) />
		<cfset createobject( 'component', 'requestHandler' ).handleRequest() />
	</cffunction>
	
	<cffunction name="redirect" access="public" returntype="void">
		<cfargument name="action" type="string" required="yes" />
		<cfif NOT StructKeyExists( request, 'action' )>
			<cfset request.action = createObject( 'component', 'action' ).init( args : arguments ) />
		</cfif>
		<cfset request.action.setArg( 'action', arguments.action ) />
		<cfset createobject( 'component', 'requestHandler' ).handleRequest() />
		<cfabort />
	</cffunction>
	
	<cffunction name='forward' access="public" returntype="void">
		<cfargument name="action" type="string" required="yes" />
		<cfargument name="args" type="array" required="no" default="#arrayNew(1)#" />
		<cfscript>
			var forwarder = createObject( 'component', 'cmdForward' ).init(
				action :arguments.action,
				args : arguments.args
			);
			request.action = forwarder.execute( request.action );
		</cfscript>
	</cffunction>
	
	<cffunction name='trigger' access="public" returntype="void">
		<cfargument name="component" type="string" required="yes" />
		<cfargument name="method" type="string" required="yes" />
		<cfargument name="resultVar" type="string" required="no" />
		<cfargument name="params" type="struct" required="no" default="#structNew()#" />
		<cfargument name="defaultValue" type="any" required="no" />
		<cfscript>
			var obj = createObject( 'component', 'cmdListener' ).init( argumentCollection : arguments );
			request.action = obj.execute( request.action, arguments.params );
		</cfscript>
	</cffunction>

</cfcomponent>