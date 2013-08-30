<cfcomponent displayname="validator" hint="Object used to validate forms." output="false">
	<cfscript>
		variables.errArray = '';
		variables.errStruct = '';
	</cfscript>
	
	<cffunction name="init" access="public" returntype="validator" output="false" >
		<cfargument name="errArray" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="errStruct" type="struct" required="false" default="#structNew()#" />
		<cfset setErrArray(arguments.errArray) />
		<cfset setErrStruct(arguments.errStruct) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="errorAppend" access="public" returntype="void" output="false">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="value" required="true" type="string" />
		<cfset var tempStruct = structNew() />
		<cfscript>
			
			tempStruct[arguments.key] = arguments.value;
			if(structKeyExists(variables.errStruct,arguments.key)){
				variables.errStruct[arguments.key] = variables.errStruct[arguments.key] & '<br />' & arguments.value;
			}
			else{
				variables.errStruct[arguments.key] = arguments.value;
				arrayAppend(getErrArray(),tempStruct);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="appendErrors" access="public" returntype="void" output="false">
		<cfargument name="arErrors"  type="array" required="yes" />
		<cfset var tempStruct = Structnew() />
		<cfset var it = "" />
		<cfloop from="1" to="#arrayLen(arguments.arErrors)#" index="i">
			<cfscript>
			for(it in arErrors[i]){
				errorAppend(it,arErrors[i][it]);
			}
			</cfscript>
		</cfloop>
	</cffunction>
	
	<cffunction name="errorClear" access="public" returntype="void" output="false">
		<cfset init() />
	</cffunction>
	
	<cffunction name="getErrArray" access="public" returntype="array" output="false">
		<cfreturn variables.errArray />
	</cffunction>
	<cffunction name="setErrArray" access="private" returntype="void" output="false">
		<cfargument name="errArray" type="array" required="false" default="#arrayNew(1)#" />
		<cfset variables.errArray = arguments.errArray />
	</cffunction>
	
	<cffunction name="getErrStruct" access="public" returntype="struct" output="false">
		<cfreturn variables.errStruct />
	</cffunction>
	<cffunction name="setErrStruct" access="private" returntype="void" output="false">
		<cfargument name="errStruct" type="struct" required="false" default="#structNew()#" />
		<cfset variables.errStruct = arguments.errStruct />
	</cffunction>
	
	<cffunction name="getErrors" access="public" returntype="struct" output="false" >
		<cfset var tempstruct = structNew() />
		<cfset tempstruct['errArr'] = getErrArray() />
		<cfset tempstruct['errStruct'] = getErrStruct() />
		<cfreturn tempStruct />
	</cffunction>
	
	<cffunction name="hasErrors" access="public" returntype="boolean" output="false">
		<cfif arrayLen(getErrArray())>
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>

	
</cfcomponent>