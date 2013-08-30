<cfcomponent name="userService" output="false">

	<cffunction name="init" access="public" output="false" returntype="userService">
		<cfargument name="dsn" type="string" required="true" />
		
		<cfset variables.userDAO = createObject('component','userDAO').init(dsn:arguments.dsn) />
		<cfset variables.userGateway = createObject('component','userGateway').init(dsn:arguments.dsn) />
		<cfset variables.personService = createObject('component','model.person.personService').init(dsn:arguments.dsn) />
		<cfset variables.addressService = createObject('component','model.address.addressService').init(dsn:arguments.dsn) />
		<cfset variables.phoneService = createObject('component','model.phone.phoneService').init(dsn:arguments.dsn) />
		<cfset variables.permissionService = createObject('component','model.permission.permissionService').init(dsn:arguments.dsn) />
		<cfreturn this />
	</cffunction>

	<cffunction name="createUser" access="public" output="false" returntype="user">
		<cfargument name="id" type="Numeric" required="false" default="0" />
		<cfargument name="username" type="String" required="false" />
		<cfargument name="password" type="String" required="false" />
		<cfargument name="lastLogin" type="String" required="false" />
		<cfargument name="createDate" type="String" required="false" />
		<cfargument name="modifiedDate" type="String" required="false" />
		<cfargument name="person" type="model.user.user" required="false" />
		<cfargument name="active" type="boolean" required="false" />
		<cfargument name="roleId" type="Numeric" required="false" />
			
		<cfset var user = createObject("component","user").init(argumentCollection=arguments) />
		<cfreturn user />
	</cffunction>

	<cffunction name="getUser" access="public" output="false" returntype="user">
		<cfargument name="id" type="Numeric" required="false" default="0" />
		<cfset var user = createUser(argumentCollection=arguments) />
		<cfset variables.userDAO.read(user) />
		<cfif user.getId()>
			<cfif user.getPerson().getId()>
				<cfset user.setPerson(variables.personService.getPerson(id:user.getPerson().getId())) />
			</cfif>
			<cfset user.setPermissions(variables.permissionService.getUserPermissions(userId:user.getId())) />
		</cfif>
		
		<cfreturn user />
	</cffunction>

	<cffunction name="getUsers" access="public" output="false" returntype="array">
		<cfargument name="id" type="Numeric" required="false" />
		<cfargument name="username" type="String" required="false" />
		<cfargument name="password" type="String" required="false" />
		<cfargument name="lastLogin" type="String" required="false" />
		<cfargument name="createDate" type="String" required="false" />
		<cfargument name="modifiedDate" type="String" required="false" />
		<cfargument name="person" type="model.user.user" required="false" />
		<cfargument name="active" type="boolean" required="false" />
		<cfargument name="roleId" type="numeric" required="false" />
		<cfset var users = variables.userGateway.getByAttributes(argumentCollection=arguments) />
		<cfloop from="1" to="#arrayLen(users)#" index="i">
			<cfset users[i] = getUser(users[i].getId()) />
		</cfloop>
		<cfreturn users />
	</cffunction>
	
	<cffunction name="getUsersQuery" access="public" output="false" returntype="query">
		<cfargument name="id" type="Numeric" required="false" />
		<cfargument name="username" type="String" required="false" />
		<cfargument name="password" type="String" required="false" />
		<cfargument name="lastLogin" type="String" required="false" />
		<cfargument name="createDate" type="String" required="false" />
		<cfargument name="modifiedDate" type="String" required="false" />
		<cfargument name="person" type="model.user.user" required="false" />
		<cfargument name="active" type="boolean" required="false" />
		<cfargument name="roleId" type="Numeric" required="false" />
		
		<cfreturn variables.userGateway.getByAttributesQuery(argumentCollection=arguments) />
	</cffunction>
	
	<cffunction name="saveUser" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="user" required="true" />
		<cfset var success = false />
		<cfset var userFacade =  createObject('component','model.user.userFacade') />
		<cfset var permissions = arguments.user.getPermissions() />
		<cfif NOT arrayLen(arguments.user.validate()) >	 
      	<cftransaction action="begin" isolation="serializable">
			<cfset success = variables.personService.savePerson(arguments.user.getPerson()) />
			<cfset success = variables.userDAO.save(user) />
			<!--- cfloop from="1" to="#arraylen(permissions)#" index="i">
				<cfset success = variables.userDAO.saveUserPermission(permissionId:permissions[i]['permissionId'], userId:arguments.user.getId(), allowed: permissions[i]['allowed']) />
			</cfloop --->
 			<cfif NOT success>
				<cftransaction action="rollback" />
			</cfif>
			<cfif success AND structKeyExists(session,'user') AND userFacade.getUser().getId() EQ arguments.user.getId()>
				<cfset userFacade.setUser(arguments.user) />
			</cfif>
		</cftransaction>
		</cfif>
		<cfreturn success />
	</cffunction>

	<cffunction name="deleteUser" access="public" output="false" returntype="boolean">
		<cfargument name="id" type="Numeric" required="true" />
		
		<cfset var user = createuser(argumentCollection=arguments) />
		<cfif user.getPerson().getId()>
			<cfset variables.personService.deletePerson(id:user.getPerson().getId()) />
		</cfif>
		<cfreturn variables.userDAO.delete(user) />
	</cffunction>
  
	<cffunction name="saveAddress" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="model.user.user" required="yes" />
		<cfargument name="address" type="model.address.address" required="yes" />
			<cfreturn variables.personService.saveAddress(person:arguments.user.getPerson(),address:arguments.address) />
	</cffunction>  
	
	<cffunction name="savePhone" access="public" output="false" returntype="boolean">
		<cfargument name="user" type="model.user.user" required="yes" />
		<cfargument name="phone" type="model.phone.phone" required="yes" />
			<cfreturn variables.personService.savePhone(person:arguments.user.getPerson(),phone:arguments.phone) />
	</cffunction> 
	
	<cffunction name="getAddressesByUserId" access="public" output="false" returntype="query">
			<cfargument name="id" type="Numeric" required="true" />
			<cfreturn variables.addressService.getUserAddresses(id:arguments.id) />
	</cffunction>
	
	<cffunction name="getPhonesByUserId" access="public" output="false" returntype="query">
			<cfargument name="id" type="Numeric" required="true" />
			<cfreturn variables.phoneService.getUserPhones(id:arguments.id) />
	</cffunction>
    
    
    
</cfcomponent>
