<cfset ItemConditionQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(ItemConditionQuery, 1)>
<cfset temp = #QuerySetCell(ItemConditionQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(ItemConditionQuery, "OptionName", "New")#>
<cfset temp = QueryAddRow(ItemConditionQuery, 1)>
<cfset temp = #QuerySetCell(ItemConditionQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(ItemConditionQuery, "OptionName", "Used")#>

<cfset AuctionDaysQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(AuctionDaysQuery, 1)>
<cfset temp = #QuerySetCell(AuctionDaysQuery, "ID", 7)#>
<cfset temp = #QuerySetCell(AuctionDaysQuery, "OptionName", "7 Days")#>
<cfset temp = QueryAddRow(AuctionDaysQuery, 1)>
<cfset temp = #QuerySetCell(AuctionDaysQuery, "ID", 14)#>
<cfset temp = #QuerySetCell(AuctionDaysQuery, "OptionName", "14 Days")#>
<cfset temp = QueryAddRow(AuctionDaysQuery, 1)>
<cfset temp = #QuerySetCell(AuctionDaysQuery, "ID", 30)#>
<cfset temp = #QuerySetCell(AuctionDaysQuery, "OptionName", "30 Days")#>

<cfset AuctionTypeQuery = QueryNew("ID,OptionName", "VarChar,VarChar")>
<cfset temp = QueryAddRow(AuctionTypeQuery, 1)>
<cfset temp = #QuerySetCell(AuctionTypeQuery, "ID", "Fixed")#>
<cfset temp = #QuerySetCell(AuctionTypeQuery, "OptionName", "Fixed Price")#>
<cfset temp = QueryAddRow(AuctionTypeQuery, 1)>
<cfset temp = #QuerySetCell(AuctionTypeQuery, "ID", "Auction")#>
<cfset temp = #QuerySetCell(AuctionTypeQuery, "OptionName", "Auction Style")#>

<cfoutput>
	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/field-wordcounter.js"></script>
	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/jquery-ui-1.9.2.custom.min.js"></script>

	<div class="panel panel-default">
		<cfif not isDefined("URL.FormRetry") and not isDefined("URL.AuctionType")>
			<div class="panel-heading"><h1>Add Auction Item</h1></div>
			<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal" enctype="multipart/form-data">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="OrganizationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<br /><br />
				<div class="alert alert-info">When completing this form to add a new auction item, please be very descriptive in your information for this item. Buyers make decisions on whether to purchase the item from the pictures, item description to research the potiential value of the item. If the buyer comes to view the item and it does not meet the information listed below the buyer can dispute this if they were the highest bidder or simply not bid on the item which will result in loss revenue for you.</div>
				<div class="panel-body">
					<cfif Session.getLocations.RecordCount>
						<div class="panel-heading"><h1>Location of Auction Item</h1></div>
						<div class="form-group">
							<cfinput type="hidden" name="LocationIDParent" value="false">
							<label for="LocationID" class="control-label col-sm-3">Location:&nbsp;</label>
							<div class="col-sm-8"><cfselect name="LocationID" class="form-control" Required="Yes" Multiple="No" query="Session.getLocations" value="TContent_ID" Display="LocationName"  queryposition="below">
								<option value="0">#Session.getSellerOrganizationInfo.BusinessName#</option>
							</cfselect></div>
						</div>
					<cfelse>
						<div class="panel-heading"><h1>Location of Auction Item</h1></div>
						<div class="form-group">
							<cfinput type="hidden" name="LocationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
							<cfinput type="hidden" name="LocationIDParent" value="true">
							<label for="LocationID" class="control-label col-sm-3">Location:&nbsp;</label>
							<div class="col-sm-8"><label for="LocationID" class="control-label">#Session.getSellerOrganizationInfo.BusinessName# (#Session.getSellerOrganizationInfo.PhysicalAddress# #Session.getSellerOrganizationInfo.PhysicalCity#, #Session.getSellerOrganizationInfo.PhysicalState# #Session.getSellerOrganizationInfo.PhysicalZipCode#)</label></div>
						</div>
					</cfif>
					<div class="panel-heading"><h1>Item Detail Information</h1></div>
					<div class="form-group">
						<label for="ItemName" class="control-label col-sm-3">Item Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemName" name="ItemName" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="ItemModelNumber" class="control-label col-sm-3">Item Model Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemModelNumber" name="ItemModelNumber" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="ItemUPC" class="control-label col-sm-3">Item UPC:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemUPC" name="ItemUPC" required="no"></div>
					</div>
					<div class="form-group">
						<label for="ItemDescription" class="control-label col-sm-3">Item Description:&nbsp;</label>
						<div class="col-sm-8">
							<textarea class="form-control" id="ItemDescription" name="ItemDescription" rows="10" required="true"></textarea>
							<script type="text/javascript">
								$("textarea").textareaCounter({limit: 1000});
							</script>
						</div>
					</div>
					<div class="form-group">
						<label for="ItemCondition" class="control-label col-sm-3">Item Condition:&nbsp;</label>
						<div class="col-sm-8"><cfselect name="ItemCondition" class="form-control" Required="Yes" Multiple="No" query="Variables.ItemConditionQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect></div>
					</div>
					<div class="form-group">
						<label for="ItemPrimaryPhoto" class="control-label col-sm-3">Primary Photo:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="file" class="form-control" id="ItemPrimaryPhoto" name="ItemPrimaryPhoto" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="ItemSecondaryPhoto" class="control-label col-sm-3">Secondary Photo:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="file" class="form-control" id="ItemSecondaryPhoto" name="ItemSecondaryPhoto" required="no"></div>
					</div>
					<div class="form-group">
						<label for="ItemTertiaryPhoto" class="control-label col-sm-3">Tertiary Photo:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="file" class="form-control" id="ItemTertiaryPhoto" name="ItemTertiaryPhoto" required="no"></div>
					</div>
					<br /><br />
					<div class="panel-heading"><h1>Auction Starting Information</h1></div>
					<div class="form-group">
						<label for="AuctionStartDate" class="control-label col-sm-3">Start Date:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="AuctionStartDate" name="AuctionStartDate" required="yes"></div>
						<script>
							$(function() {
								$("##AuctionStartDate").datepicker();
							});
						</script>
					</div>
					<div class="form-group">
						<label for="AuctionLength" class="control-label col-sm-3">Auction Days:&nbsp;</label>
						<div class="col-sm-8"><cfselect name="AuctionLength" class="form-control" Required="Yes" Multiple="No" query="Variables.AuctionDaysQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect></div>
					</div>
					<div class="form-group">
						<label for="AuctionCategory" class="control-label col-sm-3">Category:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="AuctionCategory" class="form-control" Required="Yes" Multiple="No" query="Session.CategoryQuery" value="ID" Display="CategoryName"  queryposition="below"></cfselect>
						</div>
					</div>
					<div class="form-group">
						<label for="AuctionType" class="control-label col-sm-3">Auction Type:&nbsp;</label>
						<!--- Fixed or Auction Style --->
						<div class="col-sm-8">
							<cfselect name="AuctionType" class="form-control" Required="Yes" Multiple="No" query="AuctionTypeQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect>
						</div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Add Auction Item"><br /><br />
				</div>
			</cfform>
		<cfelseif isDefined("URL.FormRetry") and not isDefined("URL.AuctionType")>
			<div class="panel-heading"><h1>Add Auction Item</h1></div>
			<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal" enctype="multipart/form-data">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="OrganizationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<br /><br />
				<div class="alert alert-info">When completing this form to add a new auction item, please be very descriptive in your information for this item. Buyers make decisions on whether to purchase the item from the pictures, item description to research the potiential value of the item. If the buyer comes to view the item and it does not meet the information listed below the buyer can dispute this if they were the highest bidder or simply not bid on the item which will result in loss revenue for you.</div>
				<div class="panel-body">
					<cfif Session.getLocations.RecordCount>
						<div class="panel-heading"><h1>Location of Auction Item</h1></div>
						<div class="form-group">
							<cfinput type="hidden" name="LocationIDParent" value="false">
							<label for="LocationID" class="control-label col-sm-3">Location:&nbsp;</label>
							<div class="col-sm-8"><cfselect name="LocationID" class="form-control" Required="Yes" Multiple="No" selected="#Session.FormData.LocationID#" query="Session.getLocations" value="TContent_ID" Display="LocationName"  queryposition="below">
								<option value="0">#Session.getSellerOrganizationInfo.BusinessName#</option>
							</cfselect></div>
						</div>
					<cfelse>
						<div class="panel-heading"><h1>Location of Auction Item</h1></div>
						<div class="form-group">
							<cfinput type="hidden" name="LocationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
							<cfinput type="hidden" name="LocationIDParent" value="true">
							<label for="LocationID" class="control-label col-sm-3">Location:&nbsp;</label>
							<div class="col-sm-8"><label for="LocationID" class="control-label">#Session.getSellerOrganizationInfo.BusinessName# (#Session.getSellerOrganizationInfo.PhysicalAddress# #Session.getSellerOrganizationInfo.PhysicalCity#, #Session.getSellerOrganizationInfo.PhysicalState# #Session.getSellerOrganizationInfo.PhysicalZipCode#)</label></div>
						</div>
					</cfif>
					<div class="panel-heading"><h1>Item Detail Information</h1></div>
					<div class="form-group">
						<label for="ItemName" class="control-label col-sm-3">Item Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemName" value="#Session.FormData.ItemName#" name="ItemName" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="ItemModelNumber" class="control-label col-sm-3">Item Model Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemModelNumber" value="#Session.FormData.ItemName#" name="ItemModelNumber" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="ItemUPC" class="control-label col-sm-3">Item UPC:&nbsp;</label>
						<div class="col-sm-8">
							<cfif isDefined("Session.FormData.ItemUPC")>
								<cfinput type="text" class="form-control" id="ItemUPC" name="ItemUPC" value="#session.FormData.ItemUPC#" required="no">
							<cfelse>
								<cfinput type="text" class="form-control" id="ItemUPC" name="ItemUPC" required="no">
							</cfif>
						</div>
					</div>
					<div class="form-group">
						<label for="ItemDescription" class="control-label col-sm-3">Item Description:&nbsp;</label>
						<div class="col-sm-8">
							<textarea class="form-control" id="ItemDescription" name="ItemDescription" rows="10" required="true">#Session.FormData.ItemDescription#</textarea>
							<script type="text/javascript">
								$("textarea").textareaCounter({limit: 1000});
							</script>
						</div>
					</div>
					<div class="form-group">
						<label for="ItemCondition" class="control-label col-sm-3">Item Condition:&nbsp;</label>
						<div class="col-sm-8"><cfselect name="ItemCondition" class="form-control" Required="Yes" selected="#Session.FormData.ItemCondition#" Multiple="No" query="Variables.ItemConditionQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect></div>
					</div>
					<div class="form-group">
						<label for="ItemPrimaryPhoto" class="control-label col-sm-3">Primary Photo:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="file" class="form-control" id="ItemPrimaryPhoto" value="#Session.FormData.ItemPrimaryPhoto#" name="ItemPrimaryPhoto" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="ItemSecondaryPhoto" class="control-label col-sm-3">Secondary Photo:&nbsp;</label>
						<div class="col-sm-8">
							<cfif Len(FORM.ItemSecondaryPhoto)>
								<cfinput type="file" class="form-control" id="ItemSecondaryPhoto" value="#Session.FormData.ItemSecondaryPhoto#" name="ItemSecondaryPhoto" required="no">
							<cfelse>
								<cfinput type="file" class="form-control" id="ItemSecondaryPhoto" name="ItemSecondaryPhoto" required="no">
							</cfif>
						</div>
					</div>
					<div class="form-group">
						<label for="ItemTertiaryPhoto" class="control-label col-sm-3">Tertiary Photo:&nbsp;</label>
						<div class="col-sm-8">
							<cfif LEN(FORM.ItemTertiaryPhoto)>
								<cfinput type="file" class="form-control" id="ItemTertiaryPhoto" value="#Session.FormData.ItemTertiaryPhoto#" name="ItemTertiaryPhoto" required="no">
							<cfelse>
								<cfinput type="file" class="form-control" id="ItemTertiaryPhoto" name="ItemTertiaryPhoto" required="no">
							</cfif>
						</div>
					</div>
					<br /><br />
					<div class="panel-heading"><h1>Auction Starting Information</h1></div>
					<div class="form-group">
						<label for="AuctionStartDate" class="control-label col-sm-3">Start Date:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="AuctionStartDate" value="#Session.FormData.AuctionStartDate#" name="AuctionStartDate" required="yes"></div>
						<script>
							$(function() {
								$("##AuctionStartDate").datepicker();
							});
						</script>
					</div>
					<div class="form-group">
						<label for="AuctionLength" class="control-label col-sm-3">Auction Days:&nbsp;</label>
						<div class="col-sm-8"><cfselect name="AuctionLength" class="form-control" selected="#Session.FormData.AuctionLength#" Required="Yes" Multiple="No" query="Variables.AuctionDaysQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect></div>
					</div>
					<div class="form-group">
						<label for="AuctionCategory" class="control-label col-sm-3">Category:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="AuctionCategory" class="form-control" selected="#Session.FormData.AUctionCategory#" Required="Yes" Multiple="No" query="Session.CategoryQuery" value="ID" Display="CategoryName"  queryposition="below"></cfselect>
						</div>
					</div>
					<div class="form-group">
						<label for="AuctionType" class="control-label col-sm-3">Auction Type:&nbsp;</label>
						<!--- Fixed or Auction Style --->
						<div class="col-sm-8">
							<cfselect name="AuctionType" class="form-control" Required="Yes" selected="#Session.FormData.AUctionType#" Multiple="No" query="AuctionTypeQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect>
						</div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Add Auction Item"><br /><br />
				</div>
			</cfform>

		<cfelseif isDefined("URL.AuctionID") and isDefined("URL.AuctionType")>
			<cfswitch expression="#URL.AuctionType#">
				<cfcase value="Fixed">
					<div class="panel-heading"><h1>Add Auction Additional Information</h1></div>
					<br /><br />
					<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal">
						<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
						<cfinput type="hidden" name="AuctionID" value="#URL.AuctionID#">
						<cfinput type="hidden" name="AuctionType" value="#URL.AuctionType#">
						<cfinput type="hidden" name="UpdateAuctionInfo" value="true">
						<cfinput type="hidden" name="formSubmit" value="true">
						<div class="panel-body">
							<div class="form-group">
								<label for="AuctionStartPrice" class="control-label col-sm-3">Buy Now Price:&nbsp;</label>
								<div class="col-sm-8">
									<cfinput type="text" class="form-control" id="AuctionStartPrice" name="AuctionStartPrice" required="yes" maxlength="9" validate="regular_expression" pattern="/^[0-9]+(\.[0-9]{0,2})?$/">
								</div>
							</div>
						</div>
						<div class="panel-footer">
							<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Add Auction Additional Information"><br /><br />
						</div>
					</cfform>
				</cfcase>
				<cfcase value="Auction">

				</cfcase>
			</cfswitch>
		</cfif>
	</div>
</cfoutput>