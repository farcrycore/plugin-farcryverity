<cfsetting enablecfoutputonly="true" />
<!------------------------------------------------------------------------
 THIS FILE ONLY GETS RUN ON THE INITIALISATION OF THE PROJECT
 - note runs AFTER ./project/config/_serverSpecifcVars.cfm
 ------------------------------------------------------------------------>
<cfset pluginLoaded=true />

<!--- set up plugin config --->
<cfif NOT structkeyExists(application.stplugins, "farcryverity")>
	<cfset application.stplugins.farcryverity = structNew() />
</cfif>

<!--- set up verity service --->
<cfif NOT structkeyExists(application.stplugins.farcryverity, "oVerityConfig")>
	<cftry>
		<cfset application.stplugins.farcryverity.oVerityConfig=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityConfig").init() />
		<cfcatch type="any">
			<!--- warn that plugin is not installed.. but don't blow up --->
			<cftrace type="warning" text="Problem initialising farcryverity plugin. Confirm types have been deployed." />
			<cfset application.coapi.COAPIUTILITIES.unloadPlugin("farcryverity") />
			<cfset pluginLoaded=false />
		</cfcatch>
	</cftry>
</cfif>

<!--- continue only if plugin config correct --->
<cfif pluginLoaded>
	<!--- set verity collection storage path --->
	<cfif NOT structkeyExists(application.stplugins.farcryverity, "storagePath")>
		<!--- set default storage path --->
		<cfset application.stplugins.farcryverity.oVerityConfig.setStoragePath(storagePath="C:\coldfusionverity\collections") />
	<cfelse>
		<!--- set custom storage path --->
		<cfset application.stplugins.farcryverity.oVerityConfig.setStoragePath(storagePath=application.stplugins.farcryverity.storagePath) />
	</cfif>
	
	<!--- set supported hosts --->
	<cfif NOT structkeyExists(application.stplugins.farcryverity, "lhosts")>
		<!--- set default host --->
		<cfset application.stplugins.farcryverity.lhosts = createObject("java", "java.net.InetAddress").localhost.getHostName() />
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false" />