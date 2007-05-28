<cfsetting enablecfoutputonly="true">

<cfimport prefix="ft" taglib="/farcry/core/tags/formtools" />

<!------------------------------- 
ACTION:
-------------------------------->
<ft:processform action="Create Collection" url="refresh">
	<!--- primary content item --->
	<ft:processformobjects typename="#URL.Typename#" r_stproperties="stprops">
		<cfset stprops.hostname=application.sysinfo.machinename />
		<cfset stprops.collectionname=application.applicationname & "_" & stprops.collectiontypename />
		<cfset stprops.collectionname=lcase(stprops.collectionname) />
	</ft:processformobjects>

	<cfset oVerity=createobject("component", "farcry.plugins.farcryverity.packages.custom.verityservice").init() />
	<cfset stresult=oVerity.createCollection(collection=stprops.collectionname) />

</ft:processform>

<ft:processform action="Save">
	<!--- primary content item --->
	<ft:processformobjects typename="#URL.Typename#" />
</ft:processform>

<ft:processform action="Save,Cancel" Exit="true" />


<!------------------------------- 
VIEW:
-------------------------------->
<ft:form>
<cfif len(stObj.collectiontypename)>
	<!--- only show index options if typename selected --->
	<ft:object legend="Configuration Options" lfields="title,indexTitle,lIndexProperties" stobject="#stObj#" format="edit" intable="false" />

	<cfoutput><div class="fieldwrap"></cfoutput>
		<ft:farcrybutton value="Save" /> 
		<ft:farcrybutton value="Cancel" />
	<cfoutput></div></cfoutput>
	
	<ft:object legend="Advanced Configuration" lfields="custom3,custom4,fileproperty" stobject="#stObj#" format="edit" intable="false" />
	<ft:object legend="Operational Options" lfields="bEnableSearch,builttodate,collectionname,collectionpath,hostname" stobject="#stObj#" format="edit" intable="false" />
	<ft:object legend="Debug Options Only" lfields="collectiontypename" stobject="#stObj#" format="edit" intable="false" />
	
	<cfoutput><div class="fieldwrap"></cfoutput>
		<ft:farcrybutton value="Save" /> 
		<ft:farcrybutton value="Cancel" />
	<cfoutput></div></cfoutput>
<cfelse>
	<!--- force selection of typename --->
	<ft:object legend="Collection Details" lfields="title,collectiontypename" stobject="#stObj#" format="edit" intable="false" />

	<cfoutput><div class="fieldwrap"></cfoutput>
		<ft:farcrybutton value="Create Collection" /> <ft:farcrybutton value="Cancel" />
	<cfoutput></div></cfoutput>

</cfif>
</ft:form>

<cfdump var="#stobj#">

<cfsetting enablecfoutputonly="no">