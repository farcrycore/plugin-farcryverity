<cfsetting enablecfoutputonly="true" />

<!--- required libs --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<!--- determine whether to use teaser or verity summary --->
<cfif structKeyExists(stObj,"teaser") AND len(trim(stObj.teaser))>
	<cfset summary = trim(stObj.teaser) />
<cfelse>
	<cfset summary = trim(stParam.summary) />
</cfif>

<!--- highlight matches --->
<cfloop list="#stParam.searchTerms#" delimiters="|" index="i">
	<cfset summary = replaceNoCase(summary,i,"<span class='searchhighlight'>#i#</span>", "all") />
</cfloop>

<cfoutput>
	<div id="vp-searchresult">
		<div class="searchtitle">
			</cfoutput>
			<skin:buildlink objectid="#stObj.objectID#">
				<cfoutput><cfif len(stParam.title)>#stParam.title#<cfelse>#stObj.label#</cfif></cfoutput>
			</skin:buildlink><cfoutput><br />
		</div>
		<div class="searchdate">
			<cfoutput>#dateFormat(stObj.dateTimeLastUpdated, "d mmmm yyyy")#<br /></cfoutput>
		</div>
		<div class="searchsummary">
			</cfoutput>
				<cfoutput>#summary# </cfoutput>
				<cfif right(summary,3) EQ "...">
					<skin:buildlink objectid="#stObj.objectID#"><cfoutput>  more</cfoutput></skin:buildlink>
				</cfif>
			<cfoutput><br />
		</div>
		<div class="searchfooter">
			#application.stCoapi[stobj.typeName].displayName# <span class="searchlight">|</span> </cfoutput>
			<skin:buildlink objectid="#stObj.objectID#">
				<cfoutput>Go to page</cfoutput>
			</skin:buildlink><cfoutput><br />
		</div>
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />