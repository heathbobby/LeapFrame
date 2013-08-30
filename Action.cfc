<cfcomponent name="action" extends="object" output="no">
	<cfset variables.results = "" />
	<cfset variables.args = "" />
	<!---
		Function: init (constructor)
			initializes the action object
		Parameters:
			args - structure optional the member structure for action object state
		Returns - action object (this)
	--->
    
	<cffunction name="init" access="public" returntype="action" output="false">
		<cfargument name="args" required="no" default="#structNew()#" />
		
			<cfset setArgs(arguments.args) />
			<cfreturn this />
	</cffunction>

<!--- accessors --->
	<!---
		Function: setArgs
			Replaces all args in action object
		Parameters: 
			args - struct required  The struct to replace all args in action object
		Returns: void
	 --->	
	<cffunction name="setArgs" access="public" returntype="void" output="false">
		<cfargument name="args" required="yes" type="struct" />
			<cfset variables.args = arguments.args />
	</cffunction>
	<!---
		Function: getArgs
			Gets args structure in action object
		Returns: struct 
	 --->	
	<cffunction name="getArgs" access="public" returntype="any" output="false">
		<cfargument name="defaults" type="struct" required="no" default="#structNew()#" />
		<cfargument name="overwrite" type="boolean" required="no" default="false" />
			<cfif Not StructIsEmpty(arguments.defaults)>
				<cfreturn structAppend(variables.args,arguments.defaults,arguments.overwrite) />
			</cfif>
			<cfreturn variables.args />
	</cffunction>	
	
	<!---
		Function: setArg
			Sets arg in action object. Overwrites the value if arg already exists.
		Parameters: 
			key - string name of the value to which the value will be set
			value - any required The value to set the arg to
		Returns: void
	 --->	
	<cffunction name="setArg" access="public" returntype="void" output="false">
		<cfargument name="key" 		required="yes" type="string"/>
		<cfargument name="value" 	required="yes" type="any" />
			<cfset variables.args[arguments.key] = arguments.value />
	</cffunction>
    
    <!---
		Function: getArg
			Retrieves specified arg in action object. If key is not present in args struct and a default val is specified, the specified default value will be returned. If not specified the value returned will be "" (empty string) 
		Parameters: 
			key - string name of the value to which the value will be set
			defaultVal - any required The value to be returned if the the requested key does not exist in the args struct
		Returns: any
	 --->	
	
	<cffunction name="getArg" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="yes" />
		<cfargument name="defaultVal" required="no" type="any" default="" />
		<cfif structKeyExists(variables.args,"#arguments.key#")>
			<cfreturn variables.args[arguments.key]  />
		<cfelse>
			<cfreturn arguments.defaultVal />
		</cfif>
	</cffunction>
	 
    <!---
		Function: argExists
		Checks for existance of argument in action object
		Parameters: 
			arg - string name of the key to check if exists
		Returns: boolean
	 --->	
	 
	<cffunction name="argExists" access="public" returntype="boolean" output="false">
		<cfargument name="arg" type="any" required="yes" />
		
		<cfreturn structKeyExists(variables.args, arguments.arg) />
	</cffunction>
	
	 <!---
		Function: appendArgs
		Append a structure to the arguments contained in the 
		Parameters: 
			args - struct to append to the variables args struct
		Returns: boolean
	 --->	
	 
	<cffunction name="appendArgs" access="public" returntype="struct" output="false">
		<cfargument name="args" type="struct" required="yes" />
		<cfargument name="overwrite" type="boolean" required="no" default="true" />
		<cfset structAppend(variables.args,arguments.args,arguments.overwrite) />
		<cfreturn variables.args />
	</cffunction>
	
	 <!---
		Function: removeArg
		Remove passed arg from args struct
		Parameters: 
			arg - string name of the key to remove from the args structure
		Returns: boolean
	 --->	
	 
	<cffunction name="removeArg" access="public" returntype="boolean" output="false">
		<cfargument name="arg" required="yes" type="string" />
		<cfif argExists(arguments.arg)>
			<cfset structDelete(variables.args,arguments.arg,true) />
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction> 
	
	 <!---
		Function: removeArgs
		Removes all keys from args structure
		Parameters: 
			NONE
		Returns: boolean
	 --->	
	 
	<cffunction name="removeArgs" access="public" returntype="void" output="false">
		<cfset structClear(variables.args) />
	</cffunction> 
	
</cfcomponent>