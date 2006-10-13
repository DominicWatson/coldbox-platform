<!-----------------------------------------------------------------------Copyright 2005 - 2006 ColdBox Framework by Luis Majanowww.coldboxframework.com | www.coldboxframework.org-------------------------------------------------------------------------author:         paul hastings <paul@sustainableGIS.com>date:           08-december-2003revisions:      15-mar-2005     fixed un-scoped var variable in formatRBString method.                       4-mar-2006      added messageFormat method to                       8-jul-2006 coldbox versionnotes:          the purpose of this CFC is to extract text resources from a pure java resource bundle. these                       resource bundles should be produced by a tools such as IBM's rbManager and consist of:                               key=ANSI escaped string such as                               (english, no need for ANSI escaped chars)                               Cancel=Cancel                               Go=Ok                               (thai, ANSI escaped chars)                               Cancel=\u0E22\u0E01\u0E40\u0E25\u0E34\u0E01                               Go=\u0E44\u0E1Bmethods in this CFC:       - getResourceBundle returns a structure containing all key/messages value pairs in a given resource       bundle file. required argument is rbFile containing absolute path to resource bundle file. optional       argument is rbLocale to indicate which locale's resource bundle to use, defaults to us_EN (american       english). PUBLIC       - getRBKeys returns an array holding all keys in given resource bundle. required argument is rbFile       containing absolute path to resource bundle file. optional argument is rbLocale to indicate which       locale's resource bundle to use, defaults to us_EN (american english). PUBLIC       - getRBString returns string containing the text for a given key in a given resource bundle. required       arguments are rbFile containing absolute path to resource bundle file and rbKey a string holding the       required key. optional argument is rbLocale to indicate which locale's resource bundle to use, defaults       to us_EN (american english). PUBLIC       - formatRBString returns string w/dynamic values substituted. performs messageFormat like       operation on compound rb string: "You owe me {1}. Please pay by {2} or I will be forced to       shoot you with {3} bullets." this function will replace the place holders {1}, etc. with       values from the passed in array (or a single value, if that's all there are). required       arguments are rbString, the string containing the placeholders, and substituteValues either       an array or a single value containing the values to be substituted. note that the values       are substituted sequentially, all {1} placeholders will be substituted using the first       element in substituteValues, {2} with the  second, etc. DEPRECATED. only retained for       backwards compatibility. please use messageFormat method instead.       - messageFormat returns string w/dynamic values substituted. performs MessageFormat       operation on compound rb string.  required arguments: pattern string to use as pattern for       formatting, args array of "objects" to use as substitution values. optional argument is       locale, java style locale       ID, "th_TH", default is "en_US". for details about format       options please see http://java.sun.com/j2se/1.4.2/docs/api/java/text/MessageFormat.html       - verifyPattern verifies MessageFormat pattern. required argument is pattern a string       holding the MessageFormat pattern to test. returns a boolean indicating if the pattern is       ok or not. PUBLICModifications08/20/2006 Luis Majano - Modified for ColdBox-----------------------------------------------------------------------><cfcomponent name="resourceBundle"			 hint="reads and parses java resource bundle per locale: version 1.0.0 coldbox core java 8-jul-2006 paul@sustainableGIS.com"			 extends="coldbox.system.plugin"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<!--- ************************************************************* --->	<cffunction name="init" access="public" returntype="any" hint="Constructor" output="false">		<cfscript>		super.Init();		variables.instance.pluginName = "Resource Bundle";		variables.instance.pluginVersion = "1.0.0 coldbox core java";		variables.instance.pluginDescription = "Java Style Resource Bundles plugin based on Paul Hastings Brain.";		return this;		</cfscript>	</cffunction>	<!--- ************************************************************* ---><!------------------------------------------- PUBLIC ------------------------------------------->	<!--- ************************************************************* --->	<cffunction name="loadBundle" access="public" output="No" hint="Reads,parses and saves the resource bundle per locale in internal ColdBox structures." returntype="void">		<!--- ************************************************************* --->		<cfargument name="rbFile"   required="Yes" type="string" hint="This must be the path + filename UP to but NOT including the locale. We auto-add .properties to the end.">		<cfargument name="rbLocale" required="No"  type="string" default="en_US">		<!--- ************************************************************* --->		<cfscript>		//Place the resource bundle in ColdBox's Storage		setSetting("RBundles.#arguments.rbLocale#",getResourceBundle(arguments.rbFile,arguments.rbLocale));		</cfscript>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="getResourceBundle" access="public" returntype="struct" output="No" hint="Reads,parses and RETURNS a resource bundle in structure format">		<!--- ************************************************************* --->		<cfargument name="rbFile"   required="Yes" type="string" hint="This must be the path + filename UP to but NOT including the locale. We auto-add the local and .properties to the end.">		<cfargument name="rbLocale" required="No"  type="string" default="en_US">		<!--- ************************************************************* --->		<cfscript>		var resourceBundle=structNew();		var thisKEY = "";		var thisMSG = "";		var keys = "";		//Load Instance 		setupInstance();		//<!--- Translate rbFile --->		arguments.rbFile = arguments.rbFile & "_#arguments.rbLocale#.properties";		if ( NOT fileExists(arguments.rbFile) )			throw("Fatal error: resource bundle #arguments.rbFile# not found.","Locale sent: #arguments.rbLocale#","Framework.plugins.resourceBundle.FileNotFoundException");				//Init Stream to read.		instance.fis.init(arguments.rbFile);		//Init RB with file Stream.		instance.rB.init(instance.fis);		//Get Keys		keys=instance.rB.getKeys();		//Loop through Keys and get the elements.		while (keys.hasMoreElements()) {			thisKEY=keys.nextElement();			thisMSG=instance.rB.handleGetObject(thisKEY);			resourceBundle["#thisKEY#"]=thisMSG;		}		instance.fis.close();		return resourceBundle;		</cfscript>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="getResource" access="public" output="true" returnType="any" hint="Returns bundle resource from loaded bundle, if it exists, according to locale. To get a resource string from non loaded RB's, use getRBString">		<!--- ************************************************************* --->		<cfargument name="resource" type="string" required="true" hint="The resource to retrieve from the loaded bundle.">		<!--- ************************************************************* --->		<cfset var Bundle = structNew()>		<cfset var locale = getfwLocale()>		<!--- Check For Bundle in memory --->		<cfif not settingExists("RBundles") or not structKeyExists(getSetting("RBundles"),locale)>			<cfthrow type="Framework.plugins.resourceBundle.BundleNotLoadedException" message="Fatal error when calling getResource(). The resource bundle for locale: #locale# has not been loaded.">		</cfif>		<!--- Get Bundle --->		<cfset Bundle = getSetting("RBundles.#locale#")>		<!--- Check for Key --->		<cfif not structKeyExists(Bundle, arguments.resource)>			<cfreturn "_UNKNOWNTRANSLATION_">		<cfelse>			<cfreturn Bundle[arguments.resource]>		</cfif>			</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="getRBString" access="public" output="No" returntype="string" hint="returns text for given key in given java resource bundle per locale">		<!--- ************************************************************* --->		<cfargument name="rbFile" 	required="Yes" 	type="string" hint="This must be the path + filename UP to but NOT including the locale. We auto-add the local and .properties to the end.">		<cfargument name="rbKey" 	required="Yes" 	type="string" hint="The key to retrieve">		<cfargument name="rbLocale" required="No" 	type="string" default="en_US" hint="The locale of the bundle. Default is en_US">		<!--- ************************************************************* --->		<cfscript>			var rbString=""; // text message to return					//Setup the instance.			setupInstance();				//Check RB File	       	arguments.rbFile = arguments.rbFile & "_#arguments.rbLocale#.properties";			if ( NOT fileExists(arguments.rbFile) )				throw("Fatal error: resource bundle #arguments.rbFile# not found.","Locale sent: #arguments.rbLocale#","Framework.plugins.resourceBundle.FileNotFoundException");			//read file			instance.fis.init(arguments.rbFile);			instance.rB.init(instance.fis);			rbString=instance.rB.handleGetObject(arguments.rbKey);			instance.fis.close();		    if ( len(trim(rbString)) )		    	return rbString;		    else		    	throw("Fatal error: resource bundle #arguments.rbFile# does not contain key #arguments.rbKey#","","Framework.plugins.resourceBundle.RBKeyNotFoundException");	       		</cfscript>		</cffunction>	<!--- ************************************************************* --->	<cffunction name="getRBKeys" access="public" output="No" returntype="array" hint="returns array of keys in java resource bundle per locale">		<!--- ************************************************************* --->		<cfargument name="rbFile" 	required="Yes" 	type="string" hint="This must be the path + filename UP to but NOT including the locale. We auto-add the local and .properties to the end.">		<cfargument name="rbLocale" required="No" 	type="string" default="en_US" hint="The locale to use.">		<!--- ************************************************************* --->		<cfscript>	       	var keys=arrayNew(1); // var to hold rb keys	       	var rbKeys="";	       	//Setup the instance.			setupInstance();	       	//Check RB File	       	arguments.rbFile = arguments.rbFile & "_#arguments.rbLocale#.properties";			if ( NOT fileExists(arguments.rbFile) )				throw("Fatal error: resource bundle #arguments.rbFile# not found.","Locale sent: #arguments.rbLocale#","Framework.plugins.resourceBundle.FileNotFoundException");						//Init Stream to read.			instance.fis.init(arguments.rbFile);			//Init RB with file Stream.			instance.rB.init(instance.fis);			//Get Keys			rbKeys=instance.rB.getKeys();			//Loop through Keys and get the elements.            while (rbKeys.hasMoreElements()) {            	arrayAppend(keys,rbKeys.nextElement());            }            instance.fis.close();            return keys;     	</cfscript>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="formatRBString" access="public" output="no" returnType="string" hint="performs messageFormat like operation on compound rb string">		<!--- ************************************************************* --->		<cfargument name="rbString" 		required="yes" type="string">	    <cfargument name="substituteValues" required="yes" hint="Array or single value to format."> <!--- array or single value to format --->	    <!--- ************************************************************* --->		<cfset var i=0>		<cfset var tmpStr = arguments.rbString>		<cfif isArray(arguments.substituteValues)> <!--- do a bunch? --->	        <cfloop index="i" from="1" to="#arrayLen(arguments.substituteValues)#">	        	<cfset tmpStr=replace(tmpStr,"{#i#}",arguments.substituteValues[i],"ALL")>	        </cfloop>		<cfelse> <!--- do single --->	        <cfset tmpStr=replace(tmpStr,"{1}",arguments.substituteValues,"ALL")>		</cfif> <!--- do a bunch? --->		<cfreturn tmpStr>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="messageFormat" access="public" output="no" returnType="string" hint="performs messageFormat on compound rb string">		<!--- ************************************************************* --->		<cfargument name="thisPattern" 	required="yes" type="string" hint="pattern to use in formatting">		<cfargument name="args" 		required="yes" hint="substitution values"> <!--- array or single value to format --->		<cfargument name="thisLocale" 	required="no"  default="en_US" hint="locale to use in formatting, defaults to en_US">		<!--- ************************************************************* --->		<cfset var pattern=createObject("java","java.util.regex.Pattern")>		<cfset var regexStr="(\{[0-9]{1,},number.*?\})">		<cfset var p="">		<cfset var m="">		<cfset var i=0>		<cfset var thisFormat="">		<cfset var inputArgs=arguments.args>		<cfset var lang="">		<cfset var country="">		<cfset var variant="">		<cfset var tLocale="">		<!--- Setup the instance --->		<cfset setupInstance()>		<cftry>	        <cfset lang=listFirst(arguments.thisLocale,"_")>	        <cfset country=listGetAt(arguments.thisLocale,2,"_")>	        <cfset variant=listLast(arguments.thisLocale,"_")>	        <cfset tLocale=instance.locale.init(lang,country,variant)>	        <cfif NOT isArray(inputArgs)>	        	<cfset inputArgs=listToArray(inputArgs)>	        </cfif>	        <cfset thisFormat=instance.msgFormat.init(arguments.thisPattern,tLocale)>	        <!--- let's make sure any cf numerics are cast to java datatypes --->	        <cfset p=pattern.compile(regexStr,pattern.CASE_INSENSITIVE)>	        <cfset m=p.matcher(arguments.thisPattern)>	        <cfloop condition="#m.find()#">                <cfset i=listFirst(replace(m.group(),"{",""))>                <cfset inputArgs[i]=javacast("float",inputArgs[i])>	        </cfloop>	        <cfset arrayPrepend(inputArgs,"")> <!--- dummy element to fool java --->	        <!--- coerece to a java array of objects  --->	        <cfreturn thisFormat.format(inputArgs.toArray())>	        <cfcatch type="Any">	              <cfthrow message="#cfcatch.message#" type="Framework.plugins.resourceBundle" detail="#cfcatch.detail#">	        </cfcatch>		</cftry>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="verifyPattern" access="public" output="no" returnType="boolean" hint="performs verification on MessageFormat pattern">    	<!--- ************************************************************* --->		<cfargument name="pattern" required="yes" type="string" hint="format pattern to test">		<!--- ************************************************************* --->		<cfscript>	        var test="";	        var isOK=true;	        //Setup the instance.			setupInstance();	        try {	        	test=instance.msgFormat.init(arguments.pattern);	        }	        catch (Any e) {	            isOK=false;	        }	        return isOk;		</cfscript>	</cffunction>	<!--- ************************************************************* --->		<!--- ************************************************************* --->	<cffunction name="getVersion" access="public" output="false" returntype="struct" hint=" returns version of this CFC and java lib it uses.">		<cfset var version=StructNew()>		<cfset var sys=createObject("java","java.lang.System")>		<cfset version.ResourceBundleVersion=instance.pluginVersion>		<cfset version.ResourceBundleDate=instance.ResourceBundleDate>		<cfset version.javaRuntimeVersion=sys.getProperty("java.runtime.version")>		<cfset version.javaVersion=sys.getProperty("java.version")>		<cfreturn version>	</cffunction>	<!--- ************************************************************* --->		<!------------------------------------------- PRIVATE ------------------------------------------->		<!--- ************************************************************* --->	<cffunction name="setupInstance" access="private" output="false" returntype="void" hint="Sets up the instance objects for usage. Pulled from init for performance.">		<cfscript>		//<!--- This plugin's properties --->		instance.rB=createObject("java", "java.util.PropertyResourceBundle");        instance.fis=createObject("java", "java.io.FileInputStream");        instance.msgFormat=createObject("java", "java.text.MessageFormat");        instance.locale=createObject("java","java.util.Locale");        instance.ResourceBundleDate="23-aug-2006"; //should be date of latest change        </cfscript>	</cffunction>	<!--- ************************************************************* --->	</cfcomponent>