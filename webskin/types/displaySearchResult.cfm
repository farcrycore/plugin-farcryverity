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
	<cfset summary = replaceNoCase(summary,i,"<span class='highlight'>#i#</span>", "all") />
</cfloop>

<cfoutput>
	<dl>
		<div class="rank">#stParam.rank#.</div>
		<dt>
			</cfoutput>
			<skin:buildlink objectid="#stObj.objectID#">
				<cfoutput><cfif len(stParam.title)>#stParam.title#<cfelse>#stObj.label#</cfif></cfoutput>
			</skin:buildlink>
			<cfoutput>
		</dt>
		<dd class="summary">
			</cfoutput>
			<cfoutput>#summary#</cfoutput>
			<cfif right(summary,3) EQ "...">
				<skin:buildlink objectid="#stObj.objectID#">more</skin:buildlink>
			</cfif>
			<cfoutput>
		</dd>
		<dd class="footer">
			#application.stCoapi[stobj.typeName].displayName# | #dateFormat(stObj.dateTimeLastUpdated, "dd mmmm yyyy")#
		</dd>
	</dl>
</cfoutput>

<cfsetting enablecfoutputonly="false" />