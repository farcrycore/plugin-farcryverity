<cfsetting enablecfoutputonly="true" />
<!--------------------------------------------------------------------
Search Results
 - dmInclude (_search.cfm)
--------------------------------------------------------------------->
<!--- @@displayname: Search Results Page --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets" /> 
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" /> 
<cfimport taglib="/farcry/plugins/farcryverity/tags/" prefix="verity" /> 

<!--- default local vars --->
<cfparam name="thispage" default="1">
<cfparam name="endpage" default="1">
<cfparam name="startrow" default="1">
<cfparam name="endrow" default="1">


<cfset lAllCollections = application.stplugins.farcryverity.oVerityConfig.getCollectionList() />
<cfset aAllCollections = application.stplugins.farcryverity.oVerityConfig.getCollectionArray() />

<cfoutput>
<style type="text/css">
	 
	##pagination {background: ##f2f2f2;color:##666;padding: 4px 2px 4px 7px;border: 1px solid ##ddd;margin: 5px 0px 5px 0px;}
	##pagination {position:relative;text-align:right}
	##pagination a:link, ##pagination a:visited, ##pagination a:hover, ##pagination a:active {text-decoration:none;background:##fff;color:##333;padding:2px 5px;border: 1px solid ##ccc}
	##pagination a:hover {background:##aaa;color:##fff}
	##pagination span {text-decoration:none;background:##fff;padding:2px 5px;border: 1px solid ##ccc;color:##ccc}
	##pagination h4 {float:left;margin:0px;}

</style>
</cfoutput>

<cfparam name="form.advancedOptions" default="" />

<cfset lCollections = "" />
<!--- setup the collections to search on, this may depend on the form value passed in on the search results page --->
<cfif form.advancedOptions EQ "" OR form.advancedOptions EQ "all">
	<cfset lCollections = lAllCollections />
<cfelse>
	<cfset lCollections = form.advancedOptions />
</cfif>

<!--- <cfparam name = "form.collection" default="#lCollections#"> --->

<!--- inbound parameters defaults --->
<cfparam name="form.criteria" default="">
<cfif IsDefined("form.criteria2")>
	<cfset form.criteria=form.criteria2>
</cfif>
<cfparam name="form.searchOperator" default="">

<!--- check if called from x page in results --->
<cfif isdefined("url.criteria")>
	<cfset form.criteria = url.criteria>
</cfif>
<cfif isdefined("url.searchOperator")>
	<cfset form.searchOperator = url.searchOperator>
</cfif>

<!--- check for verity reserved words --->
<cfif 	REFindNoCase(" and ", form.criteria)OR
	REFindNoCase("\Aand ",form.criteria)OR
	REFindNoCase(" and\Z",form.criteria)OR
	REFindNoCase(" or ",form.criteria)OR
	REFindNoCase("\Aor ",form.criteria)OR
	REFindNoCase(" or\Z",form.criteria)OR
	REFindNoCase(" not ",form.criteria)OR
	REFindNoCase("\Anot ",form.criteria)OR
	REFindNoCase(" not\Z",form.criteria)>
	<cfset form.searchOperator =  "CUSTOM">
</cfif>

<!--- treat search criteria with appropriate Verity operator --->
<cfswitch expression="#form.searchOperator#">
	<cfcase value="ALL">
		<cfset SearchCriteria = replacenocase(trim(form.criteria), " ", " AND ", "ALL")>
	</cfcase>
	<cfcase value="Custom">
		<cfset SearchCriteria = trim(form.criteria)>
	</cfcase>
	<cfcase value="PHRASE">
		<cfset SearchCriteria = replacenocase(trim(form.criteria), " ", "<PHRASE>", "ALL")>
	</cfcase>
	<cfdefaultcase> <!--- treat as ANY --->
		<cfscript>
			if (not findNoCase("not", trim(form.criteria))) {
				SearchCriteria = replacenocase(trim(form.criteria), ",", "", "ALL");
				SearchCriteria = replacenocase(trim(form.criteria), " ", " OR ", "ALL");
			}
			else
				SearchCriteria = trim(form.criteria);
		</cfscript>
	</cfdefaultcase>
</cfswitch>
<!--- get serach results --->
<cfif len(form.criteria)>
	<cfsearch collection="#lCollections#"  criteria="#searchCriteria#" name="qResults" maxrows="1000" suggestions="10" status="stQueryStatus" type="internet">
	<verity:searchlog status="#stQueryStatus#" type="internet" lcollections="#lCollections#" criteria="#searchCriteria#" />
	<cfdump var="#stQueryStatus#">
</cfif>
<cfparam name="qResults.recordCount" default="0">
<cfparam name="stQueryStatus" default="#structNew()#">

<ft:form action="#application.url.conjurer#?objectid=#application.navid.search#" name="searchForm">
<cfoutput>
	
	<h1>Search results</h1>	
	<div class="bodySearchParameters" style="">	
		<fieldset>
		<table>
		<tr>
			<td><label for="criteria2">You searched for:</label></td>
			<td><input type="text" name="criteria" id="criteria2" value="#form.criteria#" /></td>
		</tr>
		<tr>
			<td><label for="searchOperator">Search Operator:</label></td>
			<td>
				<select name="searchOperator">
					<option value="ANY"<cfif form.SearchOperator EQ "ANY" OR form.SearchOperator EQ ""> selected="selected"</cfif>>Any of these words</option>
				  	<option value="ALL"<cfif form.SearchOperator EQ "ALL"> selected="selected"</cfif>>All of these words</option>
				  	<option value="PHRASE"<cfif form.SearchOperator EQ "PHRASE"> selected="selected"</cfif>>These words as a phrase</option>
				</select>
			</td>
		</tr>
		<tr>
			<td><label for="advancedOptions">Advanced Options:</label></td>
			<td>
				<select name="advancedOptions">
					<option value="all"<cfif form.advancedOptions EQ "all" OR  form.advancedOptions EQ ""> selected="selected"</cfif>>All Content</option>
					<cfloop from="1" to="#arrayLen(aAllCollections)#" index="i">
						<option value="#aAllCollections[i].collectionname#"<cfif form.advancedOptions EQ aAllCollections[i].collectionname> selected="selected"</cfif>>#aAllCollections[i].title#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td><label for="action">&nbsp;</label></td>
			<td><ft:farcryButton value="search" /></td>
		</tr>
		</table>

			
			

		</fieldset>
	</div>
</cfoutput>

</ft:form>

<!--- work out page counter --->
<cfif isDefined("url.pg")>
	<cfset thispage = url.pg>
</cfif>
<cfset ResultsPerPage = 2>
<cfset startrow = (thispage * ResultsPerPage) - (ResultsPerPage - 1)>
<cfset endpage = ceiling(qResults.recordcount/ResultsPerPage)>
<cfset currentpage = 1>
<!--- work out the endrow from the above 2 vars and the recordcount --->
<cfif thispage eq endpage or endpage eq 1>
	<cfset endrow = qResults.recordcount>
<cfelse>
	<cfset endrow = startrow + ResultsPerPage - 1>
</cfif>
<cfif isDefined("qResults") AND qResults.recordCount gt 0>
	<cfoutput>
	<h6>Showing #startrow# to #endrow# of <span class="highlight">#qResults.recordCount#</span> results.</h6>
	<cfif structKeyExists(stQueryStatus, "suggestedquery")>		<cfif 	REFindNoCase(" and ", stQueryStatus.suggestedquery)OR
			REFindNoCase("\Aand ",stQueryStatus.suggestedquery)OR
			REFindNoCase(" and\Z",stQueryStatus.suggestedquery)OR
			REFindNoCase(" or ",stQueryStatus.suggestedquery)OR
			REFindNoCase("\Aor ",stQueryStatus.suggestedquery)OR
			REFindNoCase(" or\Z",stQueryStatus.suggestedquery)OR
			REFindNoCase(" not ",stQueryStatus.suggestedquery)OR
			REFindNoCase("\Anot ",stQueryStatus.suggestedquery)OR
			REFindNoCase(" not\Z",stQueryStatus.suggestedquery)>
			<cfset stQueryStatus.suggestedquery =  replaceList(stQueryStatus.suggestedquery," AND , OR , NOT , and , or , not ", " , , , , , ") />
		</cfif>
		<cfset request.inHead.PrototypeLite = 1 />
		<p>Did you mean: "<a href="##" onclick="$('criteria2').value='#stQueryStatus.suggestedquery#';$('searchForm').submit();">#stQueryStatus.suggestedquery#</a>"?</p>
	</cfif>
	

		<cfset urlParameters = "&objectid=#url.objectid#&criteria=#form.criteria#&searchOperator=#form.searchOperator#">
		</cfoutput>
		<cfif qResults.recordcount gt ResultsPerPage>
			
				<widgets:paginationDisplay
			        QueryRecordCount="#qResults.recordcount#"
			        DivStyle="pagination"
			        FileName="#cgi.script_name#"
			        MaxresultPages="5"
			        MaxRowsAllowed="#ResultsPerPage#"
			        bEnablePageNumber="true"
			        LayoutNumber="4"
			        FirstLastPage="numeric"
			        Layout_Previous="Previous"
			        Layout_Next="Next"
					CurrentPageWrapper_Start="<span>"
					CurrentPageWrapper_End="</span>"
			        ExtraURLString="#urlParameters#"
			        Layout_preNext="<strong>"
			        Layout_postNext="</strong>"
			        Layout_postPrevious="</strong>"
			        Layout_prePrevious="<strong>"
			        showCurrentPageDetails=true >
        </cfif>
	<!--- output results --->
	<cfloop query="qResults" startrow="#startrow#" endrow="#endrow#">
		<cfif len(qResults.custom1)>
		<!--- we have a text match --->
			<cfset oObject = createObject("component", application.stcoapi[qResults.custom1].packagepath)>
			<cfset stSearchObject = oObject.getData(objectID=qResults.key) />
			<cfset searchResultHTML = oObject.getView(stobject=stSearchObject, template="displaySearchResult", alternateHTML="")>
			<cfif len(searchResultHTML)>
				<cfoutput>#searchResultHTML#</cfoutput>
			<cfelse>
				<cfoutput>
				<dl class="search">
					<dt></cfoutput><skin:buildLink objectid="#qResults.key#"><cfoutput>#qResults.title#</cfoutput></skin:buildLink><cfoutput></dt></cfoutput>

						<cfoutput><dd class="desc">#qResults.summary# </cfoutput><skin:buildLink objectid="#qResults.key#"><cfoutput>Details</cfoutput></skin:buildLink><cfoutput></dd>
						<dd class="date">#dateFormat(stSearchObject.datetimelastupdated, "dd mmmm yyyy")#</dd>
					</dl>
				</cfoutput>
			</cfif>
		<cfelse>
		<!--- we have a file match --->
			<cfif len(qResults.key)>
			<!--- get the file name --->
				<cfset newfileName = replace(qResults.key, "\", "/", "all")>
				<cfset fileName = listLast(newfileName, "/")>
				<!--- now we have to look up the fileName and get the object id of the dmFile --->
				<cfquery name = "qFile" datasource="#application.dsn#">
					select distinct(objectid), bMemberRestricted from dmFile where
					filename = '#fileName#'
				</cfquery>

				<cfif qFile.recordcount and not qFile.bMemberRestricted>
					<cfset oFileObject = createObject("component", application.stcoapi.dmFile.packagepath)>
					<cfset fileHTML = oFileObject.getView(objectid=qFile.objectid, template="displaySearchResult")>
					<cfoutput>#fileHTML#</cfoutput>
				<cfelse>
					<!--- check if file is member only and only show if a member is logged in--->
					<cfif qFile.recordcount and qFile.bMemberRestricted and session.steelweb.bLoggedIn>
						<cfset oFileObject = createObject("component", application.stcoapi.dmFile.packagepath)>
						<cfset fileHTML = oFileObject.getView(objectid=qFile.objectid, template="displaySearchResult")>
						<cfoutput>#fileHTML#</cfoutput>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<!--- show previous/next links --->
		<cfif qResults.recordcount gt ResultsPerPage>
			<widgets:paginationDisplay
			        QueryRecordCount="#qResults.recordcount#"
			        DivStyle="pagination"
			        FileName="#cgi.script_name#"
			        MaxresultPages="5"
			        MaxRowsAllowed="#ResultsPerPage#"
			        bEnablePageNumber="true"
			        LayoutNumber="4"
			        FirstLastPage="numeric"
			        Layout_Previous="Previous"
			        Layout_Next="Next"
					CurrentPageWrapper_Start="<span>"
					CurrentPageWrapper_End="</span>"
			        ExtraURLString="#urlParameters#"
			        Layout_preNext="<strong>"
			        Layout_postNext="</strong>"
			        Layout_postPrevious="</strong>"
			        Layout_prePrevious="<strong>"
			        showCurrentPageDetails=true >
        </cfif>
<cfelse>
	<cfoutput>
	<h6>Your search for "#form.criteria#" produced no results.</h6>
	
	<cfif structKeyExists(stQueryStatus, "suggestedquery")>		<cfif 	REFindNoCase(" and ", stQueryStatus.suggestedquery)OR
			REFindNoCase("\Aand ",stQueryStatus.suggestedquery)OR
			REFindNoCase(" and\Z",stQueryStatus.suggestedquery)OR
			REFindNoCase(" or ",stQueryStatus.suggestedquery)OR
			REFindNoCase("\Aor ",stQueryStatus.suggestedquery)OR
			REFindNoCase(" or\Z",stQueryStatus.suggestedquery)OR
			REFindNoCase(" not ",stQueryStatus.suggestedquery)OR
			REFindNoCase("\Anot ",stQueryStatus.suggestedquery)OR
			REFindNoCase(" not\Z",stQueryStatus.suggestedquery)>
			<cfset stQueryStatus.suggestedquery =  replaceList(stQueryStatus.suggestedquery," AND , OR , NOT , and , or , not ", " , , , , , ") />
		</cfif>
		<cfset request.inHead.PrototypeLite = 1 />
		<p>Did you mean: "<a href="##" onclick="$('criteria2').value='#stQueryStatus.suggestedquery#';$('searchForm').submit();">#stQueryStatus.suggestedquery#</a>"?</p>
	</cfif>

	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="no">