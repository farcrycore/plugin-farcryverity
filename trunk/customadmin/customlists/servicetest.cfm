<cfquery name="qConfigs" datasource="#application.dsn#">
SELECT * FROM farVerityCollection
ORDER BY title
</cfquery>

<cfoutput>
<h2>Verity Service</h2>
<p><a href="http://daemonite.local/farcry/admin/customadmin.cfm?module=customlists/servicetest.cfm&plugin=farcryverity">Reset All</a></p>

<h2>Collection Config</h2>
<cfloop query="qConfigs">
<h3>#qconfigs.collectionname#</h3>
<ul>
	<li><a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&verityaction=create&configid=#qconfigs.objectid#">Create #qConfigs.title#</a></li>
	<li><a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&verityaction=delete&configid=#qconfigs.objectid#">Delete #qConfigs.title#</a></li>
	<li><a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&verityaction=optimize&configid=#qconfigs.objectid#">Optimize #qConfigs.title#</a></li>
	<li><a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&verityaction=update&configid=#qconfigs.objectid#">Update #qConfigs.title#</a></li>
	<li><a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&verityaction=search&configid=#qconfigs.objectid#">Search #qConfigs.title#</a></li>
</ul>
</cfloop>
</cfoutput>

<cfparam name="url.verityaction" default="none" type="string" />
<cfparam name="url.configid" default="#createUUID()#" type="uuid" />
<cfset oVerity=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityService").init(path="C:\coldfusionverity\collections") />
<cfset stConfig=createobject("component", "farcry.plugins.farcryverity.packages.types.farVerityCollection").getData(objectid=url.configid) />

<cfswitch expression="#url.verityaction#">
	
	<cfcase value="create">
		<cfset stresult=oVerity.createCollection(collection=stconfig.collectionname) />
		<cfdump var="#stResult#" />
	</cfcase>

	<cfcase value="delete">
		<cfset stresult=oVerity.deleteCollection(collection=stconfig.collectionname) />
		<cfdump var="#stResult#" />
	</cfcase>	

	<cfcase value="optimize">
		<cfset stresult=oVerity.optimizeCollection(collection=stconfig.collectionname) />
		<cfdump var="#stResult#" />
	</cfcase>

	<cfcase value="update">
		<cfset stresult=oVerity.update(config=stconfig) />
		<cfdump var="#stResult#" />
	</cfcase>

	<cfcase value="search">
		<cfoutput><h2>Search Results</h2></cfoutput>
		<cfsearch collection="#stconfig.collectionname#" criteria="*" name="qResults" status="stinfo" />
		<cfdump var="#qResults#">
		<cfdump var="#stInfo#">
	</cfcase>
	
</cfswitch>

