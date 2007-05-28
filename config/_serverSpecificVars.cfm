<cfsetting enablecfoutputonly="Yes">

<!------------------------------------------------------------------------
 THIS FILE ONLY GETS RUN ON THE INITIALISATION OF THE PROJECT
 ------------------------------------------------------------------------>

<!--- set up lylacaptcha service --->
<cfset application.stplugins.farcryverity = structNew() />
<cfset application.stplugins.farcryverity.verityStoragePath = "C:\coldfusionverity\collections" />

<cfsetting enablecfoutputonly="no">
