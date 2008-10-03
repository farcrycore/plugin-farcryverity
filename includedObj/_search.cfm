<cfsetting enablecfoutputonly="true" />
<!--------------------------------------------------------------------
Search Results
 - dmInclude (_search.cfm)
--------------------------------------------------------------------->
<!--- @@displayname: Search Results Page --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<farcry:deprecated message="Search Include page should be replaced with type webskin in the tree" />

<skin:view typename="farVeritySearch" key="searchForm" webskin="displaySearchResults"  />


<cfsetting enablecfoutputonly="false" />