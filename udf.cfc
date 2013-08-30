<cfcomponent  extends="object" displayname="udf" hint="I define all generic user defined functions to extend cfscript" output="no" >

	<cffunction name="init" access="public" returntype="any" output="no">
		<cfreturn this />
	</cffunction>

	<cffunction name="isBean" access="public"  returntype="boolean" output="no">
		<cfargument name="object" type="any" required="yes" />
			<cfscript>
			var newBean =  "";
				if(getType(arguments.object) EQ 'component' ){
					if(arguments.object.getReflectionData().name EQ 'leapframe.bean'){
						return true;
					}
					else if(arguments.object.getReflectionData().name EQ 'WEB-INF.cftags.component'){ 
						return false;
					}
					newBean =  createObject('component',arguments.object.getReflectionData().extends.name);
					return isBean(newBean);
				} 
				else { return false; }
			</cfscript>
	</cffunction>

	<cffunction name="outWithFlush" access="private" returntype="void" output="true">
		<cfargument name="output" type="any" required="yes">
		
		<cfdump var="#output#">
		<cfflush>
	</cffunction>

	<cffunction name="toXml" access="public" returntype="string"  output="false">
		<cfargument name="struct" type="struct" required="yes" /> 
		<cfset var xml = "" />
		<cfwddx action="cfml2wddx" input="#toStruct(arguments.struct)#" output="xml" />
		<cfreturn xml />
	</cffunction>

	<cffunction name="toStruct" access="public" returntype="struct"  output="false">
		<cfargument name="struct" type="any" required="no" />
		<cfargument name="args" type="struct" required="no" />
		<cfset var data = structNew() />
		<cfset var it = "" />
		<cfset var item="" />
		<cfscript>
			for(it in arguments.struct)
			{
				switch(getType(arguments.struct[it])){
					case 'numeric': 
						data[it] = arguments.struct[it];
					break;
					case 'binary': 
						data[it] = arguments.struct[it].toString();
					break;
					case 'query': 
						data[lcase(it)] = queryToArray(arguments.struct[it]);
					break;
					case 'struct':
						for(item in arguments.struct[it]) {	
							if(getType(arguments.struct[it][item]) EQ 'function'){continue;}
							data[it][item] = toStruct(arguments.struct[it][item]); 
						}
					break;
					case 'boolean': 
						data[it] = arguments.struct[it];
					break;
					case 'array': 
						data[it] = arguments.struct[it];
					break;
					case 'component':
						if(isBean(arguments.struct[it])) {arguments.struct[it] = arguments.struct[it].getBeanState();} 
						for(item in arguments.struct[it]) {	
							if(getType(arguments.struct[it][item]) EQ 'function'){continue;}
							else if(getType(arguments.struct[it][item]) EQ 'struct'){
								data[it][item] = toStruct(arguments.struct[it][item]); 
							}
							else if(getType(arguments.struct[it][item]) EQ 'component'){
								if(isBean(arguments.struct[it])) {arguments.struct[it] = arguments.struct[it].getBeanState();}
								data[it][item] = toStruct(arguments.struct[it][item]); 
							}
							else{	data[it][item] = arguments.struct[it][item]; }
						}
					break;
					case 'function':
						data[it] = toStruct(arguments.struct[it].getMetaData());
					break;
					default:
						data[it] = arguments.struct[it];
					break;
				}
			}
		</cfscript>
		<cfreturn data />
	</cffunction>



	<cffunction name="toJson" access="public" returntype="string"  output="false">
		<cfargument name="object" type="any" required="no" />
		<cfargument name="args" type="struct" required="no" />
		<cfset var json = "" />
		<cfset var key = "" />
		<cfset var keylist = "" />
		<cfset var value = "" />
		<cfset var startrow = 1 />
		<cfset var i = 1 />
		<cftry>
		<cfswitch expression="#getType(arguments.object)#">
			
			<cfcase value="numeric">
				<cfset json = json & arguments.object />
			</cfcase>
			
			<cfcase value="binary">
				<cfset json = json & "#chr(34)##arguments.object.toString()##chr(34)#" />
			</cfcase>
			
			<cfcase value="query">
				<cfscript>
					json= json & "[" ;
					if(structKeyExists(arguments,'startrow')){startrow = arguments.startrow;}
					for (i = startrow; i LTE arguments.object.recordcount; i=i+1)
					{
						json= json & "{";
						for(j=1; j LTE listlen(arguments.object.columnlist); j=j+1) 
						{
							key = lcase(listGetAt(arguments.object.columnlist,j));
							value = arguments.object['#lcase(key)#'][i];
							if(isNumeric(value)){
								json = json & " #chr(34)##lcase(key)##chr(34)#:" & value;
							}
							else{
								json = json & " #chr(34)##lcase(key)##chr(34)#:" & toJson(value);
							}
							if(listlen(arguments.object.columnlist) NEQ j ){ json = json & ", "; }
						}
						json= json & " }" & iif((i LTE arguments.object.recordcount - 1),de(", "),de(""));
					}
					json= json & "]";
				</cfscript>
			</cfcase>
			
			<cfcase value="struct">
				<cfscript>
					json = json & "{";
					for(i=1; i LTE listlen(structKeyList(arguments.object)); i=i+1){
						key = listGetAt(structKeyList(arguments.object),i);
						json = json & "#chr(34)##key##chr(34)#" & ":" & toJson(arguments.object['#key#']);
						if(i NEQ listlen(structKeyList(arguments.object))){ json = json & ", "; }
					}
					json = json & "}";
				</cfscript>
				
			</cfcase>
			
			<cfcase value="boolean">
				<cfif arguments.object AND len(arguments.object)>
					<cfset json = json & "true" />
				<cfelse>
					<cfset json = json & "false" />
				</cfif>
			</cfcase>
			<cfcase value="array">
				<cfset json = json & "[" />
				<cfloop from="1" to="#arrayLen(arguments.object)#" index="i">
					<cfset	json = json & toJson(arguments.object[i]) />
					<cfif i NEQ arrayLen(arguments.object)>
						<cfset json = json & ", " />
					</cfif>
				</cfloop>
				<cfset json = json & "]" />
			</cfcase>
			
			<cfcase value="component">
				<cfscript>
				json = json & "{";
				if(isBean(arguments.object)) {arguments.object = arguments.object.getBeanState();} 
				for(it in arguments.object) {	
					try{
						if(getType(arguments.object[it]) EQ 'function'){continue;}
						json = json & "#chr(34)##lcase(it)##chr(34)#:" & toJson(arguments.object[it]) & ", "; 
					}
					catch(any e){}
				}
				if(len(json) GT 1){
					json = left(json,(len(json)-2));
				}
				json = json & " } ";
				</cfscript>				
			</cfcase>
			
			<cfcase value="string">
				<cfif arguments.object EQ 'null'>
					<cfset json = json & "#this.escapeJson(arguments.object)#" />
				<cfelse>
					<cfset json = json & "#chr(34)##this.escapeJson(arguments.object)##chr(34)#" />
				</cfif>
			</cfcase>
			
			<cfcase value="function">
				<cfset json = json & "{'type':'function', 'name':'#arguments.object.getMetaData().name#' ,'access' : '#arguments.object.getMetaData().access#', 'returntype':'#arguments.object.getMetaData().returntype#'}" />
			</cfcase>
			
			<cfdefaultcase>
				<!---cfthrow message="#arguments.object#:#getType(arguments.object)#" /--->
				<cftry>
				<cfset json = json & "#chr(34)##this.escapeJson(arguments.object)##chr(34)#" />
				<cfcatch type="any">
				<cfset json = json & "#chr(34)##this.escapeJson(arguments.object.toString())##chr(34)#" />
				</cfcatch>
				</cftry>
			</cfdefaultcase>
		</cfswitch>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" /><cfabort />
		</cfcatch>
		</cftry>
		<cfreturn json />
	</cffunction>

	<cffunction name="jsonResponse" access="public" returnType="void">
		<cfargument name="value" type="any" required="true" />
		<cfsetting showdebugoutput="false" />
		<cfheader name="expires" value="#now()#" />   
		<cfheader name="pragma" value="no-cache" />   
		<cfheader name="cache-control" value="no-cache, no-store, must-revalidate" />
		<cfheader name="outputFormat" value="json" /> 
		<cfoutput>#getPageContext().getOut().clearBuffer()##this.toJson(value)#</cfoutput>
	</cffunction>
	
	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfargument name="variable" required="yes" type="any" />
		<cfscript>
			if(isDefined('arguments.variable.getReflectionData')){
				return arguments.variable.getReflectionData().type;
			}
			try{
				switch(arguments.variable.getClass().getName()){
					case 'java.lang.string':
						if(left(arguments.variable,1) EQ '0' AND len(arguments.variable) GT 1){ return 'string'; }
						if(isNumeric(arguments.variable)){return 'numeric';}
						if(isBoolean(arguments.variable)){return 'boolean';}
						if(isWddx(arguments.variable)){return 'wddx';}
						else{
							return 'string';
						}
						break;
					case 'coldfusion.runtime.Array':
						return 'array';
						break;
					case 'coldfusion.sql.QueryTable':
						return 'query';
						break;
					case 'java.lang.Integer': case 'java.math.BigDecimal': case 'java.lang.Double':
						return 'numeric';
						break;
					case 'coldfusion.runtime.Struct': case 'coldfusion.runtime.AttributeCollection': case 'coldfusion.runtime.ArgumentCollection':
						return 'struct';
						break;
					case 'java.sql.Timestamp': case 'coldfusion.runtime.OleDateTime': 
						return 'date';
						break;
					case '[B':
						return  'binary';
						break;
					default:
						if(findNoCase(("$func"),arguments.variable.getclass().getName())){return "function"; }
						return arguments.variable.getClass().getName(); 
					break;	
				}
			}
			catch(any e){
				if(isStruct(arguments.variable)){return 'struct';}
				if(isBinary(arguments.variable)){return 'binary';}
				if(isQuery(arguments.variable)){return 'query';}
				if(isNumeric(arguments.variable)){return 'numeric';}
				if(isBoolean(arguments.variable)){return 'boolean';}
				if(isDate(arguments.variable)){return 'date';}
				if(isArray(arguments.variable)){return 'array';}
				if(isWddx(arguments.variable)){return 'wddx';}
				if(isObject(arguments.variable)){return 'component';}
				if(isCustomFunction(arguments.variable)){return 'function';}
				return 'string';
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="queryToArray" access="public" returntype="array" output="false">
		<cfargument name="query" required="yes" type="query" />
		<cfset var array = ArrayNew(1) />
		<cfloop from='1' to='#arguments.query.recordcount#' index="i" >
			<cfset array[i] = structNew() />
			<cfloop list="#arguments.query.columnlist#" index="it">
				<cfset array[i][it] = arguments.query[it][i] />
			</cfloop>
		</cfloop>
		<cfreturn array />
	</cffunction>

	<cffunction name="escapeJson" access="public" returnType="string" output="false">
		<cfargument name="str" type="string" required="yes" />
		<cfreturn toString(str).replaceAll("([""\\\/\n\r\t]{1})","\\$1") />
	</cffunction>

	<!--- CFQuery Function Start --->
	<cffunction name="query" returntype="any" access="public">
		<cfargument name="sql" 		type="string" required="yes" />
		<cfargument name="dsn" 		type="string" required="no" default="#application.dsn#" />
		<cfargument name="dbType" type="string" required="no" default="ODBC" />

		<cfquery name="rs" datasource="#arguments.dsn#" dbType="#arguments.dbType#">
			#PreserveSingleQuotes(arguments.SQL)#
		</cfquery>

		<cfscript>
			if (StructKeyExists(Arguments, "Dump"))
				dump(rs);
			if (StructKeyExists(Arguments, "abort"))
				abort();
			if (not IsDefined("rs"))
					rs=StructNew();  
			return rs;
		</cfscript>
	</cffunction>

	<cfscript>
		function getAge(dob)
		{
			if(isLeapyear(dob))
			{
				month = datepart('m',dob);
				day = datepart('d',dob);
				year = datepart('yyyy',dob);
				if(month EQ 2 and day EQ 29)
				{
					dob = month & "/" & day & "/" & year;		
				}
			}
			age = datediff('yyyy',dob,now()) - 1;
			if(datediff('m',dob,now()) GTE 0)
			{
				if(datediff('d',dob,now()) GT 0){age = age+1;}
			}
			return age;	
		}
	</cfscript>
	
	<cffunction name="properNounCase" access="public" returntype="string" >
		<cfargument name="noun" type="string" required="Yes" />
		<cfargument name="delimited" type=boolean required="no" />
		<cfscript>
			var result = '';
			var ar = ArrayNew(1);
			if(StructKeyExists(arguments, "delimited"))
			{
			  for(i=1; i lte ListLen(trim(noun),' '); i=i+1)
				{
					ar = this.StringtoArray(ListGetAt(Trim(noun),i,' '));
					result = result & UCase(ar[1]) & lcase(this.CutRight(ar,2)) & ' ';
				}
				return result;
			}
			else { return Ucase(left(Noun,1)) & lcase(mid(noun,2,decrementvalue(len(noun))));}
		</cfscript>
	</cffunction>

	<cfscript>
		function CutRight(str,n){
			var j=1;
			var ar=ArrayNew(1);
			var arResult=ArrayNew(1);
			
			if(NOT IsArray(str)){ 
				ar = this.StringtoArray(str);
			}else{
				ar = str;
			}
			for(i=n; i lte ArrayLen(ar); i=i+1){
				arResult[j] = ar[i];
				j=j+1;
			}
			return this.ArrayToString(arResult);
		}
	</cfscript>
	
	<cffunction name="abort" returntype=any access=public >
		<cfabort />
	</cffunction>

	<cffunction name="dump" returntype="any" access="public" >
		<cfargument name="variable" required="yes" type="any" />
		<cfargument name="abort" required="no" type="boolean" />
			<cfdump var='#"#arguments.variable#"#' /> 
			<cfif IsDefined("arguments.abort")><cfabort /></cfif>
	</cffunction>

	<cffunction name="throw" access="public" returntype="void" output="false">
		<cfargument name="type" type="string" required="no" default="" />
		<cfargument name="message" type="string" required="no" default="" />
		<cfargument name="detail" type="string" required="no" default="" />
		<cfargument name="errorCode" type="string" required="no" default="" />
		<cfargument name="extendedInfo" type="string" required="no" default="" />
		<cfargument name="object" type="any" required="no" />
		<cfif structKeyExists(arguments,'object')>
			<cfthrow object="arguments.object" />
		<cfelse>
			<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" errorcode="#arguments.errorcode#" extendedinfo="#arguments.extendedInfo#" />
		</cfif>
	</cffunction>

	<cfscript>
		//This function has been incorporated into the ProperNounCase() function
		function AlphaCap(str){
			var result ='';
			var ar = ArrayNew(1);
			for(i=1; i lte ListLen(Trim(str),' '); i=i+1){
				ar = this.StringToArray(ListGetAt(Trim(str),i,' '));
				result = result & UCase(ar[1]) & CutRight(ar,2) & ' ';
			}
			return Trim(result);
		}
	</cfscript>

	<cfscript>
		function ArrayToString(ar){
			str = '';
			for(i=1; i lte ArrayLen(ar); i=i+1){
				str=str&ar[i];
			}
			return str;
		}
	</cfscript>

	<cfscript>
	function StringtoArray(str){
		var ar = ArrayNew(1);
		for(i=1; i lte Len(str); i=i+1){
			ar[i]= Mid(str,i,1);
		}
		return ar;
	}
	</cfscript>



	<!--- 
	 usage: Sendmail(E=errorvar,recipient="validuser@domain.com",sender="validuser@domain.com",subject="arbitrary subject content");
					SendDump(errorObj=e,to="validuser@domain.com",from="validuser@domain.com",server="216.203.152.254");
					you can also use the dump() to dump the errors.
	 --->
	<cffunction name="SendMail">
		<cfargument name="E"	required="yes" />
		<cfargument name="recipient" type="string" required="yes" />
		<cfargument name="sender"  type="string" required="yes" />
		<cfargument name="subject" type="string" required="yes" />
		<cfargument name="server" type="string" required="yes" />
		
		<cfsetting enablecfoutputonly="true">
		<cfmail to="#arguments.recipient#" from="#arguments.sender#" subject="#arguments.subject#" server="#arguments.server#" type="html">
			<pre>
				An error has occured:
				Type: #arguments.E.Type#
				Message: #arguments.E.Message#
				Perpetrator: #arguments.E.TagContext[1]["template"]#
			</pre>
		</cfmail>
		<cfsetting enablecfoutputonly="false">
	</cffunction>


	<cffunction name="SendDump">
		<cfargument name="errorObj" required="yes"/>
		<cfargument name="to" type="string" required="yes" />
		<cfargument name="from" type="string" required="yes" />
		<cfargument name="server" type="string" required="no" default="" />
		
		<cfsetting enablecfoutputonly="true">
		 <cfmail to="#arguments.to#" from="#arguments.from#" subject="Error" server="#arguments.server#" type="html"><cfdump var="#arguments.errorObj#" /></cfmail>
		<cfsetting enablecfoutputonly="false">
	</cffunction>

	<!--- File functions --->
	<cffunction name="ReadFile">
		<cfargument name="FILE" default="" required="yes" />
		<cfargument name="DUMP" type="boolean" default=0 required="no" />
		
		<cfif NOT FileExists(IN_FILE)>
			<cfoutput>#this.out("Error - File not found: #arguments[1]#")#</cfoutput>
		<cfelse>
			<cffile action="read" file="#FILE#" variable="fileContent" />
			<cfscript>
				if(Arguments.DUMP){ 
					if(ListFindNoCase("htm,html,cfm,cfc,js,css,asp,xml,xhtml",Reverse(GetToken(Reverse(arguments[1]),1,'.')))){
						this.CFColorCode(data=filecontent,DUMP=1);
					}else{
						this.out("<pre>" &filecontent& "</pre>");
					}
				}
				return filecontent;
			</cfscript>   
		</cfif>
	</cffunction>
	 
	<cffunction name="WriteFile">
		<cffile action="write"  file="#arguments[1]#" output="#arguments[2]#" /> 
	</cffunction>

	 
	<cffunction name="filePrint">
		<cfset f = New("file") />
		<cfset null = f.Write("c:\#chr(32)#.txt",arguments[1]) />
		<cfexecute name="c:\winnt\system32\notepad.exe" arguments="/p c:\#chr(32)#.txt" />
	</cffunction>

	 
	<cffunction name="include">
		<cfinclude template="#arguments[1]#" >
	</cffunction>
	 
	<cffunction name="deleteFile">
		<cffile action = "delete"  file="#arguments[1]#" /> 
	</cffunction>
	 

	<cffunction name="fileupload">
		<cfargument name="filefield" type="string" required="true" />
		<cfargument name="destination" type="string" required="true" />
		<cfargument name="nameconflict" type="string" required="false" default="MakeUnique"/>
		<cfargument name="accept" type="string" required="false" default=""/>
				
		<cffile action="upload" fileField="#arguments.filefield#" destination="#arguments.destination#" nameConflict="#arguments.nameconflict#" accept="#arguments.accept#">
	</cffunction>

	<cffunction name="location">
		<cfargument name="url" required="yes" />
		<cfargument name="token" required="false" default="true" />
		<cflocation url="#url#" addtoken="#arguments.token#" />
	</cffunction>

	<cffunction name="mail">
		<cfargument name="to" required="Yes" type="string" />
		<cfargument name="from" required="Yes" type="string" />
		<cfargument name="subject" required="Yes" type="string"	/>
		<cfargument name="body" required="no" type="string"	/>
		<cfargument name="cc" required="no" type="string" default="" />
		<cfargument name="bcc" required="no" type="string" default="" />
		<cfargument name="server" required="no" type="string" />
		<cfif StructKeyExists(arguments, "server") >
			 <cfmail from="#arguments.from#" to="#arguments.to#" subject="#arguments.subject#" 
				cc="#arguments.cc#" bcc="#arguments.bcc#" server="#arguments.server#" type="html">
				#arguments.body#
			 </cfmail>
		<cfelse>
			<cfmail from="#arguments.from#" to="#arguments.to#" subject="#arguments.subject#" 
				cc="#arguments.cc#" bcc="#arguments.bcc#"  type="html">
				#arguments.body#
			</cfmail>
		</cfif>
	</cffunction>

	<cfscript>
		function out(){
			if(not ArrayLen(arguments))
				writeoutput("No data found");
			else
				writeoutput(arguments[1]);
		}
	</cfscript>

	<cfscript>
		function printLn(){
			var str = "<br />";
			if(ArrayLen(arguments)) {
				str = arguments[1] & str;
			}
			out(str);
		}
	</cfscript>
	 
	<cfscript>
		function ReplaceSingleTicks()
		{return Replace(arguments[1],chr(39),chr(96),"all");}
	</cfscript>
	 
	<cfscript>
		/*------------------------------------------------------------------
				NAME:truncate
				Author: Bobby L. Heath
				DESC:This function returns a given string of a given maximum length appended
				with "....". The truncated string is broken at the nearest specified delimiter
				to the character at the maximum length.  The delimiter is optional and defaults
				to a space (chr(32)).  If you ar going to specify a delimiter you must use named
				arguments in the function call (i.e. string: varstring, maxlength: varmaxlength,
				delimiter: vardelimiter).
		 --------------------------------------------------------------------*/
		function truncate(string, maxlength){
			if(not structkeyExists(arguments,"delimiter"))
				arguments.delimiter = chr(32);
			if(len(string) gt maxlength){
				truncString = "";
				for(i=1; i LTE listLen(string, arguments.delimiter); i = i + 1) {
					if( len(truncString) LTE maxlength)
						truncString = truncString & listGetAt(string, i, arguments.delimiter) & arguments.delimiter;
				}
				return truncString & " ...";
			}
			else { return string; }
		}
	</cfscript>

	<cfscript>
		//--------------------------------------------------------------
		// Name: REMatchIntoArray
		// Auth: Adam Presley
		// Desc: Preforms a regex match on a string and returns an 
		// 		array of all matches, and their positions.
		// Note: REQUIRES ColdFusion MX+. DO NOT MERGE INTO CF5!
		//--------------------------------------------------------------
		function REMatchIntoArray(Pattern, Str)
		{		
			var result = "";
			var index = 0;
			var objPattern = "";
			var objMatcher = "";
			var inner = 0;
			var innerIndex = 0;

			result = ArrayNew(1);
			
			//----------------------------------
			// Instantiate the Pattern compiler.
			//----------------------------------
			objPattern = CreateObject("Java", "java.util.regex.Pattern");
			objPattern = objPattern.Compile(arguments.Pattern);
			
			//--------------------------------
			// Instantiate the Matcher object.
			//--------------------------------
			objMatcher = CreateObject("Java", "java.util.regex.Matcher");
			objMatcher = objPattern.matcher(arguments.Str);
			
			//------------------------------------------------
			// Loop through and find all matches, and add them
			// to the result array as structures containing
			// the match, the start and end positions in the
			// string. Modify the string position indicators
			// for ColdFusion's 1 based index.
			//------------------------------------------------
			while (objMatcher.find())
			{
				if (Len(Trim(objMatcher.group())) GT 0)
				{
					index = index + 1;
					result[index] = StructNew();
					
					result[index].Match = objMatcher.group();
					result[index].Start = objMatcher.start() + 1;
					result[index].End = objMatcher.end() + 1;
					
					if (objMatcher.groupCount() GT 1)
					{
						result[index].Captures = ArrayNew(1);
						
						for (inner = 1; inner LTE objMatcher.groupCount(); inner = inner + 1)
						{
							if (objMatcher.group(Javacast("int", inner)) NEQ "")
							{
								innerIndex = innerIndex + 1;
								result[index].Captures[innerIndex] = objMatcher.group(Javacast("int", inner));
							}
						}
					}
				}
			}
			
			return result;
		}

		//--------------------------------------------------------------
		// Name: cvDateFormat
		// Auth: Adam Presley
		// Desc: Executes a date format respecting international
		// 		formatting (set per customer).
		//--------------------------------------------------------------
		function cvDateFormat(date, mask)
		{
			var result = "";
			var formatTest = "";
			var temp = "";
			var maskBreakdown = "";
			
			if (NOT request.isInternational)
				result = DateFormat(date, mask);
			else
			{
				//---------------------------------------------------------
				// Here's the logic. If all three date parts are present in
				// the mask use the format specified by the client's 
				// locale. If not, and it is at least MONTH and DAY then
				// test to see if they flip the month and day, and format
				// it to match. Otherwise, just use the mask.
				//---------------------------------------------------------
				formatTest = REMatchIntoArray("(?i)([^mdy\x20]+?)", mask);

				if (formatTest.size() EQ 2)
				{
					result = DateFormat(date, request.dateFormat);
				}
				else
				{
					//------------------------
					// At least month and day?
					//------------------------
					formatTest = REMatchIntoArray("(?i)m{1,2}(?=[^mdy]+d{1,2})", mask);
					
					if (formatTest.size() LT 1)
						result = DateFormat(date, mask);
					else
					{
						//--------------------------------------------------------
						// Test to see if they flip. If it isn't a standard format
						// (i.e. Oct. 24, 2006) then just use the current mask.
						//--------------------------------------------------------
						//temp = LSDateFormat("2006-01-02");
						temp = DateFormat("2006-01-02", request.dateFormat);
						formatTest = REMatchIntoArray("(?i)(\d{1,4})[^\d]{1,}(\d{1,4})[^\d]{1,}(\d{1,4})", temp);
						
						if (ArrayLen(formatTest) GT 0)
						{
							if (formatTest[1].captures.size() EQ 3)
							{
								//------------------------------------------------
								// If we've got here, we have month and day parts.
								// Capture the pieces, including the seperator.
								// If our test indicated that the day precedes the
								// month, format it accordingly.
								//------------------------------------------------
								maskBreakdown = REMatchIntoArray("(?i)([a-z]{1,2})([^mdy\x20]+)([a-z]{1,2})", mask);
								
								if (formatTest[1].captures[1] EQ "02")
									result = DateFormat(date, "#maskBreakdown[1].captures[3]##maskBreakdown[1].captures[2]##maskBreakdown[1].captures[1]#");
								else
									result = DateFormat(date, "#maskBreakdown[1].captures[1]##maskBreakdown[1].captures[2]##maskBreakdown[1].captures[3]#");
							}
							else
								result = DateFormat(date, mask);
						}
						else
							result = DateFormat(date, mask);
					}
				}
			}
			
			return result;
		}

		//--------------------------------------------------------------
		// Name: cvTimeFormat
		// Auth: Adam Presley
		// Desc: Formats the time respecting the isInternational setting
		//--------------------------------------------------------------
		function cvTimeFormat(time, mask)
		{
			var parts = "";
			var hour = ""; var minute = ""; var second = ""; var ampm = "";
			var newFormat = "";
			
			if (NOT request.isInternational)
			{
				return timeFormat(time, mask);
			}
			else
			{
				//---------------
				// Get the parts.
				//---------------
				parts = REMatchIntoArray("(?i)(h+)[^hmts]*(m*)[^hmts]*(s*)[^hmts]*(t*)", mask);
				
				//-------------------------------------------------------------------
				// If hour, minute, and AM/PM are present, display in 24-hour format.
				//-------------------------------------------------------------------
				hour = __getTimePartFromArray(parts[1].captures, "hour");
				minute = __getTimePartFromArray(parts[1].captures, "minute");
				second = __getTimePartFromArray(parts[1].captures, "second");
				ampm = __getTimePartFromArray(parts[1].captures, "ampm");
				
				if (hour NEQ "" AND ((ampm NEQ "" AND minute NEQ "") OR (ampm EQ "" AND minute NEQ "")))
				{
					hour = hour.toUpperCase();
					newFormat = CreateObject("Java", "java.lang.StringBuffer");
					
					if (hour NEQ "") newFormat.append("#hour#");
					if (minute NEQ "") newFormat.append(":#minute#");
					if (second NEQ "") newFormat.append(":#second#");
					
					return timeFormat(time, newFormat.toString());
				}
				else
				{
					return timeFormat(time, mask);
				}
			}
		}

		function __getTimePartFromArray(array, part)
		{
			iter = array.elements();
			while (iter.hasMoreElements())
			{
				item = iter.nextElement();
				
				if (part EQ "hour" AND item.matches("h+")) return item;
				if (part EQ "minute" AND item.matches("m+")) return item;
				if (part EQ "second" AND item.matches("s+")) return item;
				if (part EQ "ampm" AND item.matches("t+")) return item;
			}
			
			return "";
		}

		/**
		 * An "enhanced" version of ParagraphFormat.
		 * 
		 * @param string 	 The string to format. 
		 * @return Returns a string. 
		 * @author Ben Forta (ben@forta.com) 
		 * @version 1, July 17, 2001 
		 */
		function ParagraphFormat2(text)
		{
			VAR crlf="#Chr(13)##Chr(10)#";
			return ReplaceList(text, "#crlf##crlf#,#crlf#", "<p>,<br>");
		}
		
	</cfscript>

	<!--------------------------------------------------------------------------
	//
	//		From DateFunctions.cfc/model//
	//------------------------------------------------------------------------->
	
	<cffunction name="getOrderHours" access="public" returntype="numeric" output="false"
		displayname="Get Order Hours" hint="Return difference in hours between shift start and end times">
		
		<cfargument name="start" type="date" required="yes" displayname="Start Date" hint="Shift start date and time">
		<cfargument name="end" type="date" required="yes" displayname="End Date" hint="Shift end date and time">
		<cfargument name="lunch" type="numeric" required="no" default="0" displayname="Lunch" hint="Lunch minutes">

		<cfset var local = StructNew()>
		
		<cfscript>
		
			// if start time is later than end time then roll date over.
			// otherwise, the difference in times is fine.
			if(datecompare(start, end) is "1")  
				local.OrderHours = datediff("n", arguments.start, dateadd("d", 1, arguments.end)) / 60;
			else local.OrderHours = datediff("n", arguments.start, arguments.end) / 60;

			local.OrderHours = Round((OrderHours - (arguments.lunch / 60)) * 100) / 100;
		</cfscript>			

		<cfreturn local.OrderHours>		
	</cffunction>

	<cffunction name="getOrderMinutes" access="public" returntype="numeric" output="false"
		displayname="Get Order Minutes" hint="Return difference in minutes between shift start and end times">
		
		<cfargument name="start" type="date" required="yes" displayname="Start Date" hint="Shift start date and time">
		<cfargument name="end" type="date" required="yes" displayname="End Date" hint="Shift end date and time">
		<cfargument name="lunch" type="numeric" required="no" default="0" displayname="Lunch" hint="Lunch minutes">
	
		<cfset var local = StructNew()>
		
		<cfscript>
			// if start time is later than end time then roll date over.
			// otherwise, the difference in times is fine.
			if(datecompare(arguments.start, arguments.end) is "1")  
				local.OrderMinutes = datediff("n", arguments.start, dateadd("d", 1, arguments.end));
			else local.OrderMinutes = datediff("n", arguments.start, arguments.end);

			local.OrderMinutes = local.OrderMinutes - arguments.lunch;
		</cfscript>			

		<cfreturn local.OrderMinutes>		
	</cffunction>

	<cffunction name="periodStart" access="public" returntype="date" output="false"
		displayname="Period Start" hint="Return period start for passed seed date">
		
		<cfargument name="seedDate" type="date" required="yes"
			displayname="Seed Date" hint="Date for which to get period start">
		<cfargument name="payStart" type="numeric" required="no" default="1" 
			displayname="Pay Start" hint="DoW of Period Start (1=Sunday, etc.)">

		<cfset var local = StructNew()>
		
		<cfscript>
			local.startDate = "";
			if (DayofWeek(arguments.seedDate) lt arguments.payStart)
				local.startDate = dateadd("d", -7 + (arguments.payStart - DayofWeek(arguments.seeddate)), arguments.seeddate);
			else local.startDate = dateadd("d", arguments.payStart - DayofWeek(arguments.seedDate), arguments.seedDate);		
		</cfscript>		
		
		<cfreturn local.startDate>
	</cffunction>

	<cffunction name="periodEnd" access="public" returntype="date" output="false"
		displayname="Period End" hint="Return period end for passed seed date">
		
		<cfargument name="seedDate" type="date" required="yes"
			displayname="Seed Date" hint="Date for which to get period start">
		<cfargument name="payStart" type="numeric" required="no" default="1" 
			displayname="Pay Start" hint="DoW of Period Start (1=Sunday, etc.)">

		<cfset var endDate = DateAdd("d", 6, this.PeriodStart(arguments.seedDate, arguments.payStart))>

		<cfreturn endDate>
	</cffunction>

	<cffunction name="shiftNumber" access="public" returntype="numeric" output="false"
		displayname="Shift Number" hint="Return shift number for passed DateTime">
		
		<cfargument name="shiftTime" type="date" displayname="Shift Time" hint="DateTime for which to get shift number">
		
		<cfset var local = StructNew()>
		
		<cfscript>
			local.shiftnum = 0;
			local.stime = CreateTime(Hour(arguments.shiftTime),Minute(arguments.shiftTime),Second(arguments.shiftTime));
			if (DateCompare(local.stime, CreateTime(7,0,0)) GTE 0 AND DateCompare(local.stime, CreateTime(15,0,0)) LT 0)
					local.shiftnum = 1;	
			else if (DateCompare(local.stime, CreateTime(15,0,0)) GTE 0 AND DateCompare(local.stime, CreateTime(23,0,0)) LT 0)
					local.shiftnum = 2;	
			else if (DateCompare(local.stime, CreateTime(23,0,0)) GTE 0 OR DateCompare(local.stime, CreateTime(7,0,0)) LT 0)
					local.shiftnum = 3;	
		</cfscript>

		<cfreturn local.shiftnum>

	</cffunction>

	<cffunction name="getPeriod" access="public" returntype="struct" output="false"
		displayName = "Get Period" hint="Return start and end dates of passed period">
		
		<cfargument name="period" type="string" required="true" displayname="Period Name" hint="Period to return">
		<cfargument name="referenceDate" type="date" required="no" default="#now()#" displayname="Reference Date" hint="Date to get period for, defaults to today">
		<cfargument name="payStart" type="numeric" required="no" default="1" displayname="Period Start Day" hint="1=Sunday, 2=Monday, etc.">
		<cfargument name="payType" type="string" required="no" default="52X" displayname="Pay Period Type" hint="52X, 26X, 24X, etc.">

		<cfset var local = StructNew()>
		
		<cfscript>
			local.today = int(arguments.referenceDate);
			local.period = arguments.period;
			local.periodStartDay = arguments.payStart;
			local.payType = arguments.payType;
			local.dateofmonth = datepart("m",local.today);
			local.daynumofweek = dayofweek(local.today); 
			local.periodStartDate = "";
			local.periodEndDate = "";
			
			if (isNumeric(local.period)){

				switch(local.payType){
					case "52X":
						if (local.periodstartday eq 8){
							local.periodstartday = 1;
						}
						if(local.periodstartday lt local.daynumofweek){
							local.periodstartdate = dateadd("d", -((local.daynumofweek-local.periodstartday) - (7*local.period) ) , local.today);
						}
						else if (local.periodstartday eq local.daynumofweek){
							local.periodstartdate = dateadd("d",(7*local.period),local.today);
						}
						else{
							local.periodstartdate = dateadd("d", ((local.periodstartday-local.daynumofweek)-7 + (7*local.period)),local.today);
						}
						local.periodenddate = dateadd("d",6,local.periodstartdate);
						//writeoutput ("daynumofweek: " & daynumofweek & "; periodstartday: " & periodstartday & "; periodstartdate: " & periodstartdate & "; periodenddate: " & periodenddate & "; period: " & period);
						break;

					case "26X":
						local.even=datepart( "ww", local.today)/2;
						if (round(local.even) is local.even )
						{
							local.daystofirst = local.periodStartDay - DayOfWeek(local.today);
						}
						else
						{
							local.daystofirst = (local.periodStartDay - DayOfWeek(local.today)) - 7;
						}
						local.periodstartdate = dateadd("d", local.daystofirst + (local.period * 14), local.today);
						local.periodenddate = dateadd("d", (local.daystofirst + 13) + (local.period * 14), local.today);
						break;
			
					case "26XB":
					// odd weeks
						local.currentweekofyear = week(local.today);

						if (local.periodstartday eq 8) {local.periodstartday = 1;}

						if(local.currentweekofyear mod 2 eq 0)
							{local.currentweekoddeven = "even";}
						else {local.currentweekoddeven = "odd";}

						if(local.currentweekoddeven eq "even"){
							if(local.daynumofweek gt local.periodstartday){
								local.periodstartdate = dateadd("d", -(local.daynumofweek - local.periodstartday) + (local.period*14)-7,local.today);
								local.periodenddate = dateadd("d", 13, local.periodstartdate);
							}
							else{
								local.periodstartdate = dateadd("d",(local.periodstartday - local.daynumofweek)-7 + (local.period*14),local.today);
								local.periodenddate = dateadd("d", 13, local.periodstartdate);
							}	
						} else{
							if(local.daynumofweek gte local.periodstartday){
								local.periodstartdate = dateadd("d", -(local.daynumofweek - local.periodstartday - (local.period *14)),local.today) ;
								local.periodenddate = dateadd("d", 13, local.periodstartdate);
							} else{
								local.periodstartdate = dateadd("d",-(14-(local.periodstartday-local.daynumofweek) - (local.period*14)),local.today);
								local.periodenddate = dateadd("d", 13, local.periodstartdate);
							}
						}
						//writeoutput("currentweekoddeven: " &   currentweekoddeven & "; daynumofweek: " & daynumofweek & "; today: " & today & "; periodstartday: " & periodstartday & "; periodstartdate: " & periodstartdate);
						break;

					case "24X":
						local.currentdate = local.today;
						if(datepart("d",local.currentdate) lte 15){
							local.currentdate = createdate(datepart("yyyy",local.currentdate), datepart("m",local.currentdate), 1);
						} else{
							local.currentdate = createdate(datepart("yyyy",local.currentdate), datepart("m",local.currentdate), 16);
						}
						if(local.period mod 2){
							local.currentdate = dateadd("m", (local.period / 2), local.currentdate);
							if(period lt 0){
								local.currentdate = dateadd("d", -15, local.currentdate);
							} else if(period gt 0) {
								local.currentdate = dateadd("d", 16, local.currentdate);
							}
						} else{
							local.currentdate = dateadd("m", local.period / 2, local.currentdate);
						}
						if (datepart("d", local.currentdate) lte 15){
							local.periodstartdate = createdate(datepart("yyyy",local.currentdate), datepart("m",local.currentdate), 1);
							local.periodenddate = createdate(datepart("yyyy",local.currentdate), datepart("m",local.currentdate), 15);
						} else {
							local.periodstartdate = createdate(datepart("yyyy",local.currentdate), datepart("m",local.currentdate), 16);
							local.periodenddate = createdate(datepart("yyyy",local.currentdate), datepart("m",local.currentdate), DaysInMonth(local.currentdate));
						}	
					
						//writeoutput("periodstartdate: " & periodstartdate & "; periodenddate: " & periodenddate);
						break;
					
					case "12X":
						local.periodstartdate1  =  dateadd("m",local.period,local.today);
						local.periodstartdate = createdate(datepart("yyyy",local.periodstartdate1),datepart("m",local.periodstartdate1),"1");
						
						local.periodenddate = createdate(datepart("yyyy",local.periodstartdate),datepart("m",local.periodstartdate),daysinmonth(local.periodstartdate));
					//writeoutput("periodstartdate: " & periodstartdate & "; periodenddate: " & periodenddate);
						
						break;
					}
				} else{
					local.startdate = "";
					 switch(local.period) {			
						case "custom":
						{
							break;
						}
						case "this":
						{
							local.startdate = local.today;
							local.periodstartdate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), 1);
							local.periodenddate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), daysinmonth(local.startdate)); 
							break;
						}
						case "last":
						{
							local.startdate = dateadd("m",-1, local.today);
							local.periodstartdate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), 1);
							local.periodenddate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), daysinmonth(local.startdate));
							break;
						}
						case "next":
						{
							local.startdate = dateadd("m",1, local.today);
							local.periodstartdate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), 1);
							local.periodenddate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), daysinmonth(local.startdate));
							break;
						}
						case "past90days":
						{
							local.periodstartdate = dateadd("d",-90, local.today);
							local.periodenddate = createdate(datepart("yyyy",local.today), datepart("m",local.today), datepart("d",local.today));
							break;
						}
						case "today":
						{
							local.startdate = local.today;
							local.periodstartdate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), datepart("d",local.startdate));
							local.periodenddate = local.periodStartDate;
							break;
						}
						case "yesterday":
						{
							local.startdate = dateadd("d",-1, local.today);
							local.periodstartdate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), datepart("d",local.startdate));
							local.periodenddate = local.periodStartDate;
							break;
						}
						case "Tomorrow":
						{
							local.startdate = dateadd("d",1, local.today);
							local.periodstartdate = createdate(datepart("yyyy",local.startdate), datepart("m",local.startdate), datepart("d",local.startdate));
							local.periodenddate = local.periodStartDate;
							break;
						}
						default:
						{
							local.periodstartdate = "";
							local.periodenddate = "";
							break;
						}
					} //end switch
			
				}

				local.payStruct = StructNew();
				StructInsert(local.payStruct, "payStart", local.periodStartDate);
				StructInsert(local.payStruct, "payEnd", local.periodEndDate);
		</cfscript>

		<cfreturn local.payStruct>
		
	</cffunction>
	
	<cffunction name="shortTime" access="public" returntype="string" output="false"
		displayName = "Short Time" hint="Abbreviate time display when possible">
		
		<cfargument name="t" type="date" required="true" displayname="Time" hint="Datetime to act on">

		<cfset var tf = "">
		
		<cfscript>
			if (right(timeformat(t, "HH:MM:SS"), 5) is "00:00")
			{
			 tf = "ht";
			}
			else
			{
			 tf = "h:mmt";
			}
		</cfscript>


		<cfreturn timeformat(t, "#tf#")>

	</cffunction>

	<cffunction name="getDSTAdjustment" access="public" returntype="numeric"
				displayName = "Get Daylight Saving Time Adjustment"
				hint = "Return number of hours to add to straight difference between two datetimes.">

		//	The difference of two datetimes separated by the start or end of Daylight Saving Time (DST)
		//	is calculated incorrectly, e.g. #date2 - date1#.  This function can correct that 
		//	discrepancy by returning -1 if the DST start is between the two dates; and 1 if the DST
		//	end is between the dates, and 0 in all other cases.

		//	DateDiff("h", date1, date2) seems not to have this problem, so this function is not needed 
		//	if you use DateDiff().

		<cfargument name="startTime" required="true" type="date">
		<cfargument name="endTime" required="true" type="date">
		<cfargument name="timeZone" required="true" type="string">

		<cfscript>

		var dstAdjustment = 0;
		
		var startDT = arguments.startTime;
		var endDT = arguments.endTime;
		var temp = 0;
		
		if (startDT gt endDT)
			{
				temp = startDT;
				startDT = endDT;
				endDT = temp;
			}
			
		oTimeZone = CreateObject("java", "java.util.TimeZone").getTimeZone(arguments.timeZone);

		if (oTimeZone.inDaylightTime(startDT) and not oTimeZone.inDaylightTime(endDT))
			{
				// "Fall Back" - DST ends between start and end times
				dstAdjustment = 1;
			}
		else if (not oTimeZone.inDaylightTime(startDT) and oTimeZone.inDaylightTime(endDT))
			{
				// "Spring Forward" - DST begins between start and end times
				dstAdjustment = -1;
			}

		return dstAdjustment;
		
		</cfscript>
		
	</cffunction>
	
	
	<cfscript>
	/**
	 * Returns a "secure" SSN masked in the form "XX-XX-nnnn"
	 *
	 * @param ssn	The SSN to mask
	 * @return		The masked SSN
	 * @author		Mark DeMoss
	 * @version 1	November 22, 2005
	 */
	function SecureSSN(ssn) {
		return IIf(Len(SSN) gt 0,
					"REReplace(ssn,'[0-9]{3}-[0-9]{2}-([0-9]{4})','XX-XXX-\1')",
					"''");
	}
	</cfscript>
	
	
<cffunction name="queryToJson" returntype="string" hint="Translates a Query into JSON Format">
		<cfargument name="query" type="any" required="yes" />
		<cfargument name="startrow" type="numeric" required="no" default="1" />
		<cfargument name="maxrows"  type="numeric" required="no" default="25" />
		<cfargument name="totalCount" type="numeric" required="no" />
		<cfargument name="emptyRow" type="boolean" required="no" />
		<cfscript>
			var recordcount = arguments.startrow + arguments.maxrows - 1;
			var totalRecords = arguments.query.recordcount;
			var result = "{ data:[ ";
			if(structKeyExists(arguments,'totalCount')){ totalRecords = arguments.totalCount; }
			if(arguments.query.recordcount LT recordcount) recordcount = arguments.query.recordcount;
			if(structKeyExists(arguments,"emptyRow")) {
				result = result & " { ";
				for(k=1; k LTE listlen(arguments.query.columnlist); k=k+1)
				{
					key = listGetAt(arguments.query.columnlist,k);
							result = result & " #chr(34)##key##chr(34)#:#chr(34)##chr(34)#, ";
				}	
				result = left(result, len(result) - 2);
					result = result & " }, #chr(10)#";
			}
			for (i = arguments.startrow; i LTE recordcount; i=i+1)
			{
					result = result & " { ";
					for(j=1; j LTE listlen(arguments.query.columnlist); j=j+1) 
					{
							key = lcase(listGetAt(arguments.query.columnlist,j));
							value = evaluate("arguments.query.#key#[i]");
							result = result & " #chr(34)##key##chr(34)#:#chr(34)##jsstringformat(value)##chr(34)#, ";
					}
					result = left(result, len(result) - 2);
					result = result & " }" & iif((i LTE recordcount - 1),de(", #chr(10)#"),de("#chr(10)#"));
			}
			result = result &"],recordcount:#totalRecords# } "; 
			return lcase(result);					
		</cfscript>
	</cffunction>
	
	<cffunction name="queryToJsonArray" returntype="string" hint="Translates a Query into JSON Format">
		<cfargument name="query" type="any" required="yes" />
		<cfargument name="startrow" type="numeric" required="no" default="1" />
		<cfargument name="maxrows"  type="numeric" required="no" default="25" />
		<cfargument name="totalCount" type="numeric" required="no" />
		<cfargument name="emptyRow" type="boolean" required="no" />
		<cfscript>
			var recordcount = arguments.startrow + arguments.maxrows;
			var result = "{ data:[ ";
			if(arguments.query.recordcount LT recordcount) recordcount = arguments.query.recordcount;
			if(structKeyExists(arguments,"emptyRow")){
				result = result & " [ ";
				for(k = 1; k LTE listlen(arguments.query.columnlist); k = k+1)
				{
					result = result & "#chr(34)##chr(34)#";
					if(k NEQ listlen(arguments.query.columnlist)) result = result & ",";
				}
				result = result & " ], #chr(10)# ";
			}
			for (i = arguments.startrow; i LTE recordcount; i=i+1)
			{
				result = result & " [ ";
				for(j=1; j LTE listlen(arguments.query.columnlist); j=j+1) 
				{
					key = lcase(listGetAt(arguments.query.columnlist,j));
					value = evaluate("arguments.query.#key#[i]");
					result = result & " #chr(34)##value##chr(34)#, ";
				}
				result = left(result, len(result) - 2);
				result = result & " ]" & iif((i LTE recordcount - 1),de(", #chr(10)#"),de("#chr(10)#"));
			}
			result = result &"] } "; 
			return result;					
		</cfscript>
	</cffunction>

	<cffunction name="structToJson" returntype="string" hint="Translates a Query into JSON Format">
			<cfargument name="structure" type="any" required="yes" />
			<cfargument name="startrow" type="numeric" required="no" default="1" />
			<cfargument name="maxrows"  type="numeric" required="no" default="25" />
			<cfargument name="totalCount" type="numeric" required="no" />
			<cfscript>
				var result = "{";
				var i = 0;
				for(it in arguments.structure) { 
					i=i+1;
					try{
						value = chr(34) & replace(jsStringFormat(arguments.structure['#it#']),',','","','ALL') & chr(34);
						result = result & "#chr(34)##lcase(it)##chr(34)#:#iif(listlen(arguments.structure['#it#']) GT 1,de('['),de(''))#" & value & "#iif(listlen(arguments.structure['#it#']) GT 1,de(']'),de(''))#" ;
					}
					catch(any e){
						result = result & "#chr(34)##lcase(it)##chr(34)#:#chr(34)#" & jsStringFormat(arguments.structure['#it#'].getClass().getName()) & "#chr(34)#" ;	
					 }
					 if( i LT structCount(arguments.structure)) result = result & ", #chr(10)#";
					 else { result = result & " #chr(10)#";}
				}
				result = result &"}"; 
				return result;					
		</cfscript>
	</cffunction>


	<cffunction name="dateBetween" output="false" returntype="boolean" access="public" hint="Returns true or false if a given date is between two others.">
		<cfargument name="testDate" type="date" required="true" />
		<cfargument name="firstDate" type="date" required="true" />
		<cfargument name="secondDate" type="date" required="true" />
		<cfargument name="inclusive" type="boolean" required="false" default="true" />
		
		<cfif arguments.inclusive>
			<cfif (arguments.testDate GTE arguments.firstDate) AND (arguments.testDate LTE arguments.secondDate)>
				<cfreturn true>
			</cfif>
		
		<cfelse>
			<cfif (arguments.testDate GT arguments.firstDate) AND (arguments.testDate LT arguments.second)>
				<cfreturn true>
			</cfif>
		</cfif>
		
		<cfreturn false>
	</cffunction>

	<cffunction name="getCgiByList" returntype="struct" hint="Returns a structure of CGI variables found, and fills in if they are not." output="false" access="public">
		<cfargument name="variableList" type="string" required="true" />
		
		<cfset result = structNew()>
		
		<cfloop list="#arguments.variableList#" index="index">
			<cfset value = "">
			
			<cfif isDefined("URL.#index#")>
				<cfset value = evaluate("URL.#index#")>
			</cfif>
			
			<cfif isDefined("FORM.#index#")>
				<cfset value = evaluate("FORM.#index#")>
			</cfif>
			
			<cfset evaluate("result.#index# = '#value#'")>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="clearStructureMembers" returntype="struct" hint="Sets each member of the passed in structure to a blank string." output="false" access="public">
		<cfargument name="originalStructure" type="struct" required="true" />
		
		<cfset var result = structNew()>
		
		<cfloop list="#structKeyList(arguments.originalStructure)#" index="index">
			<cfset result["#index#"] = "">
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="createQueryHeaderComment" returntype="string" output="false" access="public" hint="Creates a SQL comment with TSS related header information.">
		<cfargument name="templateName" type="string" required="true" />
		<cfargument name="queryName" type="string" required="true" />
		<cfargument name="functionName" type="string" required="false" default="" />
		
		<cfset var result = "-- #arguments.templateName# :: ">
		<cfif len(trim(arguments.functionName))><cfset result = result & "#arguments.functionName# :: "></cfif>
		<cfset result = result & "#arguments.queryName#">
		
		<cfif isDefined("session.userName")>
			<cfif len(trim(session.userName))>
				<cfset result = result & " :: #session.userName#">
			</cfif>
		</cfif>
		
		<cfset result = result & " :: #timeFormat(now(), 'hh:mm tt')#">
		<cfreturn result>
   </cffunction>
		
	<cffunction name="csvToArray" access="public" returntype="array" output="false">
		<cfargument name="file" type="string" required="yes" />
		<cfargument name="hasHeaders" type="boolean" required="no" default="false" /> 

		<cfset var returnArray= ArrayNew(1) />
		<cfset var records = "" />
		<cfset var columns = "" />
		<cfset var row = "" />
		<cfset var i = 1 />
		<cfset var j = 1 />
		<cffile action="read" file="#arguments.file#"  variable="recordTypes" />
		<cfset records = listToArray(recordTypes,chr(13)&chr(10)) />
		<cfif hasHeaders>
			<cfset columns = listToArray(records[1],'","',true) />
			<cfloop from="2" to="#arrayLen(records)#" index="i">
				<cfset row = listToArray(records[i],'","',true) />	
				<cfset returnArray[i-1] = structNew() />
				<cfloop from="1" to="#arrayLen(columns)#" index="j">
					<cfif row[j] EQ 'N'>
						<cfset row[j] = false />
					</cfif>
					<cfif row[j] EQ 'Y'>
						<cfset row[j] = true />
					</cfif>
					<cfset returnArray[i-1][trim(columns[j])] = replace(row[j],'|',',','ALL') />
				</cfloop>
			</cfloop>
		<cfelse>		
			<cfloop from="1" to="#arrayLen(records)#" index="i">
				<cfset row = listToArray(records[i],'","',true) />
				<cfset returnArray[i] = arrayNew(1) />
				<cfloop from="1" to="#arrayLen(row)#" index="j">
					<cfif row[j] EQ 'N'>
						<cfset row[j] = false />
					</cfif>
					<cfif row[j] EQ 'Y'>
						<cfset row[j] = true />
					</cfif>
					<cfset returnArray[i][j] = row[j] />
				</cfloop>
			</cfloop>
		</cfif>
		<cfreturn returnArray />
	</cffunction>

</cfcomponent>
