<!--- @@displayname: Update Verity Collections --->
<cfsetting enablecfoutputonly="true">

<cfquery datasource="#application.dsn#" name="qCollections">
	select	*
	from	farVerityCollection
	where	hostname = '#lcase(application.sysinfo.machinename)#'
</cfquery>

<cfset oVerity=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityService").init() />
<cfloop query="qCollections">
	<cfset stConfig=createobject("component", "farcry.plugins.farcryverity.packages.types.farVerityCollection").getData(objectid=qCollections.objectid[currentrow]) />
	<cfset stresult=oVerity.update(config=stconfig) />
	<cfoutput>
		#stResult.message#<br/>
	</cfoutput>
</cfloop>

<cfsetting enablecfoutputonly="false">