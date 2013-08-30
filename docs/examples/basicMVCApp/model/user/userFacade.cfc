<cfcomponent displayname="User Facade" hint="I am a facade to manipulate the user in session scope.">

	<cffunction name="init" access="public" returntype="userFacade" output="false" displayname="Init" >		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getUser" access="public" returntype="any" output="false" displayname="" hint="">
		<cflock scope="session" timeout="60">
			<cfreturn session.user />
		</cflock>
	</cffunction>

	<cffunction name="getProxyUser" access="public" returntype="any" output="false" displayname="" hint="">
		<cflock scope="session" timeout="60">
			<cfif structKeyExists( session, 'proxyUser' ) AND structKeyExists( session, 'user' )>
				<cfreturn session.user />
			</cfif>
			<cfreturn session.proxyUser />
		</cflock>
		<cfreturn false />
	</cffunction>
	
	<cffunction name="setUser" access="public" returntype="void" output="false" displayname="" hint="">
		<cfargument name="user"  type="user" required="true" />
		<cflock scope="session" timeout="60">
			<cfset session.user = arguments.user>		
		</cflock>
	</cffunction>

	<cffunction name="setProxyUser" access="public" returntype="void" output="false" displayname="" hint="">
		<cfargument name="user"  type="user" required="true" />
		<cflock scope="session" timeout="60">
			<cfif structKeyExists( session, 'user' ) AND NOT structKeyExists( session, 'proxyUser' )>
				<cfset session.proxyUser = duplicate( session.user )>
			</cfif>
			<cfset session.user = arguments.user />
		</cflock>
	</cffunction>

	<cffunction name="logoffProxy" access="public" returntype="void" output="false" displayname="" hint="">
		<cflock scope="session" timeout="60">
			<cfif structKeyExists( session, 'proxyUser' ) AND structKeyExists( session, 'user' ) >
				<cfset session.user = duplicate( session.proxyUser ) >
				<cfset structDelete( session, 'proxyUser') />		
			</cfif>
		</cflock>
	</cffunction>	
	
	<cffunction name="hasLogin" access="public" returntype="boolean" output="false" displayname="" hint="" >
		<cflock scope="session" timeout="60">
			<cfreturn (isDefined("session.user")) />
		</cflock>
	</cffunction>
	
	<cffunction name="doLogout" access="public" returntype="boolean" output="false" displayname="" hint="" >
		<cflock scope="session" timeout="60">
			<cfset StructDelete(session,"user")>
		</cflock>
	
		<cfreturn true>
	</cffunction>
	
</cfcomponent>