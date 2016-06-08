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
		<div class="panel-heading"><h1>New Location for Auction Surplus Items</h1></div>
		<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal">
			<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
			<cfinput type="hidden" name="OrganizationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
			<cfinput type="hidden" name="formSubmit" value="true">
			<div class="panel-body">
				<div class="form-group">
					<label for="LocationName" class="control-label col-sm-3">Location Name:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationName" name="LocationName" required="yes"></div>
				</div>
				<div class="form-group">
					<label for="PhysicalAddress" class="control-label col-sm-3">Physical Address:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalAddress" name="PhysicalAddress" required="yes"></div>
				</div>
				<div class="form-group">
					<label for="PhysicalCity" class="control-label col-sm-3">Physical City:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalCity" name="PhysicalCity" required="yes"></div>
				</div>
				<div class="form-group">
					<label for="PhysicalState" class="control-label col-sm-3">Physical State:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalState" name="PhysicalState" required="yes"></div>
				</div>
				<div class="form-group">
					<label for="PhysicalZipCode" class="control-label col-sm-3">Physical ZipCode:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalZipCode" name="PhysicalZipCode" required="yes"></div>
				</div>
				<div class="form-group">
					<label for="LocationPhone" class="control-label col-sm-3">Location Voice Number:&nbsp;</label>
					<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationPhone" name="LocationPhone" required="yes"></div>
				</div>
			</div>
			<div class="panel-footer">
				<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Create New Location"><br /><br />
			</div>
		</cfform>
	</div>
</cfoutput>