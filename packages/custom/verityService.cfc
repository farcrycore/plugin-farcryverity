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
        <cfargument name="verityConfig" hint="verity config object" />

        <cfset variables.chunksize = arguments.chunksize />

        <cfif not structkeyexists(arguments,"verityConfig") and isdefined("application.stplugins.farcryverity.oVerityConfig")>
              <cfset variables.oVerityConfig=application.stplugins.farcryverity.oVerityConfig>
        </cfif>

        <!--- server specific collection path set in plugin constant scope --->
        <cfif NOT len(arguments.path) and structkeyexists(variables,"oVerityConfig")>
                <cfset variables.path = variables.oVerityConfig.getStoragePath() />
        <cfelseif len(arguments.path)>
                <cfset variables.path = arguments.path />
        </cfif>

        <!--- backward compatability; collection storage path --->                                                                                                                                                                             
        <cfif not structkeyexists(variables,"path") or NOT len(variables.path)>                                                                                                                                                               
                <cfif structkeyexists(application.path, "verityStoragePath")>
                <!--- deprecated; server specific collection path set in ./config/_serverSpecificVars.cfm --->
                        <cfset variables.path = application.path.verityStoragePath />

                <cfelseif isDefined("application.config.general.verityStoragePath")>
                <!--- deprecated; collection set in general config --->
                        <cfset variables.path = application.config.general.verityStoragePath />
                </cfif>
        </cfif>

        <cfif not structkeyexists(variables,"path") or NOT len(variables.path)>
        <!--- can't determine a proper path --->
                <cfthrow type="Application" errorcode="plugins.farcryverity.verityService" message="Collection path not defined." detail="A collection path for verity collections must be defined to use the Verity plugin." />
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
	<cfset var baseFilepath="" />
	<cfset var oType="" />
	
	<cfsetting requesttimeout="10000">
	
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
		<cfif NOT listFindNoCase(lColumns, arguments.config.custom4)>
			<cfset lcolumns = listAppend(lColumns, arguments.config.custom4) />
		</cfif>
	</cfif>
	<cfloop list="#arguments.config.lindexproperties#" index="prop">
		<cfif NOT listFindNoCase(lColumns, prop)>
			<cfset lcolumns = listAppend(lColumns, prop) />
		</cfif>
	</cfloop>
	
	
	<cfif arguments.config.collectionType EQ "file" AND len(arguments.config.fileproperty)>
		<cfif NOT listFindNoCase(lColumns, arguments.config.fileproperty)>
			<cfset lcolumns = listAppend(lColumns, arguments.config.fileproperty) />
		</cfif>
	</cfif>

<!--- 	
	todo: 
	 - move to farVerityCollection so it can be overridden
	 - add check to update method so update method can reside in content type
	 - move verity actions to private methods
	 - add dbowner requirements
--->
	
	<!--- ALLOW THE DEVELOPER TO CREATE A CUSTOM QUERY FOR THE CONTENT THEY WANT TO INDEX --->
	<cfset oType = createObject("component", application.stcoapi["#arguments.config.collectiontypename#"].packagePath) />
	<cfif structKeyExists(oType,"#arguments.config.contentToIndexFunction#")>
		<cfinvoke component="#oType#" method="#arguments.config.contentToIndexFunction#" returnvariable="qContentToIndex">
			<cfinvokeargument name="config" value="#arguments.config#">
		</cfinvoke>
	<cfelse>
		<!--- OTHERWISE GET ALL CONTENT --->
		<cfquery name="qContentToIndex" datasource="#application.dsn#">
		SELECT objectID
		FROM #arguments.config.collectiontypename#
		<cfif structkeyexists(application.stcoapi[arguments.config.collectiontypename].stprops, "status")>
		where status = 'approved'
		</cfif>
		</cfquery>
	</cfif>

	<!--- determine recently updated content items --->
	<cfquery datasource="#application.dsn#" name="qAllContent">
	SELECT 	objectid,
			#lcolumns#,
			<!--- define custom fields ---> 
			'#arguments.config.collectiontypename#' AS custom1,
			<cfif arguments.config.collectionType EQ "file" AND len(arguments.config.fileproperty)>
				<!--- CUSTOM2 IS RESERVED IN file --->
				<cfif len(arguments.config.fileproperty)>objectid<cfelse>''</cfif> AS custom2,
			<cfelse>
				'reserved for category' AS custom2,
			</cfif>		
			
			<cfif len(arguments.config.custom3)>#arguments.config.custom3#<cfelse>''</cfif> AS custom3,
			<cfif len(arguments.config.custom4)>#arguments.config.custom4#<cfelse>''</cfif> AS custom4,
			<!--- standard columns --->			
			datetimelastupdated

	FROM #arguments.config.collectiontypename#
	WHERE datetimelastupdated > #createodbcdatetime(arguments.config.builttodate)#
	<cfif structkeyexists(application.stcoapi[arguments.config.collectiontypename].stprops, "status")>
		AND status = 'approved'
	</cfif>
	</cfquery>
	
	<!--- JOIN CUSTOM QUERY AND THE COLUMNS DEFINED BY THE CONFIG --->
	<cfquery name="qUpdates" dbType="query" maxrows="#variables.chunksize#">
	SELECT qAllContent.*
	FROM qContentToIndex, qAllContent
	WHERE qContentToIndex.objectid = qAllContent.objectid
	ORDER BY qAllContent.datetimelastupdated
	</cfquery>

	<cfif listlen(arguments.config.CATCOLLECTION)>
		<cfset oCat = createObject("component", "farcry.core.packages.types.category") />
		<cfset qCat = oCat.getDataQuery(lCategoryIDs="#arguments.config.CATCOLLECTION#"
			,typename="#arguments.config.collectiontypename#"
			,bMatchAll="0"
			) />
			
		<cfif qCat.recordCount>
			<cfquery dbtype="query" name="qUpdates">
			SELECT qUpdates.*
			FROM qUpdates, qCat
			WHERE qUpdates.objectid = qCat.objectid
			ORDER BY qUpdates.datetimelastupdated
			</cfquery>
		</cfif>
		
	</cfif>
	
	
	
	


	
	<!--- if no results, return immediately --->
	<!---<cfif NOT qUpdates.recordcount AND NOT qSentToDraft.recordcount AND NOT qDeleted.recordcount>
		<cfset stResult.bsuccess="true" />
		<cfset stResult.message= arguments.config.collectionname & " had no records to update." />
		<!--- todo: remove, debug only --->
		<cfset stresult.arguments = arguments />
		<cfset stresult.qUpdates = qUpdates />
		<cfset stresult.qUpdates = qSentToDraft />
		<cfset stresult.qUpdates = qDeleted />
		<cfreturn stresult />
	</cfif>--->
	
	
	<!--- Return ALL objects currently in the collection. To be used by the deleting process. --->
	<cfsearch collection="#arguments.config.collectionname#" name="qAllCurrentlyIndexed" />
	

	<cfswitch expression="#arguments.config.collectionType#">

		<cfcase value="file">
			<cftry>
				<cfset stResult.bsuccess="true" />
				<cfset stResult.message= arguments.config.collectionname & ";  " & qUpdates.recordcount & " record(s) updated." />
				
				<cfif structKeyExists(application.stcoapi[arguments.config.collectionTypename].stprops[arguments.config.fileproperty].metadata, "ftSecure")
					AND application.types[arguments.config.collectionTypename].stprops[arguments.config.fileproperty].metadata.ftSecure>
					
					<cfset baseFilepath = application.path.secureFilePath />
				<cfelse>
					<cfset baseFilepath = application.path.defaultFilePath />
				</cfif>
						
				<cfloop query="qUpdates">
					<cfset fullFilePath = "#baseFilepath##qUpdates[arguments.config.fileproperty][qUpdates.currentRow]#" />
					<cfif fileExists(fullFilePath)>
						<cfindex 
							action="update" 
							collection="#arguments.config.collectionname#" 
							key="#fullFilePath#" 
							custom1="#qUpdates.custom1#"
							custom2="#qUpdates.custom2#"
							custom3="#qUpdates.custom3#"
							custom4="#qUpdates.custom4#"
							type="file"
							extensions="*.*"
							category="file"
						 	urlpath="#qUpdates.objectid#" >
					</cfif>
				</cfloop>
				
				
				<!--- Determine which objects are in the collection which should no longer be. --->
				<cfquery name="qToDelete" dbtype="query">
				<cfif application.dbType NEQ "mysql">
					select qAllCurrentlyIndexed.[key]
				</cfif>
				<cfif application.dbType EQ "mysql">
					select qAllCurrentlyIndexed.key
				</cfif>
				from qAllCurrentlyIndexed
				where qAllCurrentlyIndexed.custom2 NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valueList(qContentToIndex.objectid)#">)
				</cfquery>
				
				<cfif qToDelete.recordCount>
					<cfindex action="delete" type="custom" query="qToDelete" collection ="#arguments.config.collectionname#" key="key" />
					<cfset stResult.message = "#stResult.message#; #qToDelete.recordCount# record(s) deleted." />
				</cfif>
				
				<cfcatch>
					<cfset stResult.bsuccess="false" />
					<cfset stResult.message=cfcatch.Message />
				</cfcatch>
			</cftry>
			
		</cfcase>
		
		<cfdefaultcase>
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
				type="custom"
				category="custom"   />
			
		
			<!--- Determine which objects are in the collection which should no longer be. --->
			<cfquery name="qToDelete" dbtype="query">
			<cfif application.dbType NEQ "mysql">
				select qAllCurrentlyIndexed.[key]
				from qAllCurrentlyIndexed
				where qAllCurrentlyIndexed.[key] NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valueList(qContentToIndex.objectid)#">)
			</cfif>
			<cfif application.dbType EQ "mysql">
				select qAllCurrentlyIndexed.key
				from qAllCurrentlyIndexed
				where qAllCurrentlyIndexed.key NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valueList(qContentToIndex.objectid)#">)
			</cfif>
			</cfquery>
				
			<cfif qToDelete.recordCount>
				<cfindex action="delete" type="custom" query="qToDelete" collection ="#arguments.config.collectionname#" key="key" />
				<cfset stResult.message = "#stResult.message#; #qToDelete.recordCount# record(s) deleted." />
			</cfif>
			<cfcatch>
				<cfset stResult.bsuccess="false" />
				<cfset stResult.message=cfcatch.Message />
			</cfcatch>
			</cftry>
		</cfdefaultcase>
	</cfswitch>

	

	
	<!--- update builttodate if successful --->
	<cfif stResult.bSuccess AND structkeyexists(arguments.config, "objectid") and qUpdates.recordcount>
		<cfset oVerityCollection=createobject("component", "farcry.plugins.farcryverity.packages.types.farVerityCollection") />
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
	
	<!--- todo: add params to filter return --->
	<cfreturn getCollectionQuery() />
	
	
</cffunction>

<cffunction name="getCollectionQuery" access="private" returntype="query" output="false" hint="Get all the collections registered for this coldfusion instance, filtered for the application name.">
	<cfset var qReturn=queryNew("CATEGORIES, CHARSET, CREATED, DOCCOUNT, LASTMODIFIED, MAPPED, NAME, ONLINE, PATH, REGISTERED, SIZE") />
	
	<cfcollection action="list" name="qReturn" />
	
	<!--- filter for the active application name --->
	<cfquery dbtype="query" name="qReturn">
	SELECT CATEGORIES, CHARSET, CREATED, DOCCOUNT, LASTMODIFIED, MAPPED, NAME, ONLINE, PATH, REGISTERED, SIZE
	FROM qReturn
	WHERE NAME LIKE '#variables.oVerityConfig.getCollectionPrefix()#%'
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
		<cfcollection action="create" collection="#arguments.collection#" path="#variables.path#" categories="true" />
		<cfcatch>
			<cfset stResult.bsuccess="false" />
			<cfset stResult.message=cfcatch.Message />
			<cfabort showerror="#cfcatch.Message#" />
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


	
	<cffunction name="getSearchResults" access="public" output="false" returntype="struct" hint="Returns a structure containing extensive information of the search results">
		<cfargument name="objectid" required="true" hint="The objectid of the farVeritySearch object containing the details of the search" />
		<cfargument name="typename" required="false" default="farVeritySearch" hint="The verity search form type used to control the search.">
		<cfargument name="maxrows" required="false" default="1000" hint="The maximum results we want returned from the verity search">
		<cfargument name="suggestions" required="false" default="10" hint="The maximum alternate search string suggestions we want returned from the verity search.">
		
		<cfset var stResult = structNew() />
		<cfset var qResults = queryNew("init") />
		<cfset var oSearchForm = createObject("component", application.stcoapi["#arguments.typename#"].packagePath) />
		<cfset var stSearchForm = oSearchForm.getData(objectid="#arguments.objectid#") />
		<cfset var lAllCollections = variables.oVerityConfig.getCollectionList() />
		<cfset var aAllCollections = variables.oVerityConfig.getCollectionArray() />
		<cfset var lCollectionsToSearch = "" />
		<cfset var searchCriteria = "" />
		
		<cfimport taglib="/farcry/plugins/farcryverity/tags" prefix="verity" />


		<!--- setup the collections to search on, this may depend on the form value passed in on the search results page --->
		<cfif not len(stSearchForm.lCollections) OR stSearchForm.lCollections EQ "all">
			<cfset stResult.lCollectionsToSearch = lAllCollections />
		<cfelse>
			<cfset stResult.lCollectionsToSearch = stSearchForm.lCollections />
		</cfif>
	
		<!--- SETUP THE ACTUAL SEARCH CRITERIA --->
		<cfset stResult.searchCriteria = formatCriteria(criteria=stSearchForm.criteria,searchOperator=stSearchForm.operator) />
		
		<cfif isValid("boolean",stSearchForm.bSearchPerformed) AND stSearchForm.bSearchPerformed>
			<cfset stResult.bSearchPerformed = true />
		<cfelse>
			<cfset stResult.bSearchPerformed = false />
		</cfif>

		<!--- SETUP THE RESULTS --->
		<cfif stResult.bSearchPerformed AND listLen(stResult.lCollectionsToSearch)>
			
			<cfsearch collection="#stResult.lCollectionsToSearch#" criteria="#stResult.searchCriteria#" name="stResult.qResults" maxrows="#arguments.maxrows#" suggestions="#arguments.suggestions#" status="stResult.stQueryStatus" type="internet" />
		
			<!--- de-dupe the results. Technically this should never be needed but we have found verity for some reason is allowing duplicate keys at times! --->
			<cfquery name="stResult.qResults" dbtype="query">
			<cfif application.dbType NEQ "mysql">
				SELECT 	max([key]) as [key], max(title) as title, max(custom1) as custom1, max(custom2) as custom2, max(custom3) as custom3, max(custom4) as custom4, max(rank) as rank, max(score) as score, max(summary) as summary
						,max(AUTHOR) as author, max(category) as category, max(categorytree) as categorytree, max(context) as context, max(size) as size, max(type) as type, max(url) as url
				FROM stResult.qResults
				group by [key]
				order by rank
			</cfif>
			<cfif application.dbType EQ "mysql">
				SELECT 	max(key) as key, max(title) as title, max(custom1) as custom1, max(custom2) as custom2, max(custom3) as custom3, max(custom4) as custom4, max(rank) as rank, max(score) as score, max(summary) as summary
						,max(AUTHOR) as author, max(category) as category, max(categorytree) as categorytree, max(context) as context, max(size) as size, max(type) as type, max(url) as url
				FROM stResult.qResults
				group by key
				order by rank
			</cfif>
			</cfquery>

		
			<verity:searchLog status="#stResult.stQueryStatus#" type="internet" lcollections="#lCollectionsToSearch#" criteria="#stResult.searchCriteria#" />
			
			<cfquery dbtype="query" name="stResult.qResults">
			SELECT *, custom2 AS objectid
			FROM stResult.qResults
			WHERE cast(category as varchar) = 'file'
			
			UNION
			
			<cfif application.dbType NEQ "mysql">
				SELECT *, [key] AS objectid
			</cfif>
			<cfif application.dbType EQ "mysql">
				SELECT *, key AS objectid
			</cfif>
			FROM stResult.qResults
			WHERE cast(category as varchar) <> 'file'			
			</cfquery>	
			
			
			
			<!--- Sort the results --->
			<cfif stSearchForm.orderby neq "RANK">
				<cfquery dbtype="query" name="stResult.qResults">
				SELECT *
				FROM stResult.qResults
				ORDER BY #stSearchForm.orderby#
				</cfquery>
			<cfelse>
				<cfquery dbtype="query" name="stResult.qResults">
				SELECT *
				FROM stResult.qResults
				ORDER BY rank
				</cfquery>
			</cfif>
			
			
			<cfinvoke component="#oSearchForm#" returnvariable="stResult.qResults" method="filterResults">
				<cfinvokeargument name="objectid" value="#stSearchForm.objectid#" />
				<cfinvokeargument name="qResults" value="#stResult.qResults#" />
			</cfinvoke>


		<cfelse>
			<cfset stResult.qResults = queryNew("init") />
		</cfif>


		<cfset stResult.suggestLink = "" />
		<cfif stResult.qResults.recordCount GT 0>
			<cfif structKeyExists(stResult.stQueryStatus, "suggestedQuery")> <!--- display suggestion --->
				<cfset stResult.suggestLink = suggestLink(suggestedQuery="#stResult.stQueryStatus.suggestedQuery#") />
			</cfif>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
<cffunction name="search" access="public" output="false" returntype="struct" hint="Returns a structure containing extensive information of the search results">
		<cfargument name="criteria" required="true" default="" hint="The verity search criteria">
		<cfargument name="lcollections" required="false" default="all" hint="The list of collections to be searched" />
		<cfargument name="previousCriteria" required="false" default="" hint="Optional Previous criteria">
		<cfargument name="maxrows" required="false" default="1000" hint="The maximum results we want returned from the verity search">
		<cfargument name="suggestions" required="false" default="10" hint="The maximum alternate search string suggestions we want returned from the verity search.">
		<cfargument name="operator" required="false" default="" hint="The verity search operator">
		<cfargument name="orderby" required="false" default="rank" hint="The order by field">
		
		<cfset var stResult = structNew() />
		<cfset var qResults = queryNew("init") />
		<cfset var lAllCollections = variables.oVerityConfig.getCollectionList() />
		
		<cfimport taglib="/farcry/plugins/farcryverity/tags" prefix="verity" />


		<!--- setup the collections to search on, this may depend on the form value passed in on the search results page --->
		<cfif not len(arguments.lCollections) OR arguments.lCollections EQ "all">
			<cfset stResult.lCollectionsToSearch = lAllCollections />
		<cfelse>
			<cfset stResult.lCollectionsToSearch = arguments.lCollections />
		</cfif>
	
		<!--- SETUP THE ACTUAL SEARCH CRITERIA --->
		<cfset stResult.searchCriteria = formatCriteria(criteria=arguments.criteria,searchOperator=arguments.operator) />
			
		<cfsearch collection="#stResult.lCollectionsToSearch#" criteria="#stResult.searchCriteria#" name="stResult.qResults" maxrows="#arguments.maxrows#" suggestions="#arguments.suggestions#" status="stResult.stQueryStatus" type="internet" />
		
		<verity:searchLog status="#stResult.stQueryStatus#" type="internet" lcollections="#stResult.lCollectionsToSearch#" criteria="#stResult.searchCriteria#" />
			
			<cfquery dbtype="query" name="stResult.qResults">
			SELECT *, custom2 AS objectid
			FROM stResult.qResults
			WHERE category = 'file'
			
			UNION
			
			<cfif application.dbType NEQ "mysql">
				SELECT *, [key] AS objectid
			</cfif>
			<cfif application.dbType EQ "mysql">
				SELECT *, key AS objectid
			</cfif>
			FROM stResult.qResults
			WHERE category <> 'file'			
			</cfquery>	
			
			<!--- Sort the results --->
			<cfif arguments.orderby neq "RANK">
				<cfquery dbtype="query" name="stResult.qResults">
				SELECT *
				FROM stResult.qResults
				ORDER BY #arguments.orderby#
				</cfquery>
			<cfelse>
				<cfquery dbtype="query" name="stResult.qResults">
				SELECT *
				FROM stResult.qResults
				ORDER BY rank
				</cfquery>
			</cfif>
			
			



	
		
		<cfreturn stResult />
	</cffunction>	 
	

	
	<cffunction name="formatCriteria" returntype="string" access="private" description="formats search criteria with verity logic" output="false">
		<cfargument name="criteria" required="true" type="string" />
		<cfargument name="searchOperator" required="true" type="string" />
	
		<cfset var searchCriteria = "" />
		<cfset arguments.criteria = trim(criteria) />
		
		<!--- check for verity reserved words --->
		<cfif REFindNoCase(" and ", arguments.criteria) OR
			REFindNoCase("\Aand ",arguments.criteria) OR
			REFindNoCase(" and\Z",arguments.criteria) OR
			REFindNoCase(" or ",arguments.criteria) OR
			REFindNoCase("\Aor ",arguments.criteria) OR
			REFindNoCase(" or\Z",arguments.criteria) OR
			REFindNoCase(" not ",arguments.criteria) OR
			REFindNoCase("\Anot ",arguments.criteria) OR
			REFindNoCase(" not\Z",arguments.criteria) OR
			FindNoCase("""", arguments.criteria ) OR
			FindNoCase("''", arguments.criteria )>
			<cfset arguments.searchOperator = "custom" />
		</cfif>
	
		<!--- treat search criteria with appropriate verity operator --->
		<cfswitch expression="#searchOperator#">
			<cfcase value="all">
				<cfset searchCriteria = replaceNoCase(arguments.criteria," "," AND ","all") />
			</cfcase>
			<cfcase value="custom">
				<cfset searchCriteria = arguments.criteria />
			</cfcase>
			<cfcase value="phrase">
				<cfset searchCriteria = """#arguments.criteria#""">
			</cfcase>
			<cfdefaultcase> <!--- treat as ANY --->
				<cfif NOT findNoCase("not",trim(arguments.criteria))>
					<cfset searchCriteria = replaceNoCase(arguments.criteria,",","","all") />
					<cfset searchCriteria = replaceNoCase(arguments.criteria," "," OR ","all") />
				<cfelse>
					<cfset searchCriteria = arguments.criteria />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
	
		<cfreturn trim(searchCriteria) />
	</cffunction>
	
	<cffunction name="stripHTML" returntype="string" access="public" description="filters out HTML code from summary returned by verity" output="false">
		<cfargument name="summary" required="true" type="string" />
	
		<cfset var cleanSummary = "" />
	
		<cfset cleanSummary = REReplace(trim(arguments.summary), "<.*?>", "", "all") />
		<cfset cleanSummary = REReplace(cleanSummary, "<.*?$", "", "all") />
		<cfset cleanSummary = REReplace(cleanSummary, "^.*?>", "", "all") />
	
		<cfreturn cleanSummary />
	</cffunction>
	
	<cffunction name="suggestLink" returntype="string" access="public" description="filters out HTML code from summary returned by verity" output="false">
		<cfargument name="suggestedQuery" required="true" type="string" />
	
		<cfset var suggestHTML = "" />
	
		<cfif REFindNoCase(" and ", suggestedQuery) OR
			REFindNoCase("\Aand ",suggestedQuery) OR
			REFindNoCase(" and\Z",suggestedQuery) OR
			REFindNoCase(" or ",suggestedQuery) OR
			REFindNoCase("\Aor ",suggestedQuery) OR
			REFindNoCase(" or\Z",suggestedQuery) OR
			REFindNoCase(" not ",suggestedQuery) OR
			REFindNoCase("\Anot ",suggestedQuery) OR
			REFindNoCase(" not\Z",suggestedQuery)>
			<cfset suggestedQuery = replaceList(lCase(suggestedQuery)," and , or , not ", " , , ") />
		</cfif>
		
		<skin:htmlHead library="extCoreJS">
	
		<cfsavecontent variable="suggestHTML">
			<cfoutput><a href="##" onclick="btnClick('#Request.farcryForm.Name#','Search');f=Ext.query('###request.farcryForm.name# .verity-search-criteria');for(var i=0; i<f.length; i++){f[i].value='#htmlEditFormat(arguments.suggestedQuery)#';};#request.farcryForm.onSubmit#;btnSubmit('#request.farcryForm.name#','Search');"><em>#arguments.suggestedQuery#</em></a></cfoutput>
		</cfsavecontent>		
	
		<cfreturn suggestHTML />
	</cffunction>
	
	<cffunction name="highlightSummary" returntype="string" access="public" description="wraps span highlight class around matching terms in summary" output="false">
		<cfargument name="searchCriteria" required="true" type="string" />
		<cfargument name="summary" required="true" type="string" />
	
		<cfset var summaryHightlightHTML = "#summary#" />
		<cfset var searchTerms = replaceList(lcase(arguments.searchCriteria)," or , and , not ","|,|,|") />
	
		<!--- highlight matches --->
		<cfloop list="#searchTerms#" delimiters="|" index="i">
			<cfset summaryHightlightHTML = replaceNoCase(summaryHightlightHTML,i,"<span class='search-highlight'>#i#</span>", "all") />
		</cfloop>
	
		<cfreturn summaryHightlightHTML />
	</cffunction>
	
</cfcomponent>
