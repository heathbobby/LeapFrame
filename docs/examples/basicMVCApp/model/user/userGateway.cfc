<cfcomponent displayname="userGateway" extends="leapframe.gateway" output="false">
	
	<cffunction name="init" access="public" output="false" returntype="userGateway">
		<cfargument name="dsn" type="string" required="true" />
		<cfset variables.dsn = arguments.dsn />
		<cfreturn super.init(argumentCollection: arguments) />
	</cffunction>
	
	<cffunction name="getByAttributesQuery" access="public" output="false" returntype="query">
		<cfargument name="id" type="Numeric" required="false" />
		<cfargument name="username" type="String" required="false" />
		<cfargument name="password" type="String" required="false" />
		<cfargument name="lastLogin" type="String" required="false" />
		<cfargument name="createDate" type="String" required="false" />
		<cfargument name="modifiedDate" type="String" required="false" />
		<cfargument name="personId" type="Numeric" required="false" />
		<cfargument name="active" type="boolean" required="false" />
		<cfargument name="orderby" type="string" required="false" default="p.lastName" />
		<cfargument name="dir" type="string" required="false" default="ASC" />
		<cfargument name="start" type="Numeric" required="false" default="0" />
		<cfargument name="limit" type="Numeric" required="false" />
		<cfargument name="count" type="boolean" required="false" default="false" />
		
		<cfset var qUsers = "" />		
		<cfquery name="qUsers" datasource="#variables.dsn#">
			SELECT
				<cfif arguments.count>
					count(u.id) as count
				<cfelse>
					u.id,
					u.username,
					u.password,
					u.lastLogin,
					u.createDate,
					u.modifiedDate,
					u.personId,
					u.active,
					u.roleid,
					p.firstName,
					p.middleName,
					p.lastName,
					p.email,
          u.organizationId,
					n.name,
					r.role
				</cfif>
			FROM	user as u
			JOIN person as p ON p.id = u.personId
			LEFT OUTER JOIN role as r ON r.id = u.roleId
			LEFT OUTER JOIN organization_name n ON u.organizationId = n.organizationId
						AND n.id = 
						(
						SELECT id
						FROM organization_name as a 
						WHERE a.organizationId = u.organizationId 
						ORDER BY a.EffectiveDate DESC
						LIMIT 1)
			WHERE	0=0
		
		<cfif structKeyExists(arguments,"id") and len(arguments.id)>
			AND	u.id = <cfqueryparam value="#arguments.id#" CFSQLType="cf_sql_integer" />
		</cfif>
		<cfif structKeyExists(arguments,"username") and len(arguments.username)>
			AND	u.username = <cfqueryparam value="#arguments.username#" CFSQLType="cf_sql_varchar" />
		</cfif>
		<cfif structKeyExists(arguments,"password") and len(arguments.password)>
			AND	u.password = <cfqueryparam value="#arguments.password#" CFSQLType="cf_sql_varchar" />
		</cfif>
		<cfif structKeyExists(arguments,"lastLogin") and len(arguments.lastLogin)>
			AND	u.lastLogin = <cfqueryparam value="#arguments.lastLogin#" CFSQLType="cf_sql_timestamp" />
		</cfif>
		<cfif structKeyExists(arguments,"createDate") and len(arguments.createDate)>
			AND	u.createDate = <cfqueryparam value="#arguments.createDate#" CFSQLType="" />
		</cfif>
		<cfif structKeyExists(arguments,"modifiedDate") and len(arguments.modifiedDate)>
			AND	u.modifiedDate = <cfqueryparam value="#arguments.modifiedDate#" CFSQLType="" />
		</cfif>
		<cfif structKeyExists(arguments,"personId") and len(arguments.personId)>
			AND	u.personId = <cfqueryparam value="#arguments.personId#" CFSQLType="cf_sql_integer" />
		</cfif>
		<cfif structKeyExists(arguments,"active") and len(arguments.active)>
			AND	u.active = <cfqueryparam value="#arguments.active#" CFSQLType="cf_sql_bit" />
		</cfif>
		<cfif structKeyExists(arguments,"roleId") and len(arguments.roleId)>
			AND	u.roleId = <cfqueryparam value="#arguments.roleId#" CFSQLType="cf_sql_integer" />
		</cfif>
		<cfif structKeyExists(arguments,"firstName") and len(arguments.firstName)>
			AND	p.firstName = <cfqueryparam value="#arguments.firstname#" CFSQLType="cf_sql_varchar" />
		</cfif>
		<cfif structKeyExists(arguments,"middleName") and len(arguments.middleName)>
			AND	p.middleName = <cfqueryparam value="#arguments.middleName#" CFSQLType="cf_sql_varchar" />
		</cfif>
		<cfif structKeyExists(arguments,"lastName") and len(arguments.lastName)>
			AND	p.lastName = <cfqueryparam value="#arguments.lastName#" CFSQLType="cf_sql_varchar" />
		</cfif>
		<cfif structKeyExists(arguments,"email") and len(arguments.email)>
			AND	p.email = <cfqueryparam value="#arguments.email#" CFSQLType="cf_sql_varchar" />
		</cfif>
		<cfif structKeyExists(arguments,"organizationId") and len(arguments.organizationId)>
			AND	u.organizationId = <cfqueryparam value="#arguments.organizationId#" CFSQLType="cf_sql_integer" />
		</cfif>
		<cfif structKeyExists(arguments, "orderby") and len(arguments.orderBy)>
			ORDER BY #arguments.orderby# #arguments.dir#
		</cfif>
		<cfif structKeyExists(arguments, "limit") and val(arguments.limit) and NOT arguments.count>
			limit #start#,#limit#
		</cfif>
		</cfquery>

		<cfreturn qUsers />
	</cffunction>

	<cffunction name="getByAttributes" access="public" output="false" returntype="array">
		<cfargument name="id" type="Numeric" required="false" />
		<cfargument name="username" type="String" required="false" />
		<cfargument name="password" type="String" required="false" />
		<cfargument name="lastLogin" type="String" required="false" />
		<cfargument name="createDate" type="String" required="false" />
		<cfargument name="modifiedDate" type="String" required="false" />
		<cfargument name="personId" type="Numeric" required="false" />
		<cfargument name="active" type="boolean" required="false" />
		<cfargument name="roleId" type="numeric" required="false" />
		<cfargument name="orderby" type="string" required="false" />
		
		<cfset var qList = getByAttributesQuery(argumentCollection=arguments) />		
		<cfset var arrObjects = arrayNew(1) />
		<cfset var tmpObj = "" />
		<cfset var i = 0 />
		<cfloop from="1" to="#qList.recordCount#" index="i">
			<cfset tmpObj = createObject("component","user").init(argumentCollection=queryRowToStruct(qList,i)) />
			<cfset arrayAppend(arrObjects,tmpObj) />
		</cfloop>
				
		<cfreturn arrObjects />
	</cffunction>

</cfcomponent>
