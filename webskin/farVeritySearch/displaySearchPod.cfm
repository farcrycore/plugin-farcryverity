<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<!--- DEFAULT STPARM --->
<cfparam name="stparam.actionURL" default="" />


<!--- ONLY SHOW THE MINI POD IF WE ARE NOT CURRENTLY PERFORMING A SEARCH --->
<cfif not structKeyExists(form, "criteria")>

	<cfif not len(stparam.actionURL)>
		<cfif structKeyExists(application.navid, "search")>
			<cfset stparam.actionURL = "#application.url.conjurer#?objectID=#application.navID.search#" />
		<cfelse>
			<cfset stparam.actionURL = "#application.url.conjurer#?type=farVerityCollection&bodyView=displayTypeSearch" />
		</cfif>
	</cfif>

	
	<cfoutput>
	<div id="search">
		<form method="post" action="#stparam.actionURL#">
			<label for="criteria">Site Search:</label>
			<input id="criteria" type="text" name="criteria"/>
			<input class="f-submit" type="submit" value="Go"/>
		</form>
	</div>
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />