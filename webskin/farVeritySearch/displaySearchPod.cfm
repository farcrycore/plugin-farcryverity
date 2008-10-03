<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<!--- DEFAULT STPARM --->
<cfparam name="stparam.actionURL" default="" />


<cfif not len(stparam.actionURL)>
	<cfif structKeyExists(application.navid, "search")>
		<cfset stparam.actionURL = "#application.url.conjurer#?objectID=#application.navID.search#" />
	<cfelse>
		<cfset stparam.actionURL = "#application.url.conjurer#?type=farVerityCollection&bodyView=displayTypeSearchResults" />
	</cfif>
</cfif>

<ft:form name="searchFormPod" action="#stparam.actionURL#">
	
	<!--- We want to clear the value in this search field when displaying and let the search form handle it once submitted --->
	<cfset stPropMetadata = structNew() />
	<cfset stPropMetadata.criteria = structNew() />
	<cfset stPropMetadata.criteria.value = "" />
	<ft:object objectid="#stobj.objectid#" lFields="criteria,lCollections" stPropMetadata="#stPropMetadata#" r_stFields="stFields" />

	<cfoutput>
		<div id="search">
			<table id="tab-search" class="layout">
			<tr>
				<td valign="middle">#stFields.criteria.label#</td>
				<td valign="middle">#stFields.criteria.html#</td>
				<td valign="middle"><ft:button value="Search" size="small" /></td>
			</tr>
			</table>
		</div>
	</cfoutput>
</ft:form>


<cfsetting enablecfoutputonly="false" />