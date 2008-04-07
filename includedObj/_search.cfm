<cfsetting enablecfoutputonly="true" />
<!--------------------------------------------------------------------
Search Results
 - dmInclude (_search.cfm)
--------------------------------------------------------------------->
<!--- @@displayname: Search Results Page --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets" />
<cfimport taglib="/farcry/plugins/farcryverity/tags/" prefix="verity" />

<!--- config vars --->
<cfparam name="resultsPerPage" default="10" type="numeric" />
<cfparam name="maxResultPages" default="5" type="numeric" />
<cfparam name="maxResults" default="1000" type="numeric" />

<!--- default local vars --->
<cfparam name="thispage" default="1" type="numeric" />
<cfparam name="endpage" default="1" type="numeric" />
<cfparam name="startrow" default="1" type="numeric" />
<cfparam name="endrow" default="1" type="numeric" />
<cfparam name="qResults.recordCount" default="0" type="numeric" />
<cfparam name="stQueryStatus" default="#structNew()#" type="struct" />
<cfparam name="stParam" default="#structNew()#" type="struct" />

<!--- form vars --->
<cfparam name="form.advancedOptions" default="all" type="string" />
<cfparam name="form.criteria" default="" type="string" />
<cfparam name="form.searchOperator" default="" type="string" />

<cfset lAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionList() />
<cfset aAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionArray() />

<!--- setup the collections to search on, this may depend on the form value passed in on the search results page --->
<cfif form.advancedOptions EQ "all">
	<cfset lCollections = lAllCollections />
<cfelse>
	<cfset lCollections = form.advancedOptions />
</cfif>

<!--- inbound parameters defaults --->
<cfif structKeyExists(form,"criteria2")>
	<cfset form.criteria=form.criteria2 />
</cfif>
<cfif structKeyExists(url,"criteria")>
	<cfset form.criteria = url.criteria />
</cfif>
<cfif structKeyExists(url,"searchOperator")>
	<cfset form.searchOperator = url.searchOperator />
</cfif>
<cfif structKeyExists(url,"pg")>
	<cfset thisPage = url.pg />
</cfif>

<cfset searchCriteria = formatCriteria(criteria=form.criteria,searchOperator=form.searchOperator) />

<!--- get serach results --->
<cfif len(searchCriteria)>
	<cfsearch collection="#lCollections#" criteria="#searchCriteria#" name="qResults" maxrows="#maxResults#" suggestions="10" status="stQueryStatus" type="internet" />
	<verity:searchlog status="#stQueryStatus#" type="internet" lcollections="#lCollections#" criteria="#searchCriteria#" />
</cfif>

<!--- default style, should be defined in your main project css file
<style type="text/css">
	/* VERITY PLUGIN - SEARCH RESULTS */

	#vp-searchresult {padding:10px 0px 10px 0px; border-top:1px dotted #DCDCDC;}
	#vp-searchresult span.searchtitle {font-weight:bold; margin:3px 0px 3px 0px;}
	#vp-searchresult span.searchsummary {margin:3px 0px 3px 0px;}
	#vp-searchresult span.searchdate {color:#A9A9A9;}
	#vp-searchresult span.searchlight {color:#A9A9A9;}
	#vp-searchresult span.searchfooter {}

	#vp-searchform {}
	#vp-searchform table {clear:both; padding:5px 5px 5px 5px;line-height:1em;}
	#vp-searchform td {width:33%;}

	#vp-pagination {margin:0px; padding:10px 0px 20px 0px; width:100%;}
	#vp-pagination h4 {font-size:1em;float:right;width:auto; color:#003472;}
	#vp-pagination span {border:1px solid #CCCCCC; color:#999999; display:block; float:left; margin:0px 0px 0px 5px; padding:0pt 4px 0px 4px; text-decoration:none; font-weight:bold;}
	#vp-pagination a:link, #vp-pagination a:visited, #vp-pagination a:active, #vp-pagination a:hover {border:1px solid #CCCCCC; display:block; float:left; margin:0px 0px 0px 5px; padding:0px 4px; text-decoration:none; font-weight:bold;}
	#vp-pagination a:hover {color:#FFFFFF;text-decoration:none;background:#999999;}

</style>
--->

<!--- display search form --->
<cfinclude template="includes/_searchForm.cfm" />

<!--- eval start/end rows --->
<cfset startRow = (thisPage * resultsPerPage) - (resultsPerPage - 1) />
<cfset endPage = ceiling(qResults.recordCount / resultsPerPage) />
<!--- work out the endrow from the above 2 vars and the recordcount --->
<cfif thisPage EQ endPage OR endPage EQ 1>
	<cfset endRow = qResults.recordCount />
<cfelse>
	<cfset endRow = startRow + resultsPerPage - 1 />
</cfif>

<cfif isDefined("qResults") AND qResults.recordCount GT 0>

	<cfif structKeyExists(stQueryStatus, "suggestedQuery")> <!--- display suggestion --->
		<cfoutput>#suggestLink(stQueryStatus.suggestedQuery)#</cfoutput>
	</cfif>

	<cfoutput><p><b>Your search returned <span id="vp-resultsfound">#qResults.recordCount#</span> results.</b></p></cfoutput>

	<!--- display search results --->
	<cfloop query="qResults" startrow="#startrow#" endrow="#endrow#">
		<!--- setup stParam to pass verity vars to webskin --->
		<cfset stParam.searchTerms = replaceList(lcase(searchCriteria)," or , and , not ","|,|,|") />
		<cfset stParam.rank = qResults.rank />
		<cfset stParam.score = qResults.score />
		<cfset stParam.summary = stripHTML(qResults.summary) />
		<cfset stParam.title = qResults.title />
		<cfset stParam.key = qResults.key />
		<!--- create object of result type, render webskin --->
		<cfset oProperty = createObject("component", application.stCoapi[qResults.custom1].packagePath) />
		<cfset stProperty = oProperty.getData(objectID=qResults.key) />
		<cfset searchResultHTML = oProperty.getView(stObject=stProperty, stParam=stParam, template="displaySearchResult") />
		<cfoutput>#searchResultHTML#</cfoutput>
	</cfloop>

	<!--- pagination bottom --->
	<cfif qResults.recordCount GT resultsPerPage>
		<cfset urlParameters = "&objectID=#url.objectID#&criteria=#form.criteria#&searchOperator=#form.searchOperator#" />
		<widgets:paginationDisplay
			QueryRecordCount="#qResults.recordCount#"
			DivStyle="vp-pagination"
			FileName="#cgi.script_name#"
			MaxresultPages="#maxResultPages#"
			MaxRowsAllowed="#resultsPerPage#"
			bEnablePageNumber="true"
			LayoutNumber="4"
			FirstLastPage="numeric"
			Layout_Previous="Previous"
			Layout_Next="Next"
			CurrentPageWrapper_Start="<span>"
			CurrentPageWrapper_End="</span>"
			ExtraURLString="#urlParameters#"
			Layout_preNext="<b>"
			Layout_postNext="</b>"
			Layout_prePrevious="<b>"
			Layout_postPrevious="</b>"
			showCurrentPageDetails=true >
	</cfif>

<cfelse>

	<cfif len(searchCriteria)>
		<cfoutput><p>Your search for "#searchCriteria#" produced no results.</p></cfoutput>
	<cfelse>
		<cfoutput><p>Please enter in a search term above.</p></cfoutput>
	</cfif>
	<cfif structKeyExists(stQueryStatus, "suggestedQuery")> <!--- display suggestion --->
		<cfoutput>#suggestLink(stQueryStatus.suggestedQuery)#</cfoutput>
	</cfif>

</cfif>

<cffunction name="formatCriteria" returntype="string" access="private" description="formats search criteria with verity logic" output="false">
	<cfargument name="criteria" required="true" type="string" />
	<cfargument name="searchOperator" required="true" type="string" />

	<cfset var searchCriteria = "" />

	<!--- check for verity reserved words --->
	<cfif REFindNoCase(" and ", criteria) OR
		REFindNoCase("\Aand ",criteria) OR
		REFindNoCase(" and\Z",criteria) OR
		REFindNoCase(" or ",criteria) OR
		REFindNoCase("\Aor ",criteria) OR
		REFindNoCase(" or\Z",criteria) OR
		REFindNoCase(" not ",criteria) OR
		REFindNoCase("\Anot ",criteria) OR
		REFindNoCase(" not\Z",criteria)>
		<cfset arguments.searchOperator = "custom" />
	</cfif>

	<!--- treat search criteria with appropriate verity operator --->
	<cfswitch expression="#searchOperator#">
		<cfcase value="all">
			<cfset searchCriteria = replaceNoCase(criteria," "," AND ","all") />
		</cfcase>
		<cfcase value="custom">
			<cfset searchCriteria = criteria />
		</cfcase>
		<cfcase value="phrase">
			<cfset searchCriteria = replaceNoCase(criteria," ","<phrase>","all") />
		</cfcase>
		<cfdefaultcase> <!--- treat as ANY --->
			<cfif NOT findNoCase("not",trim(form.criteria))>
				<cfset searchCriteria = replaceNoCase(criteria,",","","all") />
				<cfset searchCriteria = replaceNoCase(criteria," "," OR ","all") />
			<cfelse>
				<cfset searchCriteria = criteria />
			</cfif>
		</cfdefaultcase>
	</cfswitch>

	<cfreturn trim(searchCriteria) />
</cffunction>

<cffunction name="stripHTML" returntype="string" access="private" description="filters out HTML code from summary returned by verity" output="false">
	<cfargument name="summary" required="true" type="string" />

	<cfset var cleanSummary = "" />

	<cfset cleanSummary = REReplace(trim(arguments.summary), "<.*?>", "", "all") />
	<cfset cleanSummary = REReplace(cleanSummary, "<.*?$", "", "all") />
	<cfset cleanSummary = REReplace(cleanSummary, "^.*?>", "", "all") />

	<cfreturn cleanSummary />
</cffunction>

<cffunction name="suggestLink" returntype="string" access="private" description="filters out HTML code from summary returned by verity" output="false">
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
	<cfset request.inHead.PrototypeLite = 1 />

	<cfset suggestHTML = "<p>Did you mean <a href=""##"" onclick=""$('criteria2').value='#suggestedQuery#';$('searchForm').submit();""><em>#suggestedQuery#</em></a> ?</p>" />

	<cfreturn suggestHTML />
</cffunction>

<cfsetting enablecfoutputonly="false" />