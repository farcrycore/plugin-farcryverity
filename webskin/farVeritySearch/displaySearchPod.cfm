<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />



<!--- We want to clear the value in this search field when displaying and let the search form handle it once submitted --->
<cfset stPropMetadata = structNew() />
<cfset stPropMetadata.criteria = structNew() />
<cfset stPropMetadata.criteria.value = "" />
<ft:object objectid="#stobj.objectid#" lFields="criteria" stPropMetadata="#stPropMetadata#" r_stFields="stFields" />

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



<cfsetting enablecfoutputonly="false" />