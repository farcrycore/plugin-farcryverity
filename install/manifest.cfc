<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<!--- IMPORT TAG LIBRARIES --->
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	
	
	<cfset this.name = "FarCry Verity" />
	<cfset this.description = "Website Search Service Running on Verity" />
	<cfset this.lRequiredPlugins = "" />
	<cfset addSupportedCore(majorVersion="5", minorVersion="1", patchVersion="0") />
		
	
	<cffunction name="install" output="true">
		
		<cfset var result = "DONE" />
		
		<cfset result = createContent() />
				
		
		<cfreturn result />
	</cffunction>
	
		
	

</cfcomponent>

