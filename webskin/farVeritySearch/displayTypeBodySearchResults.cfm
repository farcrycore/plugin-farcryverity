<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Search Results Page --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput><h1>Search</h1></cfoutput>
<skin:view typename="farVeritySearch" key="searchForm" webskin="displaySearchResults" searchFormWebskin="displaySearchForm" bAllowEmptyCriteria="false" />


<cfsetting enablecfoutputonly="false" />