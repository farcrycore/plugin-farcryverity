<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Display Search Results --->
<!--- @@description: Runs the cfsearch and displays the search results  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/plugins/farcryverity/tags" prefix="verity" />

<!------------------ 
START WEBSKIN
 ------------------>


<!--- default local vars --->
<cfparam name="stQueryStatus" default="#structNew()#" type="struct" />

<!--- inbound parameters defaults --->
<ft:processForm action="Search" url="refresh">
	<ft:processFormObjects typename="farVeritySearch" bSessionOnly="true" />
</ft:processForm>

<!--- Initialize the Search Service --->
<cfset oSearchService=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityService").init() />


<cfset stSearchResult = oSearchService.getSearchResults(objectid="#stobj.objectid#") />

<ft:form name="searchForm">

	<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchForm" />

	<cfif len(stSearchResult.searchCriteria)>

		<cfif stSearchResult.qResults.recordCount GT 0>

			<cfif len(stSearchResult.suggestLink)>
				<cfoutput><p>Did you mean #stSearchResult.suggestLink#?</p></cfoutput>
			</cfif>
		
			<cfoutput><p><b>Your search returned <span id="vp-resultsfound">#stSearchResult.qResults.recordCount#</span> results.</b></p></cfoutput>
		
			<!--- display search results --->
			<ft:pagination 
				paginationID="#stobj.objectid#"
				qRecordSet="#stSearchResult.qResults#"
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

					<skin:view 
						typename="#st.custom1#" 
						objectid="#st.objectid#" 
						webskin="displaySearchResult"
						searchCriteria="#stSearchResult.searchCriteria#"
						rank="#st.rank#"	
						score="#st.score#"		
						title="#st.title#"	
						key="#st.key#"
						summary="#st.summary#"		
						 >
		
				</ft:paginateLoop>
			</ft:pagination>
		<cfelse>
		
			<cfoutput><p>Your search for "#stSearchResult.searchCriteria#" produced no results.</p></cfoutput>

			<cfif len(stSearchResult.suggestLink)>
				<cfoutput><p>Did you mean #stSearchResult.suggestLink#?</p></cfoutput>
			</cfif>
		</cfif>
	<cfelse>
		<cfoutput><p>Please enter in a search term above.</p></cfoutput>
	</cfif>
</ft:form>



<cfsetting enablecfoutputonly="false">