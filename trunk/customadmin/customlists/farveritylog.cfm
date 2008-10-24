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
<admin:header title="Verity Search Log" />

<ft:objectadmin 
	typename="farVerityLog"
	permissionset="news"
	title="Verity Search Log"
	columnList="criteria,lcollections,results,datetimecreated"
	sortableColumns="criteria,lcollections,results,datetimecreated"
	lFilterFields="criteria,lcollections"
	sqlorderby="datetimecreated desc"
	plugin="farcryverity"
	module="customlists/farveritycollection.cfm"
	bFlowCol="false"
	bViewCol="false" />

<!--- setup footer --->
<admin:footer />