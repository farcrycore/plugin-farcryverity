<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION || 
$Description: farVerityCollection Type 
Configuration object for Verity Search Collections
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="farcry.core.packages.types.types" displayname="Verity Collection" hint="Configuration object for Verity free text search collection." bSchedule="false" bFriendly="false">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftseq="1" ftfieldset="Collection Details" name="title" type="string" hint="Collection title." required="no" default="" ftlabel="Title" ftvalidation="required" />
<cfproperty ftseq="2" ftfieldset="Collection Details" name="collectiontypename" type="string" hint="Collection content type." required="no" default="" fttype="list" ftrendertype="dropdown" ftlistdata="getContentTypes" ftlabel="Content Type" />
<cfproperty ftseq="3" ftfieldset="Collection Details" name="collectionname" type="string" hint="Verity/ColdFusion collection name." required="no" default="" ftlabel="Collection Name" ftdisplayonly="true" />
<cfproperty ftseq="5" ftfieldset="Collection Details" name="collectionpath" type="string" hint="Absolute path to the collection stem on the host." required="no" default="" ftlabel="Collection Path" ftdisplayonly="true" />
<cfproperty ftseq="6" ftfieldset="Collection Details" name="hostname" type="string" hint="Host the collection physically resides on." required="no" default="" ftlabel="Hostname" ftdisplayonly="true" />

<cfproperty ftseq="21" ftfieldset="Searchable Properties" name="indexTitle" type="string" hint="Field used to populate result title." required="no" default="" fttype="list" ftlistdata="getIndexTitles" ftlabel="Result Title" />
<cfproperty ftseq="22" ftfieldset="Searchable Properties" name="lIndexProperties" type="longchar" hint="List of property fields to be indexed in BODY. Restricted to string and longchar fields." required="no" default="" fttype="list" ftrendertype="checkbox" ftSelectMultiple="true" ftlistdata="getIndexStrings" ftlabel="Indexed Properties" />

<cfproperty ftseq="41" ftfieldset="Advanced Options" name="custom3" type="date" hint="Custom3 field hijack for a single date property; for example, publishdate." required="no" default="" fttype="list" ftlistdata="getIndexDates" ftlabel="Date Filter" />
<cfproperty ftseq="42" ftfieldset="Advanced Options" name="custom4" type="string" hint="Custom4 field hijack for a single string/longchar property; for example, lauthors." required="no" default="" fttype="list" ftlistdata="getIndexMisc" ftlabel="Miscellaneous Filter" />
<cfproperty ftseq="43" ftfieldset="Advanced Options" name="fileproperty" type="string" hint="Associated file collection will be based on this filepath property if activated." required="no" default="" fttype="list" ftlistdata="getIndexFilePaths" ftlabel="File Collection" />

<cfproperty ftseq="61" ftfieldset="Operational" name="builttodate" type="date" hint="The date the collection was last built to.  Can be manually overridden to force collection to update from the specified point, based on typename datetimelastupdated." required="yes" default="1970-01-01" fttype="datetime" ftlabel="Built To date" />
<cfproperty ftseq="62" ftfieldset="Operational" name="bEnableSearch" type="boolean" hint="Enable search; by default new collections start as disabled." required="no" default="" ftlabel="Enable Search?" />

<!------------------------------------------------------------------------
object methods 

edit()
 - select typename; once selected hostname/typename/collectionname set in stone
 - edit other fields

verity maintenance methods (maybe move to verityservice.cfc)
---------------------------
createCollection(); only if hostname matches current host
deleteCollection(); only if hostname matches current host
optimiseColection(); only if hostname matches current host
optimiseAllCollections()
getCollectionList()
getCollection()

update requirements
---------------------------
beforeSave(); update hostname
afterSave(); synch with other host collections
------------------------------------------------------------------------->



	
<!------------------------------------------------------------------------
formtool methods
------------------------------------------------------------------------->	
<cffunction name="ftdisplaylIndexProperties" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
	<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	<cfset var html = "" />
	<cfset var i = 0 />
	
	<cfparam name="arguments.stMetadata.ftList" default="" />
	
	<!--- make upper case and put in a space for better display --->
	<cfsavecontent variable="html">
	<cfloop list="#arguments.stmetadata.value#" index="i">
		<cfif i eq listLast(arguments.stmetadata.value)>
			<cfoutput>#uCase(i)#</cfoutput>
		<cfelse>
			<cfoutput>#uCase(i)#, </cfoutput>
		</cfif>
	</cfloop>
	</cfsavecontent>
	
	<cfreturn html>
</cffunction>


<!------------------------------------------------------------------------
library methods
------------------------------------------------------------------------->	
<cffunction name="getContentTypes" access="public" hint="Get list of all searchable content types." output="false" returntype="string">
	<cfset var listdata = "" />
	<cfset var qListData = queryNew("typename,displayname") />
	
	<cfloop collection="#application.types#" item="type">
		<cfset queryAddRow(qListData) />
		<cfset querySetCell(qListData, "typename", type) />
		<cfset querySetCell(qListData, "displayname", application.stcoapi[type].displayname) />
	</cfloop>
	
	<cfloop query="qListData">
		<cfset listdata = listAppend(listdata, "#qlistdata.typename#:#qlistdata.displayname#") />
	</cfloop>
	
	<cfreturn listData />
</cffunction>

<cffunction name="getIndexStrings" access="public" hint="Get list of all indexable string properties for a specific content type." output="false" returntype="string">
	<cfargument name="objectid" required="true" type="uuid" />
	
	<cfset var stobj = getData(arguments.objectid) />
	<cfset var listdata = "" />
	<cfset var qListData = getIndexProperties(stobj.collectiontypename) />
	
	<!--- filter for appropriate data types --->
	<cfquery dbtype="query" name="qListData">
	SELECT property, fttype
	FROM qListData
	WHERE datatype IN ('string','nstring','longchar')
	</cfquery>
	
	<cfloop query="qListData">
		<cfset listdata = listAppend(listdata, "#qlistdata.property#:#qlistdata.property# (#qlistdata.fttype#)") />
	</cfloop>
	
	<cfreturn listData />
</cffunction>

<cffunction name="getIndexTitles" access="public" hint="Get list of all indexable string properties (without longchar) for a specific content type." output="false" returntype="string">
	<cfargument name="objectid" required="true" type="uuid" />
	
	<cfset var stobj = getData(arguments.objectid) />
	<cfset var listdata = "" />
	<cfset var qListData = getIndexProperties(stobj.collectiontypename) />
	
	<!--- filter for appropriate data types --->
	<cfquery dbtype="query" name="qListData">
	SELECT property, fttype
	FROM qListData
	WHERE datatype IN ('string','nstring')
	</cfquery>
	
	<cfloop query="qListData">
		<cfset listdata = listAppend(listdata, "#qlistdata.property#:#qlistdata.property# (#qlistdata.fttype#)") />
	</cfloop>
	
	<cfreturn listData />
</cffunction>

<cffunction name="getIndexDates" access="public" hint="Get list of all indexable date properties for a specific content type." output="false" returntype="string">
	<cfargument name="objectid" required="true" type="uuid" />
	
	<cfset var stobj = getData(arguments.objectid) />
	<cfset var listdata = ":None specified" />
	<cfset var qListData = getIndexProperties(stobj.collectiontypename) />
	
	<!--- filter for appropriate data types --->
	<cfquery dbtype="query" name="qListData">
	SELECT property
	FROM qListData
	WHERE datatype = 'date'
	</cfquery>
	
	<cfloop query="qListData">
		<cfset listdata = listAppend(listdata, "#qlistdata.property#:#qlistdata.property#") />
	</cfloop>
	
	<cfreturn listData />
</cffunction>

<cffunction name="getIndexMisc" access="public" hint="Get list of all indexable properties for a specific content type." output="false" returntype="string">
	<cfargument name="objectid" required="true" type="uuid" />
	
	<cfset var stobj = getData(arguments.objectid) />
	<cfset var listdata = ":None specified" />
	<cfset var qListData = getIndexProperties(stobj.collectiontypename) />
	
	<!--- filter for appropriate data types --->
	<cfquery dbtype="query" name="qListData">
	SELECT property
	FROM qListData
	</cfquery>
	
	<cfloop query="qListData">
		<cfset listdata = listAppend(listdata, "#qlistdata.property#:#qlistdata.property#") />
	</cfloop>
	
	<cfreturn listData />
</cffunction>

<cffunction name="getIndexFilePaths" access="public" hint="Get list of all indexable file path properties for a specific content type." output="false" returntype="string">
	<cfargument name="objectid" required="true" type="uuid" />
	
	<cfset var stobj = getData(arguments.objectid) />
	<cfset var listdata = ":None specified" />
	<cfset var qListData = getIndexProperties(stobj.collectiontypename) />
	
	<!--- filter for appropriate data types --->
	<cfquery dbtype="query" name="qListData">
	SELECT property
	FROM qListData
	WHERE fttype = 'file'
	</cfquery>
	
	<cfloop query="qListData">
		<cfset listdata = listAppend(listdata, "#qlistdata.property#:#qlistdata.property#") />
	</cfloop>
	
	<cfreturn listData />
</cffunction>



<cffunction name="getIndexProperties" access="private" hint="Get query of all indexable properties for a specific content type." output="false" returntype="query">
	<cfargument name="typename" required="true" type="string" />
	
	<cfset var qlistdata=queryNew("property,datatype,fttype") />
	<cfset var prop="" />
	
	<cfif NOT structkeyexists(application.stcoapi, arguments.typename)>
		<cfthrow type="Application" errorcode="plugins.farcryverity.packages.types.farveritycollection" message="Typename (#arguments.typename#) is invalid." detail="The typename must be available in the application in order to build a collection." />
	</cfif>
	
	<cfloop collection="#application.stcoapi[arguments.typename].stProps#" item="prop">
		<cfif ListFindNoCase("string,nstring,longchar,date", application.stcoapi[arguments.typename].stProps[prop].metadata.type)>
			<cfset queryAddRow(qListData) />
			<cfset querySetCell(qListData, "property", prop) />
			<cfset querySetCell(qListData, "datatype", application.stcoapi[arguments.typename].stProps[prop].metadata.type) />
			<cfset querySetCell(qListData, "fttype", application.stcoapi[arguments.typename].stProps[prop].metadata.fttype) />
		</cfif>
	</cfloop>
	
	<!--- filter out inappropriate system attributes --->
	<cfquery dbtype="query" name="qListData">
	SELECT property, datatype, fttype
	FROM qListData
	WHERE property NOT IN ('displayMethod','status','commentlog','ownedby','createdby','lockedBy','lastupdatedby')
	ORDER BY property
	</cfquery>
	
	<cfreturn qlistdata />
</cffunction>

</cfcomponent>