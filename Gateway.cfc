<cfcomponent extends="object" output="false">
	
	<cfset variables.dsn = "" />
	
	<!---
		Function: init
			This function overrides the parent init function and allows for assigning private member attributes to this class
			The main usage is for appending the dsn in the state of the gateway object, thereby eliminating the need to pass the dsn with every function call.
		Params: 
			optional - optional params must be name value pairs. 
		Returns: Gateway
	--->
	<cffunction name="init" access="public" returntype="gateway" output="false">
		<cfargument name="dsn" type="string" required="false" default="" />
		
		<cfset structAppend(variables,arguments,true) />
		<cfreturn super.init() />
	</cffunction>

	<!--- 
	 * Makes a row of a query into a structure.
	 * 
	 * @param query 	 The query to work with. 
	 * @param row 	 Row number to check. Defaults to row 1. 
	 * @return Returns a structure. 
	 * @author Nathan Dintenfass (nathan@changemedia.com) 
	 * @version 1, December 11, 2001 
	 --->
	<cffunction name="queryRowToStruct" access="public" output="false" returntype="struct">
		<cfargument name="qry" type="query" required="true">
		<cfargument name="row" type="string" required="false" default="1" />
		<cfargument name="keys" type="any" required="false" />
		<cfargument name="excludeKeys" type="any" required="false" />
		<cfscript>
			var ii = 1;
			var i = 1;
			var j = 1;
			var cols = listToArray(qry.columnList);
			var stReturn = structnew();
			var hasKey = false;
			
			// if a list or array of keys are provided and each exists in the query then use those instead of the query columns
			if( structKeyExists(arguments, 'keys') ){
				if( ! isArray(arguments.keys) ){ arguments.keys = listtoArray( arguments.keys ); }
				for( i = 1; i lte arrayLen(arguments.keys); i = i + 1 ){
					hasKey = false;
					for( j = 1; j lte arrayLen(cols); j = j + 1){
						if( cols[j] EQ arguments.keys[i] ){ 
							hasKey = true; 
							break;
						}
					}
					if(hasKey EQ true){
						continue;
					}
					break;
				}
				if( hasKey ){
					cols = arguments.keys;
				}
			}

			//loop over the cols and build the struct from the query row
			for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
				stReturn[cols[ii]] = qry[cols[ii]][arguments.row];
			}

			// if a list or array of excludeKeys are provided then remove them from the cols used for the return struct.
			if( structKeyExists(arguments, 'excludeKeys') ){
				if( ! isArray(arguments.excludeKeys) ){ arguments.excludeKeys = listtoArray( arguments.excludeKeys ); }
				for( i = 1; i lte arrayLen(arguments.excludeKeys); i = i + 1 ){
					structDelete( stReturn, arguments.excludeKeys[ i ] );
				}
			}

			return stReturn;
		</cfscript>
	</cffunction>
	
</cfcomponent>