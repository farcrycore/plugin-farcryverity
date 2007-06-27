<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!----------------------------------------
ENVIRONMENT
----------------------------------------->
<cfparam name="form.action" default="none" type="string" />

<cfset qMissing=queryNew("objectid,collectionname,title,collectiontypename") />

<cfset oVerity=createObject("component", "farcry.plugins.farcryverity.packages.custom.verityservice").init() />
<cfset qCollections=oVerity.getCollections() />

<cfquery datasource="#application.dsn#" name="qHostConfigs">
SELECT objectid, collectionname, title, collectiontypename
FROM farVerityCollection
WHERE hostname = '#application.sysinfo.machinename#'
</cfquery>

<cfloop query="qHostConfigs">
	<cfquery dbtype="query" name="qMissingCheck">
	SELECT name
	FROM qCollections
	WHERE qCollections.name = '#qHostConfigs.collectionname#'
	</cfquery>
	
	<cfif NOT qMissingCheck.recordcount>
		<cfquery dbtype="query" name="qConfig">
		SELECT objectid, collectionname, title, collectiontypename
		FROM qHostConfigs
		WHERE collectionname = '#qMissingCheck.name#'
		</cfquery>
		
		<cfset queryAddRow(qMissing,1) />
		<cfset querySetCell(qMissing, "objectid", qHostConfigs.objectid) />
		<cfset querySetCell(qMissing, "collectionname", qHostConfigs.collectionname) />
		<cfset querySetCell(qMissing, "title", qHostConfigs.title) />
		<cfset querySetCell(qMissing, "collectiontypename", qHostConfigs.collectiontypename) />
	</cfif>
</cfloop>


<!----------------------------------------
ACTION
----------------------------------------->
<cfswitch expression="#form.action#">
	
	<cfcase value="Create Verity Collections">

		<cfoutput><h3>Create Verity Collections</h3></cfoutput>
		
		<cfset oVerity=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityservice").init() />
		<cfset ofvc=createObject("component", "farcry.plugins.farcryverity.packages.types.farVerityCollection") />

		<cfloop query="qMissing">
			<cfset stConfig=ofvc.getData(objectid=qMissing.objectid) />
			<cfset verityResult=oVerity.createCollection(collection=stConfig.collectionname) />
			<cfdump var="#verityResult#">
		</cfloop>
		<cfoutput>All Done.</cfoutput>
		<cfabort />

	</cfcase>
	
</cfswitch>

<!----------------------------------------
VIEW
----------------------------------------->
<!--- set up page header --->
<admin:header title="Host Management" />

<!--- Create Missing Collections --->
<cfform format="flash" name="createhostcollections">
	<cfformgroup type="panel" label="Create Missing Collections">
		<!--- nested tree model orphans --->
		<cfformitem type="html"><p>The following collections do not exist for this host. Create <b>ALL</b> missing 
		collections for this host by clicking the button provided.</p></cfformitem>
		
		<cfgrid query="qMissing" name="collections"  />
		
		<cfformgroup type="horizontal">
			<cfinput type="submit" name="action" value="Create Verity Collections" />
		</cfformgroup>
	</cfformgroup>
</cfform>

<!--- setup footer --->
<admin:footer />



