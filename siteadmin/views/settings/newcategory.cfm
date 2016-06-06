<!---
<cfset OrganizationTypeAccountQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(OrganizationTypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "OptionName", "K12 School District")#>
<cfset temp = QueryAddRow(OrganizationTypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "OptionName", "Non-Profit Organization")#>
<cfset temp = QueryAddRow(OrganizationTypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "ID", 2)#>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "OptionName", "College/University Organization")#>
<cfset temp = QueryAddRow(OrganizationTypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "ID", 3)#>
<cfset temp = #QuerySetCell(OrganizationTypeAccountQuery, "OptionName", "Government Organization")#>
--->
<cfoutput>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>New Auction Category</h1></div>
		<cfform action="" method="post" id="CreateNewCategory" class="form-horizontal">
			<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
			<cfinput type="hidden" name="formSubmit" value="true">
			<div class="panel-body">
				<div class="form-group">
					<label for="CategoryName" class="control-label col-sm-3">Category Title:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="CategoryName" name="CategoryName" required="yes"></div>
				</div>
				<div class="form-group">
					<label for="CategoryParentID" class="control-label col-sm-3">Category Parent:&nbsp;</label>
					<div class="col-sm-8">
						<cfselect name="CategoryParentID" class="form-control" Required="Yes" Multiple="No" query="Session.getParentCategories" value="Category_ID" Display="Category_Name"  queryposition="below">
							<option value="0">Top Level Category</option>
						</cfselect>
					</div>
				</div>
			</div>
			<div class="panel-footer">
				<cfinput type="Submit" name="CreateCategory" class="btn btn-primary pull-right" value="Add New Category"><br /><br />
			</div>
		</cfform>
	</div>
</cfoutput>