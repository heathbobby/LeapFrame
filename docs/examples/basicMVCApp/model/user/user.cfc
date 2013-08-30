<cfcomponent displayname="user" output="false" extends="leapframe.bean" >
		<cfset variables.id = "" />
		<cfset variables.username = "" />
		<cfset variables.password = "" />
		<cfset variables.lastLogin = "" />
		<cfset variables.createDate = "" />
		<cfset variables.modifiedDate = "" />
		<cfset variables.person = "" />
		<cfset variables.active = "" />
		<cfset variables.permissions = "" />
		<cfset variables.roleId = "" />
		<cfset variables.organizationId = "" />

	<!---
	INITIALIZATION / CONFIGURATION
	--->
	<cffunction name="init" access="public" returntype="user" output="false">
		<cfargument name="id" type="Numeric" required="false" default="0" />
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
		<cfargument name="lastLogin" type="String" required="false" default="" />
		<cfargument name="createDate" type="String" required="false" default="" />
		<cfargument name="modifiedDate" type="String" required="false" default="" />
		<cfargument name="person" type="model.person.person" required="false" default="#createObject('component','model.person.person').init()#" />
		<cfargument name="active" type="boolean" required="false" default="true" />
		<cfargument name="permissions" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="tariffPermissions" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="roleid" type="numeric" required="false" default="0" />
		<cfargument name="organizationId" type="numeric" required="false" default="0" />
		
		<!--- run setters --->
		<cfset setId(arguments.id) />
		<cfset setUsername(arguments.username) />
		<cfset setPassword(arguments.password) />
		<cfset setLastLogin(arguments.lastLogin) />
		<cfset setCreateDate(arguments.createDate) />
		<cfset setModifiedDate(arguments.modifiedDate) />
		<cfset setPerson(arguments.person) />
		<cfset setActive(arguments.active) />
		<cfset setPermissions(arguments.permissions) />
		<cfset setTariffPermissions(arguments.permissions) />
		<cfset setRoleId(arguments.roleId) />
		<cfset setOrganizationId(arguments.OrganizationId) />
		
		<cfreturn super.init(argumentCollection: arguments) />
 	</cffunction>

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="validate" access="public" returntype="array" output="false">
		<cfset var validator = createObject('component','model.util.validatorFacade').getValidator() />
		
		<!--- id --->
		
		<!--- username --->
		<cfif (NOT len(trim(getusername())))>
			<cfset validator.errorAppend('username',"User Name is required.") />
		</cfif>
		
		<!--- password --->
		<cfif (NOT len(trim(getpassword())))>
			<cfset validator.errorAppend('password',"Password is required.") />
		</cfif>
		
		<!--- lastLogin --->
		
		<!--- createDate --->
		
		<!--- modifiedDate --->
		
		<!--- personId --->
		<!--- cfif (NOT len(trim(getPerson().getId())))>
			<cfset thisError.field = "personId" />
			<cfset thisError.type = "required" />
			<cfset thisError.message = "personId is required" />
			<cfset arrayAppend(errors,duplicate(thisError)) />
		</cfif --->
		
		<cfreturn Validator.getErrArray() />
	</cffunction>

	<!---
	ACCESSORS
	--->
	<cffunction name="setid" access="public" returntype="void" output="false">
		<cfargument name="id" type="Numeric" required="true" />
		<cfset variables.id = arguments.id />
	</cffunction>
	<cffunction name="getid" access="public" returntype="Numeric" output="false">
		<cfreturn variables.id />
	</cffunction>

	<cffunction name="setusername" access="public" returntype="void" output="false">
		<cfargument name="username" type="String" required="true" />
		<cfset variables.username = arguments.username />
	</cffunction>
	<cffunction name="getusername" access="public" returntype="String" output="false">
		<cfreturn variables.username />
	</cffunction>

	<cffunction name="setpassword" access="public" returntype="void" output="false">
		<cfargument name="password" type="String" required="true" />
		<cfset variables.password = arguments.password />
	</cffunction>
	<cffunction name="getpassword" access="public" returntype="String" output="false">
		<cfreturn variables.password />
	</cffunction>

	<cffunction name="setlastLogin" access="public" returntype="void" output="false">
		<cfargument name="lastLogin" type="String" required="true" />
		<cfif isDate(arguments.lastLogin)>
			<cfset variables.lastLogin = createOdbcDateTime(arguments.lastLogin) />
		</cfif>
	</cffunction>
	<cffunction name="getlastLogin" access="public" returntype="String" output="false">
		<cfreturn variables.lastLogin />
	</cffunction>

	<cffunction name="setcreateDate" access="public" returntype="void" output="false">
		<cfargument name="createDate" type="String" required="true" />
		<cfset variables.createDate = arguments.createDate />
	</cffunction>
	<cffunction name="getcreateDate" access="public" returntype="String" output="false">
		<cfreturn variables.createDate />
	</cffunction>

	<cffunction name="setmodifiedDate" access="public" returntype="void" output="false">
		<cfargument name="modifiedDate" type="String" required="true" />
		<cfset variables.modifiedDate = arguments.modifiedDate />
	</cffunction>
	<cffunction name="getmodifiedDate" access="public" returntype="String" output="false">
		<cfreturn variables.modifiedDate />
	</cffunction>

	<cffunction name="setPerson" access="public" returntype="void" output="false">
		<cfargument name="person" type="model.person.person" required="true" />
		<cfset variables.person = arguments.person />
	</cffunction>
	<cffunction name="getPerson" access="public" returntype="model.person.person" output="false">
		<cfreturn variables.person />
	</cffunction>

	<cffunction name="setActive" access="public" returntype="void" output="false">
		<cfargument name="Active" type="boolean" required="true" />
		<cfset variables.Active = arguments.Active />
	</cffunction>
	<cffunction name="getActive" access="public" returntype="boolean" output="false">
		<cfreturn variables.Active />
	</cffunction>
	
	<cffunction name="setPermissions" access="public" returntype="void" output="false">
		<cfargument name="permissions" type="array" required="true" />
		<cfset variables.permissions = arguments.permissions />
	</cffunction>
	<cffunction name="getPermissions" access="public" returntype="array" output="false">
		<cfreturn variables.permissions />
	</cffunction>
	
	<cffunction name="setTariffPermissions" access="public" returntype="void" output="false">
		<cfargument name="tariffPermissions" type="array" required="true" />
		<cfset variables.tariffPermissions = arguments.tariffPermissions />
	</cffunction>
	<cffunction name="getTariffPermissions" access="public" returntype="array" output="false">
		<cfreturn variables.tariffPermissions />
	</cffunction>
	
	<cffunction name="setRoleId" access="public" returntype="void" output="false">
		<cfargument name="roleId" type="numeric" required="true" />
		<cfset variables.roleId = arguments.roleId />
	</cffunction>
	<cffunction name="getRoleId" access="public" returntype="numeric" output="false">
		<cfreturn variables.RoleId />
	</cffunction>
	
	<cffunction name="setOrganizationId" access="public" returntype="void" output="false">
		<cfargument name="organizationId" type="numeric" required="true" />
		<cfset variables.organizationId = arguments.organizationId />
	</cffunction>
	<cffunction name="getOrganizationId" access="public" returntype="numeric" output="false">
		<cfreturn variables.organizationId />
	</cffunction>
	
	<cffunction name="hasPermission" access="public" returntype="boolean" output="true">
		<cfargument name="permission" type="string" required="yes" />
		<cfset var i = 1 />
		<cfloop from="1" to="#arrayLen(variables.permissions)#" index="i">
			<cfif variables.permissions[i].permission EQ arguments.permission AND variables.permissions[i].allowed EQ 1>
				<cfreturn true />
			</cfif>
		</cfloop>
		<cfreturn false />
	</cffunction>
	
	<cffunction name="canRead" access="public" returntype="boolean" output="true">
		<cfargument name="id" type="numeric" required="yes" />
		<cfloop from="1" to="#arrayLen(variables.tariffPermissions)#" index="i">
			<cfif bitand(4,variables.tariffPermissions[i].bitmask)>
				<cfset result = true />
			</cfif>
		</cfloop>
		<cfreturn result />
	</cffunction>
	
	<cffunction name="canEdit" access="public" returntype="boolean" output="true">
		<cfargument name="id" type="numeric" required="yes" />
		<cfloop from="1" to="#arrayLen(variables.tariffPermissions)#" index="i">
			<cfif bitand(2,variables.tariffPermissions[i].bitmask)>
				<cfset result = true />
			</cfif>
		</cfloop>
		<cfreturn result />
	</cffunction>
	
	<cffunction name="canDelete" access="public" returntype="boolean" output="true">
		<cfargument name="id" type="numeric" required="yes" />
		<cfloop from="1" to="#arrayLen(variables.tariffPermissions)#" index="i">
			<cfif bitand(1,variables.tariffPermissions[i].bitmask)>
				<cfset result = true />
			</cfif>
		</cfloop>
		<cfreturn result />
	</cffunction>

 	<cffunction name="toTree" access="public" returntype="struct" output="false">
		<cfset var tree = structNew() />
		<cfset tree['userid'] = getId() />
		<cfset tree["text"] = getPerson().getLastName() & ", " & getPerson().getFirstName() />
		<cfset tree["cls"] = 'file' />	
		<cfset tree["leaf"] = 'true' />
		<cfset structAppend(tree,getBeanState()) />
		<cfreturn tree />
	</cffunction>
	
</cfcomponent>
