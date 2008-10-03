<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">
<cfimport taglib="/farcry/core/tags/widgets" prefix="widgets" />
<cfimport taglib="/farcry/plugins/farcryverity/tags/" prefix="verity" /> 

<!--- set up page header --->
<admin:header title="Test Search" />

<cfoutput><h1>Search</h1></cfoutput>
<skin:view typename="farVeritySearch" key="searchForm" webskin="displaySearchResults"  />

<!--- setup footer --->
<admin:footer />