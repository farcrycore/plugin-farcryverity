<cfsetting enablecfoutputonly="true" />

<!--- required includes --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:form>
	<ft:object objectid="#stobj.objectid#" typename="farVeritySearch" IncludeFieldSet="false" prefix="searchFormPrefix"  />
	<ft:farcryButtonPanel>
		<ft:button value="Search" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />