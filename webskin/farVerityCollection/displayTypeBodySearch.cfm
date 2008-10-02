<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Search Results Page --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/plugins/farcryverity/tags/" prefix="verity" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<!--- config vars --->
<cfparam name="resultsPerPage" default="10" type="numeric" />
<cfparam name="maxResultPages" default="5" type="numeric" />
<cfparam name="maxResults" default="1000" type="numeric" />
<cfparam name="highlightMatches" default="false" type="boolean" />

<!--- default local vars --->
<cfparam name="stQueryStatus" default="#structNew()#" type="struct" />
<cfparam name="stParam" default="#structNew()#" type="struct" />

<!--- form vars --->
<cfparam name="form.advancedOptions" default="all" type="string" />
<cfparam name="form.criteria" default="" type="string" />
<cfparam name="form.searchOperator" default="" type="string" />

<cfset lAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionList() />
<cfset aAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionArray() />

<!--- inbound parameters defaults --->

<cfif structKeyExists(url,"criteria")>
	<cfset form.criteria = url.criteria />
</cfif>
<cfif structKeyExists(url,"searchOperator")>
	<cfset form.searchOperator = url.searchOperator />
</cfif>
<cfif structKeyExists(url, "advancedOptions")>
	<cfset form.advancedOptions = url.advancedOptions />
</cfif>
<cfif structKeyExists(url,"pg")>
	<cfset thisPage = url.pg />
</cfif>

<!--- setup the collections to search on, this may depend on the form value passed in on the search results page --->
<cfif form.advancedOptions EQ "all">
	<cfset lCollections = lAllCollections />
<cfelse>
	<cfset lCollections = form.advancedOptions />
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


<ft:form>

<!--- display search form --->

<cfoutput>
	<div id="vp-searchform">
		<table class="layout">
		<tr>
			<td><label for="criteria">You searched for:</label></td>
			<td><input type="text" name="criteria" id="criteria" value="#form.criteria#" /></td>
			<td></td>
		</tr>
		<tr>
			<td><label for="searchOperator">Search Operator:</label></td>
			<td>
				<select name="searchOperator">
					<option value="any"<cfif form.searchOperator EQ "any" OR form.searchOperator EQ ""> selected="selected"</cfif>>Any of these words</option>
				  	<option value="all"<cfif form.searchOperator EQ "all"> selected="selected"</cfif>>All of these words</option>
				  	<option value="phrase"<cfif form.searchOperator EQ "phrase"> selected="selected"</cfif>>These words as a phrase</option>
				</select>
			</td>
			<td></td>
		</tr>
		<tr>
			<td><label for="advancedOptions">Advanced Options:</label></td>
			<td>
				<select name="advancedOptions">
					<option value="all"<cfif form.advancedOptions EQ "all" OR  form.advancedOptions EQ ""> selected="selected"</cfif>>All Content</option>
					<cfloop index="i" from="1" to="#arrayLen(aAllCollections)#">
						<option value="#aAllCollections[i].collectionname#"<cfif form.advancedOptions EQ aAllCollections[i].collectionname> selected="selected"</cfif>>#aAllCollections[i].title#</option>
					</cfloop>
				</select>
			</td>
			<td><ft:button value="Search" /></td>
		</tr>
		</table>
	</div>
</cfoutput>



<cfif isDefined("qResults") AND qResults.recordCount GT 0>

	<cfif structKeyExists(stQueryStatus, "suggestedQuery")> <!--- display suggestion --->
		<cfoutput>#suggestLink(stQueryStatus.suggestedQuery)#</cfoutput>
	</cfif>

	<cfoutput><p><b>Your search returned <span id="vp-resultsfound">#qResults.recordCount#</span> results.</b></p></cfoutput>

	<!--- display search results --->
	
	<ft:pagination 
		paginationID="#stobj.objectid#"
		qRecordSet="#qResults#"
		pageLinks="5"
		recordsPerPage="25" 
		Top="true" 
		Bottom="true"
		submissionType="form"
		renderType="inline"
		bShowPageDropdown="false"
		>

		
		<!--- Loop through the page to get all the image ID s --->
		<ft:paginateLoop r_stObject="st" bTypeAdmin="false">		
			
			<cfswitch expression="#st.category#">
			<cfcase value="file">
				<cfset searchResultObjectID = st.custom2 />
			</cfcase>
			<cfdefaultcase>
				<cfset searchResultObjectID = st.key />
			</cfdefaultcase>
			</cfswitch>
			
			<!--- FORMAT THE SUMMARY --->
			<cfset st.summary = stripHTML(st.summary) />
			<cfif highlightMatches>
				<cfset st.summary = highlightSummary(searchCriteria="#searchCriteria#", summary="#st.summary#") />
			</cfif>
			
			
			<skin:view typename="#st.custom1#" objectid="#searchResultObjectID#" webskin="displaySearchResult"
				searchCriteria="#searchCriteria#"
				rank="#st.rank#"	
				score="#st.score#"		
				title="#st.title#"	
				key="#st.key#"
				summary="#st.summary#"		
				 >

		</ft:paginateLoop>
	</ft:pagination>
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

	<cfset suggestHTML = "<p>Did you mean <a href=""##"" onclick=""$('criteria').value='#suggestedQuery#';$('searchForm').submit();""><em>#suggestedQuery#</em></a> ?</p>" />

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

<cfsetting enablecfoutputonly="false" />