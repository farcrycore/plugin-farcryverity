<cfcomponent displayname="Search Form" hint="The search form for searching through the verity index" extends="farcry.core.packages.forms.forms" output="false">
	<cfproperty ftSeq="1" ftFieldset="General" name="criteria" type="string" default="" hint="The search text criteria" ftLabel="Search" />
	<cfproperty ftSeq="2" ftFieldset="General" name="operator" type="string" default="" hint="The operator used for the search" ftLabel="Search Operator" ftType="list" ftList="any:Any of these words,all:All of these words,phrase:These words as a phrase" />
	<cfproperty ftSeq="3" ftFieldset="General" name="lCollections" type="string" default="" hint="The collections to be searched" ftLabel="Collections" ftType="list" ftListData="getCollectionList" />
	
	
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
	
	
	<cffunction name="getSearchResults" access="public" output="false" returntype="struct" hint="Returns a structure containing extensive information of the search results">
		<cfargument name="objectid" required="true" hint="The objectid of the farVeritySearch object containing the details of the search" />
		
		<cfset var stResult = structNew() />
		<cfset var qResults = queryNew("init") />
		<cfset var stObject = getData(objectid="#arguments.objectid#") />
		<cfset var lAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionList() />
		<cfset var aAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionArray() />
		<cfset var lCollectionsToSearch = "" />
		<cfset var searchCriteria = "" />
		
		<cfimport taglib="/farcry/plugins/farcryverity/tags" prefix="verity" />


		<!--- setup the collections to search on, this may depend on the form value passed in on the search results page --->
		<cfif not len(stObject.lCollections) OR stObject.lCollections EQ "all">
			<cfset stResult.lCollectionsToSearch = lAllCollections />
		<cfelse>
			<cfset stResult.lCollectionsToSearch = stObject.lCollections />
		</cfif>
		
		<!--- SETUP THE ACTUAL SEARCH CRITERIA --->
		<cfset stResult.searchCriteria = formatCriteria(criteria=stObject.criteria,searchOperator=stObject.operator) />
		
		<!--- SETUP THE RESULTS --->
		<cfif len(stResult.searchCriteria)>
		
			<cfsearch collection="#stResult.lCollectionsToSearch#" criteria="#stResult.searchCriteria#" name="stResult.qResults" maxrows="1000" suggestions="10" status="stResult.stQueryStatus" type="internet" />
		
			<verity:searchlog status="#stQueryStatus#" type="internet" lcollections="#lCollectionsToSearch#" criteria="#searchCriteria#" />
			
			<cfquery dbtype="query" name="stResult.qResults">
			SELECT *, custom2 AS objectid
			FROM stResult.qResults
			WHERE category = 'file'
			
			UNION
			
			SELECT *, [key] AS objectid
			FROM stResult.qResults
			WHERE category <> 'file'			
			</cfquery>	
			
			<cfquery dbtype="query" name="stResult.qResults">
			SELECT *
			FROM stResult.qResults
			ORDER BY rank
			</cfquery>
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
			<cfoutput><a href="##" onclick="$('searchFormPrefixcriteria').value='#htmlEditFormat(arguments.suggestedQuery)#';btnSubmit('searchForm','Search');"><em>#arguments.suggestedQuery#</em></a></cfoutput>
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
			<cfset summaryHightlightHTML = replaceNoCase(summaryHightlightHTML,i,"<span class='searchhighlight'>#i#</span>", "all") />
		</cfloop>
	
		<cfreturn summaryHightlightHTML />
	</cffunction>
	
</cfcomponent>