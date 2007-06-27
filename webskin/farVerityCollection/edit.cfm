<cfsetting enablecfoutputonly="true" />

<cfimport prefix="ft" taglib="/farcry/core/tags/formtools" />

<!------------------------------- 
ACTION:
-------------------------------->
<ft:processform action="Create Collection" url="refresh">
	<!--- create physical collection --->
	<ft:processformobjects typename="#URL.Typename#" r_stproperties="stprops">
		<cfset stprops.hostname=application.sysinfo.machinename />
		<cfset stprops.collectionname=application.applicationname & "_" & stprops.collectiontypename />
		<cfif stprops.collectiontype neq 'custom'>
			<cfset stprops.collectionname=stprops.collectionname & "_" & stprops.collectiontype />
		</cfif>
		<cfset stprops.collectionname=lcase(stprops.collectionname) />
		
		<cfquery name="qCheckCollectionName" datasource="#application.dsn#">
		SELECT objectid, label
		FROM farVerityCollection
		WHERE 
			collectionname = '#stprops.collectionname#'
			AND objectid <> '#stprops.objectid#'
		</cfquery>
		
		<cfif qCheckCollectionName.recordcount gt 0>
			<cfset stprops.collectionname="" />
			<cfdump var="#stprops#">
			<!--- 
			todo: server side validation message
			<cfoutput><p><strong>Error</strong>: #qCheckCollectionName.label# already has a collection of the same name.</p></cfoutput> 
			--->
		<cfelse>
			<cfset oVerity=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityservice").init() />
			<cfset verityResult=oVerity.createCollection(collection=stprops.collectionname) />
			<cfdump var="#verityResult#">
		</cfif>	
	</ft:processformobjects>
</ft:processform>

<ft:processform action="Save">
	<!--- update primary content item --->
	<ft:processformobjects typename="#URL.Typename#" />
	
	<!--- synchronise the settings for other members of lhosts --->
	<cfif len(application.stplugins.farcryverity.lhosts)>
		<cfquery datasource="#application.dsn#" name="qConfigs">
		SELECT objectid FROM farVerityCollection
		WHERE 
			collectionname = '#stobj.collectionname#'
			AND objectid <> '#stobj.objectid#'
		</cfquery>
		
		<cfloop query="qConfigs">
			<cfset stConfig=getData(objectid=qConfigs.objectid) />
			<cfset stUpdate=stobj />
			<!--- reset immutable properties --->
			<cfset stUpdate.hostname=stConfig.hostname />
			<cfset stUpdate.collectionpath=stConfig.collectionpath />
			<!--- <cfset stUpdate.builttodate=stConfig.builttodate /> --->
			<cfset setData(objectid=qConfigs.objectid, stproperties=stUpdate) />
		</cfloop>
	</cfif>
	
	<cfset resetActiveCollections() />
</ft:processform>

<ft:processform action="Save,Cancel" Exit="true" />


<!------------------------------- 
VIEW:
-------------------------------->
<ft:form>
<cfif len(stObj.collectionname)>
	<!--- only show index options if typename selected --->
	<ft:object legend="Configuration Options" lfields="title,indexTitle,lIndexProperties" stobject="#stObj#" format="edit" intable="false" />

	<cfoutput><div class="fieldwrap"></cfoutput>
		<ft:farcrybutton value="Save" /> 
		<ft:farcrybutton value="Cancel" />
	<cfoutput></div></cfoutput>
	
	<cfswitch expression="#stobj.collectiontype#">
		<cfcase value="file">
			<ft:object legend="File Configuration" lfields="fileproperty" stobject="#stObj#" format="edit" intable="false" />
		</cfcase>
		<cfcase value="cat">
			<ft:object legend="Category Configuration" lfields="catCollection" stobject="#stObj#" format="edit" intable="false" />
		</cfcase>
	</cfswitch>
	
	<ft:object legend="Advanced Configuration" lfields="custom3,custom4" stobject="#stObj#" format="edit" intable="false" />
	<ft:object legend="Operational Options" lfields="bEnableSearch,builttodate,collectionname,collectionpath,hostname" stobject="#stObj#" format="edit" intable="false" />
	<ft:object legend="Debug Options Only" lfields="collectiontype,collectiontypename" stobject="#stObj#" format="edit" intable="false" />
	
	<cfoutput><div class="fieldwrap"></cfoutput>
		<ft:farcrybutton value="Save" /> 
		<ft:farcrybutton value="Cancel" />
	<cfoutput></div></cfoutput>
<cfelse>
	<!--- force selection of typename --->
	<ft:object legend="Collection Creation" lfields="title,collectiontype,collectiontypename" stobject="#stObj#" format="edit" intable="false" />

	<cfoutput><div class="fieldwrap"></cfoutput>
		<ft:farcrybutton value="Create Collection" /> <ft:farcrybutton value="Cancel" />
	<cfoutput></div></cfoutput>

</cfif>
</ft:form>

<cfdump var="#stobj#">

<cfsetting enablecfoutputonly="no">