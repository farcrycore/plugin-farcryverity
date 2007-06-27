<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!----------------------------------------
ENVIRONMENT
----------------------------------------->
<cfparam name="form.action" default="none" type="string" />

<cfquery datasource="#application.dsn#" name="qPurge">
SELECT objectid, title, hostname, collectionname 
FROM farVerityCollection
WHERE hostname NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#application.stplugins.farcryverity.lhosts#" />)
</cfquery>

<!--- <cfdump var="#qPurge#"> --->

<!----------------------------------------
ACTION
----------------------------------------->
<cfswitch expression="#form.action#">

	<cfcase value="Purge Redundant Configs">
		<cfoutput><h3>Not quite baked: Purge Redundant Configs</h3></cfoutput>
	</cfcase>

</cfswitch>

<!----------------------------------------
VIEW
----------------------------------------->
<!--- set up page header --->
<admin:header title="Host Management" />

<!--- Purge Redundant Collections --->
<cfform format="flash" name="purgehostform">
	<cfformgroup type="panel" label="Purge Redundant Collections">
		<!--- nested tree model orphans --->
		<cfformitem type="html"><p>The listed hosts are not registered as authorised Verity hosts. Purge 
			configs for the selected hosts, assuming the host is redundant. <b>There is no undo.</b></p></cfformitem>

		<cfgrid query="qPurge" name="purge"  />

		<cfformgroup type="horizontal">
			<cfinput type="submit" name="action" value="Purge Redundant Configs" />
		</cfformgroup>
	</cfformgroup>
</cfform>

<!--- setup footer --->
<admin:footer />



