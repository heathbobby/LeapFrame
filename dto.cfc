<cfcomponent extends="object" output="no">
	<cfset variables.udf = createObject('component','udf') />
	<cffunction name="init" access="public" returntype="dto" output="false">
		<cfargument name="component" type="any" required="yes" />
		<cfscript>
		
			if(variables.udf.isBean(arguments.component)){
				setMembers(component);
			}
		</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setMembers" access="private" returntype="void" output="no">
		<cfargument name="component" type="any" required="yes" />
		<cfscript>
			var beanData = "";
			var it = "";
			beanData = arguments.component.getBeanState();
			for(it in beanData){
				if(it EQ 'this'){continue;}
				if(variables.udf.isBean(beanData[it])){
					this[it] = createObject('component','dto').init(beanData[it]);
				}
				else{ this[it] = beanData[it]; }
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>
