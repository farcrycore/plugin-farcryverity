<cfcomponent displayname="Search Form" hint="The search form for searching through the verity index" extends="farcry.core.packages.forms.forms" output="false">
	<cfproperty ftSeq="1" ftFieldset="General" name="criteria" type="string" default="" hint="The search text criteria" ftLabel="Search" />
	<cfproperty ftSeq="2" ftFieldset="General" name="operator" type="string" default="" hint="The operator used for the search" ftLabel="Search Operator" ftType="list" ftList="any:Any of these words,all:All of these words,phrase:These words as a phrase" />
	<cfproperty ftSeq="3" ftFieldset="General" name="lCollections" type="string" default="" hint="The collections to be searched" ftLabel="Collections" ftType="list" ftListData="getCollectionList" />
	
	
	<cffunction name="getCollectionList" access="public" output="false" returntype="string" hint="Returns a list used to populate the lCollections field dropdown selection">
		<cfargument name="objectid" required="true" hint="The objectid of this object" />
		
		<cfset var lResult = ":All Content" />
		<cfset var i = "" />
		<cfset var aAllCollections = application.stPlugins.farcryVerity.oVerityConfig.getCollectionArray() />
		
		<cfloop index="i" from="1" to="#arrayLen(aAllCollections)#">
			<cfset lResult = listAppend(lResult, "#aAllCollections[i].collectionname#:#aAllCollections[i].title#") />
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>
	

</cfcomponent>