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
	<ft:processFormObjects objectid="#stobj.objectid#" typename="#stobj.typename#" bSessionOnly="true" />
</ft:processForm>

<!--- Render the search form and results --->
<ft:form name="#stobj.typename#SearchForm" bAjaxSubmission="true" ajaxMaskMsg="Searching..." action="#application.url.webroot#/index.cfm?objectid=#stobj.objectid#&view=displaySearch">

	<!--- Get the search Results --->
	<cfset oSearchService=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityService").init() />
	<cfset stSearchResult = oSearchService.getSearchResults(objectid="#stobj.objectid#", typename="#stobj.typename#") />

	<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchForm" />

	<cfif len(stSearchResult.searchCriteria)>

		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchCount" stParam="#stSearchResult#" />

		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchSuggestions" stParam="#stSearchResult#" />

		<cfif stSearchResult.qResults.recordCount GT 0>
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchResults" stParam="#stSearchResult#" />
		</cfif>
	<cfelse>
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="displaySearchNoCriteria" stParam="#stSearchResult#" />
	</cfif>
</ft:form>



<cfsetting enablecfoutputonly="false">