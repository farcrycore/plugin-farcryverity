<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!----------------------------------------
ENVIRONMENT
----------------------------------------->

<!----------------------------------------
ACTION
----------------------------------------->

<!----------------------------------------
VIEW
----------------------------------------->
<!--- set up page header --->
<admin:header title="Verity Collections" />

<ft:objectadmin 
	typename="farVerityCollection"
	permissionset="news"
	title="Verity Collections: All Hosts"
	columnList="title,collectiontypename,hostname,builttodate,lIndexProperties,benablesearch,collectiontype"
	sortableColumns="title,collectiontypename,hostname,builttodate"
	lFilterFields="title,hostname"
	sqlorderby="datetimelastupdated desc"
	plugin="farcryverity"
	module="customlists/farveritycollectionall.cfm"
	bFlowCol="false"
	bViewCol="false" />

<!--- setup footer --->
<admin:footer />