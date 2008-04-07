<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:form action="#application.url.conjurer#?objectID=#application.navID.search#" name="searchForm">

<cfoutput>
	<div id="vp-searchform">
		<table>
		<tr>
			<td><label for="criteria2">You searched for:</label></td>
			<td><input type="text" name="criteria" id="criteria2" value="#form.criteria#" /></td>
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
			<td><ft:farcryButton value="Search" /></td>
		</tr>
		</table>
	</div>
</cfoutput>

</ft:form>

<cfsetting enablecfoutputonly="false" />