<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets" />
<cfimport taglib="/farcry/plugins/farcryverity/tags/" prefix="verity" /> 

<!--- set up page header --->
<admin:header title="Test Search" />

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


	.searchhighlight {color:white;background-color:red;}
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
</cfif>
<cfparam name="qResults.recordCount" default="0">
<cfparam name="stQueryStatus" default="#structNew()#">

<ft:form action="#application.url.farcry#/admin/customadmin.cfm?plugin=farcryverity&amp;module=customlists/testsearch.cfm" name="searchForm">
<cfoutput>
	
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



<!--- work out page counter --->
<cfif isDefined("url.pg")>
	<cfset thispage = url.pg>
</cfif>
<cfset ResultsPerPage = 10>
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
		<p>Did you mean: "<a href="##" onclick="$('criteria2').value='#stQueryStatus.suggestedquery#';btnSubmit('#Request.farcryForm.Name#','search');">#stQueryStatus.suggestedquery#</a>"?</p>
	</cfif>


		<cfset urlParameters = "&plugin=farcryverity&module=customlists/testsearch.cfm&criteria=#form.criteria#&searchOperator=#form.searchOperator#">
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
		

		<!--- FORMAT THE SUMMARY --->
		<cfset formattedSummary = stripHTML(qResults.summary) />
		<cfset formattedSummary = highlightSummary(searchCriteria="#searchCriteria#", summary="#formattedSummary#") />	
		
		<!--- Depending on the type of index that generated the result (custom:Standard,file:File Library,cat:Category Filtered) determines where the object id is located --->
		<cfswitch expression="#qResults.category#">
		<cfcase value="file">
			<cfset searchResultObjectID = qResults.custom2 />
		</cfcase>
		<cfdefaultcase>
			<cfset searchResultObjectID = qResults.key />
		</cfdefaultcase>
		</cfswitch>
				
		<skin:view 
			typename="#qResults.custom1#" 
			objectid="#searchResultObjectID#"
			webskin="displaySearchResult"
			searchCriteria="#searchCriteria#"
			rank="#qResults.rank#"	
			score="#qResults.score#"		
			title="#qResults.title#"	
			key="#qResults.key#"
			summary="#formattedSummary#"		
			 >
			 
		
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
		<p>Did you mean: "<a href="##" onclick="$('criteria2').value='#stQueryStatus.suggestedquery#';btnSubmit('#Request.farcryForm.Name#','search');">#stQueryStatus.suggestedquery#</a>"?</p>
	</cfif>

	</cfoutput>

</cfif>
</ft:form>


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
	
	<skin:htmlHead library="extCoreJS">

	<cfset suggestHTML = "<p>Did you mean <a href=""##"" onclick=""$('criteria').value='#suggestedQuery#';btnSubmit('#Request.farcryForm.Name#','search');""><em>#suggestedQuery#</em></a> ?</p>" />

	<cfreturn suggestHTML />
</cffunction>

<cffunction name="highlightSummary" returntype="string" access="private" description="wraps span highlight class around matching terms in summary" output="false">
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



<!--- setup footer --->
<admin:footer />