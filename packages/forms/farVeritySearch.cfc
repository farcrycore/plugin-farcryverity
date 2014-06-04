<cfcomponent displayname="Search Form" hint="The search form for searching through the verity index" extends="farcry.core.packages.forms.forms" output="false" fualias="search">
	<cfproperty ftSeq="1" ftFieldset="General" name="criteria" type="string" default="" hint="The search text criteria" ftLabel="Search" ftClass="verity-search-criteria" />
	<cfproperty ftSeq="2" ftFieldset="General" name="operator" type="string" default="" hint="The operator used for the search" ftLabel="Search Operator" ftType="list" ftList="any:Any of these words,all:All of these words,phrase:These words as a phrase" />
	<cfproperty ftSeq="3" ftFieldset="General" name="lCollections" type="string" default="" hint="The collections to be searched" ftLabel="Collections" ftType="list" ftListData="getCollectionList" />
	<cfproperty ftSeq="4" ftFieldset="General" name="orderBy" type="string" default="rank" hint="The sort order of the results" ftLabel="Sort Order" ftType="list" ftList="rank:Relevance,custom3 DESC:Date" />
	<cfproperty name="bSearchPerformed" type="boolean" default="false" hint="Will be true if any search has been performed" />
	
	<cffunction name="getCollectionList" access="public" output="false" returntype="string" hint="Returns a list used to populate the lCollections field dropdown selection">
		<cfargument name="objectid" required="true" hint="The objectid of this object" />
		
		<cfset var lResult = ":All Content" />
		<cfset var i = "" />
		<cfset var aAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionArray() />
		
		<cfloop index="i" from="1" to="#arrayLen(aAllCollections)#">
			<cfset lResult = listAppend(lResult, "#aAllCollections[i].collectionname#:#aAllCollections[i].title#") />
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>
	
	<cffunction name="filterResults" access="public" output="false" returntype="query" hint="Allows the developer to add a 2nd filter on the results of the verity search">
		<cfargument name="objectid" required="false" default="" hint="The objectid of this verity search form object" />	
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#" hint="The verity search object" />		
		<cfargument name="qResults" required="true" hint="The initial results of the search" />
		
		<cfreturn arguments.qResults />
		 
		<!--- SEE AN EXAMPLE FILTER BELOW --->
		<!--- 
		<cfset var stVeritySearch = getData(objectid="#arguments.objectid#")>
		<cfset var qFilter = queryNew("blah") />
		<cfset var qFilteredResults = queryNew("blah") />

		
		<cfquery datasource="#application.dsn#" name="qFilter">
		SELECT objectid,startDate
		FROM yafEvent
		WHERE endDate <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		<cfif len(stVeritySearch.eventMonth)>
			AND month(startDate) = <cfqueryparam cfsqltype="cf_sql_integer" value="#stVeritySearch.eventMonth#">
		</cfif>
		</cfquery>

		<cfquery dbtype="query" name="qFilteredResults">
		SELECT *
		FROM arguments.qResults
		WHERE objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valueList(qFilter.objectid)#">
		)
		</cfquery>	


		<cfreturn qFilteredResults />
		 --->
		 
	</cffunction>
</cfcomponent>