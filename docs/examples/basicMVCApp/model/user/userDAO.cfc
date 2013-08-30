<cfcomponent displayname="userDAO" extends="leapframe.dao" hint="table ID column = id">

	<cffunction name="init" access="public" output="false" returntype="userDAO">
		<cfargument name="dsn" type="string" required="true" />
		<cfset variables.dsn = arguments.dsn />
		<cfreturn super.init(argumentCollection: arguments) />
	</cffunction>
	
	<cffunction name="create" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="user" required="true" />

		<cfset var qCreate = "" />
		<cfset var qMax = "" />
		<cftry>
			<cfquery name="qCreate" datasource="#variables.dsn#">
				INSERT INTO user
					(
					username,
					password,
					lastLogin,
					createDate,
					modifiedDate,
					personId,
					active,
					roleId,
					organizationId
					)
				VALUES
					(
					<cfqueryparam value="#arguments.user.getusername()#" CFSQLType="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.user.getPassword()#" CFSQLType="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.user.getlastLogin()#" CFSQLType="cf_sql_date" />,
					<cfqueryparam value="#createOdbcDate(now())#" CFSQLType="cf_sql_date" />,
					<cfqueryparam value="#arguments.user.getmodifiedDate()#" CFSQLType="cf_sql_date" null="#not len(arguments.user.getmodifiedDate())#" />,
					<cfqueryparam value="#arguments.user.getPerson().getId()#" CFSQLType="cf_sql_integer" />,
					<cfqueryparam value="#iif(arguments.user.getactive(),de('1'),de('0'))#" CFSQLType="cf_sql_tinyint" />,
					<cfqueryparam value="#arguments.user.getRoleId()#" CFSQLType="cf_sql_integer" />,
          <cfqueryparam value="#arguments.user.getOrganizationId()#" CFSQLType="cf_sql_integer" null="#not val(arguments.user.getOrganizationId())#" />
					)
			</cfquery>
			<cfquery name="qMax" datasource="#variables.dsn#">
				SELECT max(id) as id FROM user
			</cfquery>
			<cfif qMax.id >
				<cfset arguments.user.setid(qMax.id) />
			</cfif>
			<cfcatch type="database">
				<cfdump var="#cfcatch#" /><cfabort />
				<cfreturn false />
			</cfcatch>
		</cftry>
		<cfreturn true />
	</cffunction>

	<cffunction name="read" access="public" output="false" returntype="void">
		<cfargument name="user" type="user" required="true" />

		<cfset var qRead = "" />
		<cfset var strReturn = structNew() />
		<cftry>
			<cfquery name="qRead" datasource="#variables.dsn#">
				SELECT
					id,
					username,
					password,
					lastLogin,
					createDate,
					modifiedDate,
					coalesce(personId,0) as personId,
					active,
					roleId,
					coalesce(organizationId,0) as organizationId
				FROM	user
				WHERE	id = <cfqueryparam value="#arguments.user.getid()#" CFSQLType="cf_sql_integer" />
			</cfquery>
			<cfcatch type="database">
				<!--- leave the bean as is and set an empty query for the conditional logic below --->
				<cfset qRead = queryNew("id") />
			</cfcatch>
		</cftry>
		<cfif qRead.recordCount>
			<cfset strReturn = queryRowToStruct(qRead)>
			<cfset arguments.user.init(argumentCollection=strReturn)>
			<cfset arguments.user.getPerson().setId(qRead.personId) />
		</cfif>
	</cffunction>

	<cffunction name="update" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="user" required="true" />

		<cfset var qUpdate = "" />
		<cftry>
			<cfquery name="qUpdate" datasource="#variables.dsn#">
				UPDATE	user
				SET
					username = <cfqueryparam value="#arguments.user.getusername()#" CFSQLType="cf_sql_varchar" />,
					<cfif len(arguments.user.getPassword())>
							password = <cfqueryparam value="#arguments.user.getpassword()#" CFSQLType="cf_sql_varchar" />,
					</cfif>
					lastLogin = <cfqueryparam value="#arguments.user.getlastLogin()#" CFSQLType="cf_sql_date" null="#not len(arguments.user.getLastLogin())#" />,
					modifiedDate = <cfqueryparam value="#createOdbcDateTime(now())#" CFSQLType="cf_sql_date"  />,
					personId = <cfqueryparam value="#arguments.user.getPerson().getId()#" CFSQLType="cf_sql_integer" />,
					active = <cfqueryparam value="#iif(arguments.user.getactive(),de('1'),de('0'))#" cfsqltype="cf_sql_bit" />,
					roleId = <cfqueryparam value="#arguments.user.getRoleId()#" CFSQLType="cf_sql_integer" />,
					organizationId = <cfqueryparam value="#arguments.user.getOrganizationId()#" CFSQLType="cf_sql_integer" null="#not val(arguments.user.getOrganizationId())#" />
				WHERE id = <cfqueryparam value="#arguments.user.getid()#" CFSQLType="cf_sql_integer" />
			</cfquery>
			<cfcatch type="database">
				<cfreturn false />
			</cfcatch>
		</cftry>
		<cfreturn true />
	</cffunction>

	<cffunction name="delete" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="user" required="true" />

		<cfset var qDelete = "">
		<cftry>
			<cfquery name="qDelete" datasource="#variables.dsn#">
				DELETE FROM	user 
				WHERE	id = <cfqueryparam value="#arguments.user.getid()#" CFSQLType="cf_sql_integer" />
			</cfquery>
			<cfcatch type="database">
				<cfreturn false />
			</cfcatch>
		</cftry>
		<cfreturn true />
	</cffunction>

	<cffunction name="exists" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="user" required="true" />

		<cfset var qExists = "">
		<cfquery name="qExists" datasource="#variables.dsn#" maxrows="1">
			SELECT count(1) as idexists
			FROM	user
			WHERE	id = <cfqueryparam value="#arguments.user.getid()#" CFSQLType="cf_sql_integer" />
		</cfquery>

		<cfif qExists.idexists>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>

	<cffunction name="save" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="user" required="true" />
		<cfset var success = false />
		<cfif exists(arguments.user)>
			<cfset success = update(arguments.user) />
		<cfelse>
			<cfset success = create(arguments.user) />
		</cfif>
		<cfreturn success />
	</cffunction>
	
	<cffunction name="saveUserPermission" access="public" returntype="boolean" output="false">
		<cfargument name="userId" type="numeric" required="true" />
		<cfargument name="permissionId" type="numeric" required="true" />
		<cfargument name="allowed" type="Numeric" required="false" default="0" />
		
		<cfset var qPermission_user = "" />
		<cftry>
			<cfquery name="qPermission_user" datasource="#variables.dsn#">
				CALL saveuserPermission(
					<cfqueryparam value="#arguments.userId#" CFSQLType="cf_sql_integer" />,
					<cfqueryparam value="#arguments.permissionId#" CFSQLType="cf_sql_integer" />,
					<cfqueryparam value="#arguments.allowed#" CFSQLType="cf_sql_varchar" />
				)
			</cfquery>
			<cfcatch type="any">
				<cfdump var="#cfcatch#" /><cfabort />
				<cfreturn false />
			</cfcatch>
		</cftry>
		<cfreturn true />
	</cffunction>

	
</cfcomponent>
