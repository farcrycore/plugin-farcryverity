<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<!--- DEFAULT STPARM --->
<cfparam name="stparam.actionURL" default="" />

<cfif structKeyExists(url,"criteria")>
	<cfset form.criteria = url.criteria />
</cfif>

<!--- ONLY SHOW THE MINI POD IF WE ARE NOT CURRENTLY PERFORMING A SEARCH --->
<cfif not structKeyExists(form, "criteria")>

	<cfif not len(stparam.actionURL)>
		<cfif structKeyExists(application.navid, "search")>
			<cfset stparam.actionURL = "#application.url.conjurer#?objectID=#application.navID.search#" />
		<cfelse>
			<cfset stparam.actionURL = "#application.url.conjurer#?type=farVerityCollection&bodyView=displayTypeSearch" />
		</cfif>
	</cfif>

	<ft:form action="#stparam.actionURL#" name="searchForm">
		<cfoutput>
		<table>
		<tr>
			<td><input type="text" name="criteria" value="" /> </td>
			<td><ft:button value="Search" /></td>
		</tr>
		</table>
		</cfoutput>
	</ft:form>
</cfif>

<cfsetting enablecfoutputonly="false" />