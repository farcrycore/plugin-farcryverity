<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfoutput>
	<dt>
</cfoutput>
<skin:buildlink objectid="#stObj.objectid#" target="blank">
	<cfif structkeyexists(application.stCOAPI[stObj.typename],"icon")>
		<cfoutput>
			<img src="#application.stCOAPI[stObj.typename].icon#" class="icon" alt="#application.stCOAPI[stObj.typename].displayname#" border="0" style="float:left;" />
		</cfoutput>
	</cfif>
	<cfoutput>#stObj.label#</cfoutput>
</skin:buildlink>
<cfoutput>
	</dt>
</cfoutput>

<cfif structkeyexists(stObj,"teaser")>
	<cfoutput>
		<dd>
			#stObj.teaser#
	</cfoutput>
	
	<skin:buildlink objectid="#stObj.objectid#" target="_blank">
		<cfoutput>more...</cfoutput>
	</skin:buildlink>
	
	<cfoutput>
		</dd>
	</cfoutput>
</cfif>

<cfoutput>
	<dd class="date">#dateFormat(stObj.datetimelastupdated, "dd mmmm yyyy")#</dd>
</cfoutput>

<cfsetting enablecfoutputonly="false" />