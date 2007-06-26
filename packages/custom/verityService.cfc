<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION || 
$Description: verityService Component 
Maintenance object for physical Verity collections
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent displayname="Verity Maintenance" hint="Maintenance object for physical Verity collections.">

<cffunction name="init">
	<cfargument name="path" default="" type="string" hint="Absolute path to Verity collection storage." />
	<cfargument name="chunksize" default="1000" type="numeric" hint="Size of recordsets to update." />
	
	<cfset variables.chunksize = arguments.chunksize />
	
	<!--- determine collection storage path --->
	<cfif NOT len(arguments.path)>
		<cfif structkeyexists(application.stplugins.farcryverity, "verityStoragePath")>
		<!--- server specific collection path set in plugin constant scope --->
			<cfset variables.path = application.stplugins.farcryverity.verityStoragePath />

		<cfelseif structkeyexists(application.path, "verityStoragePath")>
		<!--- deprecated; server specific collection path set in ./config/_serverSpecificVars.cfm --->
			<cfset variables.path = application.path.verityStoragePath />
		
		<cfelseif isDefined("application.config.general.verityStoragePath")>
		<!--- deprecated; collection set in general config --->
			<cfset variables.path = application.config.general.verityStoragePath />
		</cfif>
		
		<cfif NOT len(variables.path)>
		<!--- can't determine a proper path --->
			<cfthrow type="Application" errorcode="plugins.farcryverity.verityservice" message="Collection path not defined." detail="A collection path for verity collections must be defined to use the Verity plugin." />
		</cfif>
	<cfelse>
		<cfset variables.path = arguments.path />
	</cfif>
	
	<cfreturn this />
</cffunction>


<cffunction name="update" output="false">
	<cfargument name="config" required="true" type="struct" />
	
	<cfset var stResult = structNew() />
	<cfset var lcolumns = "objectid,datetimelastupdated" />
	<cfset var prop = "" />
	<cfset var qUpdates=queryNew("blah") />
	<cfset var qSentToDraft=queryNew("objectid") />
	<cfset var qDeleted=queryNew("objectid") />
	<cfset var stConfigProps=structNew() />
	<cfset var oVerityCollection="" />
	
	<!--- required config values --->
	<cfif NOT structkeyexists(arguments.config, "lindexproperties") OR NOT len(arguments.config.lindexproperties)>
		<!--- <cfthrow message="update: lindexproperties not present in config." /> --->
		<cfset arguments.config.lindexproperties="label" />
	</cfif>
	<cfif NOT structkeyexists(arguments.config, "indexTitle") OR NOT len(arguments.config.indexTitle)>
		<!--- <cfthrow message="update: indexTitle not present in config." /> --->
		<cfset arguments.config.indexTitle="label" />
	</cfif>
	<cfif NOT structkeyexists(arguments.config, "builttodate") OR NOT isDate(arguments.config.builttodate)>
		<cfthrow message="update: valid builttodate not present in config." />
	</cfif>
	
	<!--- 
	build update query 
		todo:
			filter for approved status items only (done)
			chunk update (beware CF bug re: maxrows; fixed 7?)
			add custom3 and custom4
			issue: datetimelastupdated records identical on migration (impossible to chunk)
	--->
	<!--- build column list --->
	<cfset lcolumns = listAppend(lColumns, arguments.config.indexTitle) />
	<cfif structkeyexists(arguments.config, "custom3") AND len(arguments.config.custom3)>
		<cfset lcolumns = listAppend(lColumns, arguments.config.custom3) />
	</cfif>
	<cfif structkeyexists(arguments.config, "custom4") AND len(arguments.config.custom4)>
		<cfset lcolumns = listAppend(lColumns, arguments.config.custom4) />
	</cfif>
	<cfloop list="#arguments.config.lindexproperties#" index="prop">
		<cfif NOT listFindNoCase(lColumns, prop)>
			<cfset lcolumns = listAppend(lColumns, prop) />
		</cfif>
	</cfloop>

<!--- 	
	todo: 
	 - move to farVerityCollection so it can be overridden
	 - add check to update method so update method can reside in content type
	 - move verity actions to private methods
--->
	<!--- determine recently updated content items --->
	<cfquery name="qUpdates" datasource="#application.dsn#" maxrows="#variables.chunksize#">
	SELECT
		<!--- define custom fields ---> 
		'#arguments.config.collectiontypename#' AS custom1,
		'reserved for category' AS custom2,
		'#arguments.config.custom3#' AS custom3,
		'#arguments.config.custom4#' AS custom4,
		<!--- standard columns --->
		#lcolumns#
	FROM #arguments.config.collectiontypename#
	WHERE datetimelastupdated > #createodbcdatetime(arguments.config.builttodate)#
	<cfif structkeyexists(application.stcoapi[arguments.config.collectiontypename].stprops, "status")>
		AND status = 'approved'
	</cfif>
	ORDER BY datetimelastupdated
	</cfquery>
	
	<!--- determine content items recently sent to draft --->
	<cfif structkeyexists(application.stcoapi[arguments.config.collectiontypename].stprops, "status")>
		<cfquery name="qSentToDraft" datasource="#application.dsn#">
		SELECT objectid
		FROM #arguments.config.collectiontypename#
		WHERE 
			datetimelastupdated > #createodbcdatetime(arguments.config.builttodate)#
			AND status IN ('draft', 'pending')
		ORDER BY datetimelastupdated
		</cfquery>
	</cfif>	
	
	<!--- determine recently deleted content --->
	<cfquery name="qDeleted" datasource="#application.dsn#">
	SELECT objectid
	FROM fqAudit
	WHERE 
		datetimeStamp > #createodbcdatetime(arguments.config.builttodate)#
		AND auditType = 'delete'
	ORDER BY datetimeStamp
	</cfquery>

	
	<!--- if no results, return immediately --->
	<cfif NOT qUpdates.recordcount AND NOT qSentToDraft.recordcount AND NOT qDeleted.recordcount>
		<cfset stResult.bsuccess="true" />
		<cfset stResult.message= arguments.config.collectionname & " had no records to update." />
		<!--- todo: remove, debug only --->
		<cfset stresult.arguments = arguments />
		<cfset stresult.qUpdates = qUpdates />
		<cfset stresult.qUpdates = qSentToDraft />
		<cfset stresult.qUpdates = qDeleted />
		<cfreturn stresult />
	</cfif>
	
	<!--- update new content items --->
	<cftry>
		<cfset stResult.bsuccess="true" />
		<cfset stResult.message= arguments.config.collectionname & ";  " & qUpdates.recordcount & " record(s) updated." />
		
		<cfindex 
			action="update" 
			collection="#arguments.config.collectionname#" 
			query="qUpdates" 
			key="objectid" 
			title="#arguments.config.indexTitle#" 
			body="#arguments.config.lindexproperties#"
			custom1="custom1"
			custom2="custom2"
			custom3="custom3"
			custom4="custom4"
			type="custom" />
		
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=cfcatch.Message />
		</cfcatch>
	</cftry>

	<!--- remove content sent to draft --->
	<cftry>
		<cfset stResult.bsuccess="true" />
		<cfset stResult.message=stResult.message & " " & arguments.config.collectionname & ";  " & qSentToDraft.recordcount & " record(s) removed." />
		
		<cfindex action="delete" type="custom" query="qSentToDraft" collection ="#arguments.config.collectionname#" key="objectid" />
		
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=stResult.message & " " & cfcatch.Message />
		</cfcatch>
	</cftry>
	
	<!--- remove content deleted --->
	<cftry>
		<cfset stResult.bsuccess="true" />
		<cfset stResult.message=stResult.message & " " & arguments.config.collectionname & ";  " & qDeleted.recordcount & " record(s) deleted." />
		
		<cfindex action="delete" type="custom" query="qDeleted" collection ="#arguments.config.collectionname#" key="objectid" />
		
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=stResult.message & " " & cfcatch.Message />
		</cfcatch>
	</cftry>
	
	<!--- update builttodate if successful --->
	<cfif stResult.bSuccess AND structkeyexists(arguments.config, "objectid")>
		<cfset oVerityCollection=createobject("component", "farcry.plugins.farcryverity.packages.types.farveritycollection") />
		<cfset stConfigProps=oVerityCollection.getData(objectid=arguments.config.objectid) />
		<cfset stConfigProps.builttodate = qUpdates.datetimelastupdated[qUpdates.recordcount] />
		<cfset stresult.builttodate = stConfigProps.builttodate />
		<cfset oVerityCollection.setData(stProperties=stConfigProps) />
	</cfif>
	
	<!--- debug only --->
	<cfset stresult.arguments = arguments />
	<cfset stresult.qUpdates = qUpdates />
	
	<cfreturn stresult />
</cffunction>


<cffunction name="deleteCustom">
	<cfargument name="collection" hint="Name of a collection that is registered by ColdFusion" />
	<cfargument name="key" />
	<cfargument name="query" type="query" />

	<cfindex action="delete" type="custom" query="#arguments.query#" collection ="#arguments.collection#" key="#arguments.key#" />
</cffunction>

<cffunction name="purge">
	<cfargument name="collection" required="true" type="string" />
	<cfset var stresult=structNew() />

	<cfset stresult.bsuccess="true" />
	<cfset stresult.message="#arguments.collection# purged." />
	<cfset stresult.collection=arguments.collection />
	<cfset stresult.path=variables.path />
	
	<cftry>
		<cfindex action="purge" collection="#arguments.collection#" />
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=cfcatch.Message & cfcatch.Detail />
		</cfcatch>
	</cftry>
	
	<cfreturn stResult />
</cffunction>

<cffunction name="refresh">
	<!--- <cfindex action="refresh"> --->
	<cfthrow message="refresh: not quite baked yet." />
</cffunction>

<!----------------------------------------------- 
Gateway
------------------------------------------------>
<cffunction name="getCollections" access="public" output="false" returntype="query" hint="Return application collections.">
	<cfargument name="bActive" default="true" type="boolean" hint="Restrict to active collections only." />
	
	
	
	<cfthrow message="refresh: not quite baked yet." />
</cffunction>

<cffunction name="getCollectionQuery" access="private" returntype="query" output="false" hint="Get all the collections registered for this coldfusion instance, filtered for the application name.">
	<cfset var qReturn=queryNew("CATEGORIES, CHARSET, CREATED, DOCCOUNT, EXTERNAL, LANGUAGE, LASTMODIFIED, MAPPED, NAME, ONLINE, PATH, REGISTERED, SIZE") />
	
	<cfcollection action="list" name="qReturn" />
	
	<!--- filter for the active application name --->
	<cfquery dbtype="query" name="qReturn">
	SELECT CATEGORIES, CHARSET, CREATED, DOCCOUNT, EXTERNAL, LANGUAGE, LASTMODIFIED, MAPPED, NAME, ONLINE, PATH, REGISTERED, SIZE
	FROM qReturn
	WHERE NAME LIKE '#application.ApplicationName#%'
	</cfquery>
	
	<cfreturn qReturn />
	
</cffunction>

<!----------------------------------------------- 
Collection Maintenance
------------------------------------------------>
<cffunction name="createCollection">
	<cfargument name="collection" required="true" type="string" />
	<cfset var stresult=structNew() />

	<cfset stresult.bsuccess="true" />
	<cfset stresult.message="#arguments.collection# created." />
	<cfset stresult.collection=arguments.collection />
	<cfset stresult.path=variables.path />
	
	<cftry>
		<cfcollection action="create" collection="#arguments.collection#" path="#variables.path#" />
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=cfcatch.Message />
		</cfcatch>
	</cftry>
	
	<cfreturn stResult />
</cffunction>

<cffunction name="deleteCollection">
	<cfargument name="collection" required="true" type="string" />
	<cfset var stresult=structNew() />

	<cfset stresult.bsuccess="true" />
	<cfset stresult.message="#arguments.collection# deleted." />
	<cfset stresult.collection=arguments.collection />
	<cfset stresult.path=variables.path />
	
	<cftry>
		<cfcollection action="delete" collection="#arguments.collection#" />
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=cfcatch.Message />
		</cfcatch>
	</cftry>
	
	<cfreturn stResult />
</cffunction>

<cffunction name="optimizeCollection">
	<cfargument name="collection" required="true" type="string" />
	<cfset var stresult=structNew() />

	<cfset stresult.bsuccess="true" />
	<cfset stresult.message="#arguments.collection# optimized." />
	<cfset stresult.collection=arguments.collection />
	<cfset stresult.path=variables.path />
	
	<cftry>
		<cfcollection action="optimize" collection="#arguments.collection#" />
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=cfcatch.Message />
		</cfcatch>
	</cftry>
	
	<cfreturn stResult />
</cffunction>


</cfcomponent>
