<cfset ItemConditionQuery = QueryNew("ID,OptionName", "VarChar,VarChar")>
<cfset temp = QueryAddRow(ItemConditionQuery, 1)>
<cfset temp = #QuerySetCell(ItemConditionQuery, "ID", "New")#>
<cfset temp = #QuerySetCell(ItemConditionQuery, "OptionName", "New")#>
<cfset temp = QueryAddRow(ItemConditionQuery, 1)>
<cfset temp = #QuerySetCell(ItemConditionQuery, "ID", "Used")#>
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

<cfset AuctionAvailableQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(AuctionAvailableQuery, 1)>
<cfset temp = #QuerySetCell(AuctionAvailableQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(AuctionAvailableQuery, "OptionName", "Yes")#>
<cfset temp = QueryAddRow(AuctionAvailableQuery, 1)>
<cfset temp = #QuerySetCell(AuctionAvailableQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(AuctionAvailableQuery, "OptionName", "No")#>

<cfoutput>
	<link rel="stylesheet" href="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/plupload/js/jquery.ui.plupload/css/jquery.ui.plupload.css" type="text/css" />

	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/field-wordcounter.js"></script>
	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/jquery-ui-1.9.2.custom.min.js"></script>
	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/plupload/js/plupload.full.min.js"></script>
	<script type="text/javascript" src="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/js/plupload/js/jquery.ui.plupload/jquery.ui.plupload.js"></script>

	<div class="panel panel-default">
		<cfif not isDefined("URL.FormRetry") and not isDefined("URL.AuctionType")>
			<div class="panel-heading"><h1>Add Auction Item</h1></div>
			<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal dropzone" enctype="multipart/form-data">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="OrganizationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<div class="panel-body">
					<br /><br />
					<div class="alert alert-info">When completing this form to add a new auction item, please be very descriptive in your information for this item. Buyers make decisions on whether to purchase the item from the pictures and item description. If the item description does not accuratly describe the item, the buyer might not complete the transaction or request a refund. If the buyer comes to view the item and it does not meet the information listed below the buyer can dispute this if they were the highest bidder or simply not bid on the item which will result in loss revenue for you.</div>
				</div>
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
						<label for="SiteAssetTag" class="control-label col-sm-3">Asset Tag Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="SiteAssetTag" name="SiteAssetTag" required="no"></div>
					</div>
					<div class="form-group">
						<label for="ItemUPC" class="control-label col-sm-3">Item UPC:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemUPC" name="ItemUPC" required="no"></div>
					</div>
					<div class="form-group">
						<label for="YearsInService" class="control-label col-sm-3">Item Years in Service:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="YearsInService" name="YearsInService" required="no"></div>
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
					<br /><br />
					<div class="panel-heading"><h1>Manufacturer Information</h1></div>
					<div class="alert alert-info">If you know of any information from the Manufacturer that is online where a potential buyer can view specifications, description of item, etc. Please enter that website address in the field below.</div>
					<div class="form-group">
						<label for="ItemWebsite" class="control-label col-sm-3">Item Website:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ItemWebsite" name="ItemWebsite" required="no"></div>
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
					<br /><br />
					<div class="alert alert-info">An Item with Auction Style will give bidders the opportunity to bid against each other to raise the price of an item. A Fixed Price Auction will set a firm price on an auction item.</div>
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
						<label for="SiteAssetTag" class="control-label col-sm-3">Asset Tag Number:&nbsp;</label>
						<div class="col-sm-8">
							<cfif isDefined("Session.FormData.ItemUPC")>
								<cfinput type="text" class="form-control" id="SiteAssetTag" name="SiteAssetTag" value="#Session.FormData.SiteAssetTag#" required="no">
							<cfelse>
								<cfinput type="text" class="form-control" id="SiteAssetTag" name="SiteAssetTag" required="no">
							</cfif>
						</div>
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
						<label for="YearsInService" class="control-label col-sm-3">Item Years in Service:&nbsp;</label>
						<div class="col-sm-8">
							<cfif isDefined("Session.FormData.YearsInService")>
								<cfinput type="text" class="form-control" id="YearsInService" name="YearsInService" value="#Session.FormData.YearsInService#" required="no">
							<cfelse>
								<cfinput type="text" class="form-control" id="YearsInService" name="YearsInService" required="no">
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
					<br /><br />
					<div class="panel-heading"><h1>Manufacturer Information</h1></div>
					<div class="alert alert-info">If you know of any information from the Manufacturer that is online where a potential buyer can view specifications, description of item, etc. Please enter that website address in the field below.</div>
					<div class="form-group">
						<label for="ItemWebsite" class="control-label col-sm-3">Item Website:&nbsp;</label>
						<div class="col-sm-8">
							<cfif isDefined("Session.FormData.ItemWebsite")>
								<cfinput type="text" class="form-control" id="ItemWebsite" name="ItemWebsite" value="#Session.FormData.ItemWebsite#" required="no">
							<cfelse>
								<cfinput type="text" class="form-control" id="ItemWebsite" name="ItemWebsite" required="no">
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
				<cfcase value="Auction">
					<div class="panel-heading"><h1>Add Auction Additional Information</h1></div>
					<br /><br />
					<cfform action="" method="post" id="AuctionAdditionalInfo" class="form-horizontal" enctype="multipart/form-data">
						<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
						<cfinput type="hidden" name="AuctionID" value="#URL.AuctionID#">
						<cfinput type="hidden" name="AuctionType" value="#URL.AuctionType#">
						<cfinput type="hidden" name="UpdateAuctionInfo" value="true">
						<cfinput type="hidden" name="formSubmit" value="true">
						<div class="panel-body">
							<div class="form-group">
								<label for="AuctionStartPrice" class="control-label col-sm-3">Starting Bid Price:&nbsp;</label>
								<div class="col-sm-8">
									<cfinput type="text" class="form-control" id="AuctionStartPrice" name="AuctionStartPrice" required="yes" maxlength="9" validate="regular_expression" pattern="/^[0-9]+(\.[0-9]{0,2})?$/">
								</div>
							</div>
							<div class="form-group">
								<label for="AuctionAvailable" class="control-label col-sm-3">Item Ready for Bids:&nbsp;</label>
								<div class="col-sm-8">
									<cfselect name="AuctionAvailable" class="form-control" Required="Yes" Multiple="No" query="AuctionAvailableQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect>
								</div>
							</div>
						</div>
						<div class="form-group">
							<label for="ItemPrimaryPhoto" class="control-label col-sm-3">Photos:&nbsp;</label>
							<div class="col-sm-8">
								<div id="uploader">
									<p>Your Browser does not have Flash, Silverlight or HTML5 Support.</p>
								</div>
							</div>
						</div>
						<div class="panel-footer">
							<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Add Auction Additional Information"><br /><br />
						</div>
					</cfform>
					<script type="text/javascript">
						// Initialize the widget when the DOM is ready
						$(function() {
							$("##uploader").plupload({
								// General settings
								runtimes : 'html5,flash,silverlight,html4',
								url : '#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:auctions.uploadpictures&AuctionID=#URL.AuctionID#',
								// User can upload no more then 20 files in one go (sets multiple_queues to false)
								max_file_count: 20,
								chunk_size: '1mb',
								// Resize images on clientside if we can
								resize : {
									width : 200,
									height : 200,
									quality : 90,
									crop: true // crop to exact dimensions
								},
								filters : {
									// Maximum file size
									max_file_size : '1000mb',
									// Specify what files to browse for
									mime_types: [
										{title : "Image files", extensions : "jpg,gif,png"},
										{title : "Zip files", extensions : "zip"}
									]
								},

								// Rename files by clicking on their titles
								rename: true,

								// Sort files
								sortable: true,
								// Enable ability to drag'n'drop files onto the widget (currently only HTML5 supports that)
								dragdrop: true,
								// Views to activate
								views: {
									list: true,
									thumbs: false, // Show thumbs
									active: 'list'
								},
								// Flash settings
								flash_swf_url : '/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/js/plupload/js/Moxie.swf',
								// Silverlight settings
								silverlight_xap_url : '/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/js/plupload/js/Moxie.xap'
							});

							// Handle the case when form was submitted before uploading has finished
							$('##AuctionAdditionalInfo').submit(function(e) {
								// Files in queue upload them first
								if ($('##uploader').plupload('getFiles').length > 0) {
									// When all files are uploaded submit form
									$('##uploader').on('complete', function() {
										$('##AuctionAdditionalInfo')[0].submit();
									});
									$('##uploader').plupload('start');
								} else {
									alert("You must have at least one file in the queue.");
								}
								return false; // Keep the form from submitting
							});
						});
					</script>
				</cfcase>
				<cfcase value="Fixed">
					<div class="panel-heading"><h1>Add Auction Additional Information</h1></div>
					<br /><br />
					<cfform action="" method="post" id="AuctionAdditionalInfo" class="form-horizontal" enctype="multipart/form-data">
						<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
						<cfinput type="hidden" name="AuctionID" value="#URL.AuctionID#">
						<cfinput type="hidden" name="AuctionType" value="#URL.AuctionType#">
						<cfinput type="hidden" name="UpdateAuctionInfo" value="true">
						<cfinput type="hidden" name="formSubmit" value="true">
						<div class="panel-body">
							<div class="form-group">
								<label for="AuctionStartPrice" class="control-label col-sm-3">Buy It Now Price:&nbsp;</label>
								<div class="col-sm-8">
									<cfinput type="text" class="form-control" id="AuctionStartPrice" name="AuctionStartPrice" required="yes" maxlength="9" validate="regular_expression" pattern="/^[0-9]+(\.[0-9]{0,2})?$/">
								</div>
							</div>
							<div class="form-group">
								<label for="AuctionAvailable" class="control-label col-sm-3">Item Ready for Purchase:&nbsp;</label>
								<div class="col-sm-8">
									<cfselect name="AuctionAvailable" class="form-control" Required="Yes" Multiple="No" query="AuctionAvailableQuery" value="ID" Display="OptionName"  queryposition="below"></cfselect>
								</div>
							</div>
						</div>
						<div class="form-group">
							<label for="ItemPrimaryPhoto" class="control-label col-sm-3">Photos:&nbsp;</label>
							<div class="col-sm-8">
								<div id="uploader">
									<p>Your Browser does not have Flash, Silverlight or HTML5 Support.</p>
								</div>
							</div>
						</div>
						<div class="panel-footer">
							<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Add Auction Additional Information"><br /><br />
						</div>
					</cfform>
					<script type="text/javascript">
						// Initialize the widget when the DOM is ready
						$(function() {
							$("##uploader").plupload({
								// General settings
								runtimes : 'html5,flash,silverlight,html4',
								url : '#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:auctions.uploadpictures&AuctionID=#URL.AuctionID#',
								// User can upload no more then 20 files in one go (sets multiple_queues to false)
								max_file_count: 20,
								chunk_size: '1mb',
								// Resize images on clientside if we can
								resize : {
									width : 200,
									height : 200,
									quality : 90,
									crop: true // crop to exact dimensions
								},
								filters : {
									// Maximum file size
									max_file_size : '1000mb',
									// Specify what files to browse for
									mime_types: [
										{title : "Image files", extensions : "jpg,gif,png"},
										{title : "Zip files", extensions : "zip"}
									]
								},

								// Rename files by clicking on their titles
								rename: true,

								// Sort files
								sortable: true,
								// Enable ability to drag'n'drop files onto the widget (currently only HTML5 supports that)
								dragdrop: true,
								// Views to activate
								views: {
									list: true,
									thumbs: false, // Show thumbs
									active: 'list'
								},
								// Flash settings
								flash_swf_url : '/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/js/plupload/js/Moxie.swf',
								// Silverlight settings
								silverlight_xap_url : '/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/js/plupload/js/Moxie.xap'
							});

							// Handle the case when form was submitted before uploading has finished
							$('##AuctionAdditionalInfo').submit(function(e) {
								// Files in queue upload them first
								if ($('##uploader').plupload('getFiles').length > 0) {
									// When all files are uploaded submit form
									$('##uploader').on('complete', function() {
										$('##AuctionAdditionalInfo')[0].submit();
									});
									$('##uploader').plupload('start');
								} else {
									alert("You must have at least one file in the queue.");
								}
								return false; // Keep the form from submitting
							});
						});
					</script>
				</cfcase>
			</cfswitch>
		</cfif>
	</div>
</cfoutput>