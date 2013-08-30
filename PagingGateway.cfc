<cfcomponent extends="object" output="no">

	<cffunction name="getPagedData" access="public" returntype="array" output="false">
		<cfargument name="query" type="query" required="yes" />
		<cfargument name="start" type="numeric" required="no" default="0" />
		<cfargument name="limit" type="numeric" required="no" />
		<cfscript>
			var qResult = arrayNew(1);
			var maxRow = "";
			var i = "";
			var j = "";
			var counter = 0;
			arguments.start = arguments.start + 1;
			if(not StructKeyExists(arguments,'limit')){
				arguments.limit = arguments.query.recordcount;
			}
			if((arguments.limit + arguments.start) GTE  arguments.query.recordcount){
				maxRow = arguments.query.recordcount;
			}
			else {
				maxRow = arguments.limit + arguments.start;
			}

			for(i = arguments.start; i LTE maxRow; i=i+1){
				counter = counter + 1;
				//queryAddRow(qResult);
				qResult[counter] = StructNew();
				for(j=1; j LTE listlen(arguments.query.columnList); j=j+1){
					qResult[counter]['#listGetAt(arguments.query.columnlist,j)#'] = arguments.query[listGetAt(arguments.query.columnlist,j)][i];
				}			
			}
		</cfscript>
		<cfreturn qResult>
	</cffunction>
	
</cfcomponent>