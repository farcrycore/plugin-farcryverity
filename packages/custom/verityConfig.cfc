<cfcomponent displayname="Verity Config" hint="Configuration bean for verity plugin." output="false">

	<cfproperty name="storagePath" displayname="Storage Path" hint="Verity collection storage path; file path from drive." type="string" default="c:\coldfusionverity\collections" />
	<cfproperty name="aCollections" displayname="Collections" hint="Array of active collections." type="array" />
	<cfproperty name="lCollections" displayname="Collections" hint="List of active collections." type="string" />

	<!--- pseudo constructor --->
	<cfset storagePath="" />
	<cfset aCollections=arrayNew(1) />
	<cfset lCollections="" />
	<cfset hostname=createObject("java", "java.net.InetAddress").localhost.getHostName() />

	<cffunction name="init" access="public" output="false" returntype="verityConfig">
		<cfset setCollectionArray() />
		<cfset setCollectionList() />
		<cfreturn this />
	</cffunction>

	<cffunction name="getStoragePath" access="public" output="false" returntype="string">
		<cfreturn storagePath />
	</cffunction>

	<cffunction name="setStoragePath" access="public" output="false" returntype="void">
		<cfargument name="storagePath" type="string" required="true" />
		<cfset storagePath = arguments.storagePath />
		<cfreturn />
	</cffunction>

	<cffunction name="getCollectionArray" access="public" output="false" returntype="array">
		<cfreturn aCollections />
	</cffunction>

	<cffunction name="setCollectionArray" access="public" output="false" returntype="void">
		<cfset var qCollections=getCollections() />
		<cfset var st=structNew() />
		<cfset variables.aCollections = arrayNew(1) />
		
		<cfloop query="qCollections">
			<cfset st=structNew() />
			<cfset st.configid=qCollections.configid />
			<cfset st.title=qCollections.title />
			<cfset st.collectionname=qCollections.collectionname />
			<cfset arrayAppend(aCollections, st) />
		</cfloop>
		<cfreturn />
	</cffunction>

	<cffunction name="getCollectionList" access="public" output="false" returntype="string">
		<cfreturn lCollections />
	</cffunction>

	<cffunction name="setCollectionList" access="public" output="false" returntype="void">
		<cfset var qCollections=getCollections() />
		<cfset lCollections = valuelist(qCollections.collectionname) />
		<cfreturn />
	</cffunction>

	<cffunction name="getCollections" access="private" output="false" returntype="query">
		<cfset var qCollections=queryNew("configid, title, collectionname")>
		
		<cfquery datasource="#application.dsn#" name="qCollections">
		SELECT objectid AS configid, title, collectionname
		FROM farVerityCollection
		WHERE bEnableSearch = 1
		AND hostname = '#variables.hostname#'
		ORDER BY title
		</cfquery>
		
		<cfreturn qCollections />
	</cffunction>
	
</cfcomponent>