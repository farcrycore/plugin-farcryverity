<cfsetting enablecfoutputonly="Yes">

<!------------------------------------------------------------------------
 THIS FILE ONLY GETS RUN ON THE INITIALISATION OF THE PROJECT
 ------------------------------------------------------------------------>

<!--- set up verity service --->
<cfset application.stplugins.farcryverity = structNew() />
<cfset application.stplugins.farcryverity.oVerityConfig=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityconfig").init() />
<cfset application.stplugins.farcryverity.oVerityConfig.setStoragePath(StoragePath="C:\coldfusionverity\collections") />

<cfset application.stplugins.farcryverity.lhosts = createObject("java", "java.net.InetAddress").localhost.getHostName() />

<cfsetting enablecfoutputonly="no">
