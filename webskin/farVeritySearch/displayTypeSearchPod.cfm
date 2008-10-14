<cfsetting enablecfoutputonly="true" />

<!--- @@displayname: Search Pod --->
<!--- @@author: Geoff Bowers (modius@daemon.com.au) --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />



<cfif structKeyExists(application.navid, "search")>
	<cfset actionURL = "#application.url.conjurer#?objectID=#application.navID.search#" />
<cfelse>
	<cfset actionURL = "#application.url.conjurer#?type=#stobj.name#&bodyView=displayTypeBodySearch" />
</cfif>


<ft:form action="#actionURL#">

	<skin:view typename="#stobj.name#" key="#stobj.name#SearchForm" webskin="displaySearchPod"  />

</ft:form>

<cfsetting enablecfoutputonly="false" />