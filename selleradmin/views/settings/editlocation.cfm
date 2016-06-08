<cfset LocationActiveQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(LocationActiveQuery, 1)>
<cfset temp = #QuerySetCell(LocationActiveQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(LocationActiveQuery, "OptionName", "No")#>
<cfset temp = QueryAddRow(LocationActiveQuery, 1)>
<cfset temp = #QuerySetCell(LocationActiveQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(LocationActiveQuery, "OptionName", "Yes")#>

<cfoutput>
	<div class="panel panel-default">
		<cfif not isDefined("URL.PerformAction")>
			<div class="panel-heading"><h1>Edit Location for Auction Surplus Items</h1></div>
			<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="OrganizationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
				<cfinput type="hidden" name="LocationID" value="#Session.getSelectedLocation.TContent_ID#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<div class="panel-body">
					<div class="form-group">
						<label for="LocationName" class="control-label col-sm-3">Location Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationName" name="LocationName" value="#Session.getSelectedLocation.LocationName#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalAddress" class="control-label col-sm-3">Physical Address:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalAddress" name="PhysicalAddress" value="#Session.getSelectedLocation.PhysicalAddress#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalCity" class="control-label col-sm-3">Physical City:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalCity" name="PhysicalCity" value="#Session.getSelectedLocation.PhysicalCity#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalState" class="control-label col-sm-3">Physical State:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalState" name="PhysicalState" value="#Session.getSelectedLocation.PhysicalState#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalZipCode" class="control-label col-sm-3">Physical ZipCode:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalZipCode" name="PhysicalZipCode" value="#Session.getSelectedLocation.PhysicalZipCode#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationPhone" class="control-label col-sm-3">Location Voice Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationPhone" name="LocationPhone" value="#Session.getSelectedLocation.PrimaryVoiceNumber#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationActive" class="control-label col-sm-3">Location Active:&nbsp;</label>
						<div class="col-sm-8"><cfselect name="LocationActive" class="form-control" Required="Yes" Multiple="No" selected="#Session.getSelectedLocation.Active#" query="LocationActiveQuery" value="ID" Display="OptionName"  queryposition="below">
								</cfselect>
						</div>
					</div>
					<div class="panel-heading"><h1>Additional Information</h1></div>
					<div class="form-group">
						<label for="LocationCreated" class="control-label col-sm-3">Record Created:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationCreated" name="LocationCreated" value="#DateFormat(Session.getSelectedLocation.dateCreated, 'full')# at #TimeFormat(Session.getSelectedLocation.dateCreated,'HH:mm:ss tt')#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationUpdated" class="control-label col-sm-3">Record Last Updated:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationUpdated" name="LocationUpdated" value="#DateFormat(Session.getSelectedLocation.lastUpdated, 'full')# at #TimeFormat(Session.getSelectedLocation.lastUpdated,'HH:mm:ss tt')#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationUpdatedBy" class="control-label col-sm-3">Record Last Updated By:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationUpdatedBy" name="LocationUpdatedBy" value="#Session.getSelectedLocation.lastUpdateBy#" disabled="yes"></div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Update Location Information"><br /><br />
				</div>
			</cfform>
		<cfelse>
			<div class="panel-heading"><h1>Delete Location</h1></div>
				<cfform action="" method="post" id="RegisterNewLocation" class="form-horizontal">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="OrganizationID" value="#Session.getSellerOrganizationInfo.Organization_ID#">
				<cfinput type="hidden" name="LocationID" value="#Session.getSelectedLocation.TContent_ID#">
				<cfinput type="hidden" name="PerformAction" value="true">
				<cfinput type="hidden" name="formSubmit" value="true">
				<div class="panel-body">
					<div class="form-group">
						<label for="LocationName" class="control-label col-sm-3">Location Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationName" name="LocationName" value="#Session.getSelectedLocation.LocationName#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalAddress" class="control-label col-sm-3">Physical Address:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalAddress" name="PhysicalAddress" value="#Session.getSelectedLocation.PhysicalAddress#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalCity" class="control-label col-sm-3">Physical City:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalCity" name="PhysicalCity" value="#Session.getSelectedLocation.PhysicalCity#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalState" class="control-label col-sm-3">Physical State:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalState" name="PhysicalState" value="#Session.getSelectedLocation.PhysicalState#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="PhysicalZipCode" class="control-label col-sm-3">Physical ZipCode:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalZipCode" name="PhysicalZipCode" value="#Session.getSelectedLocation.PhysicalZipCode#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationPhone" class="control-label col-sm-3">Location Voice Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationPhone" name="LocationPhone" value="#Session.getSelectedLocation.PrimaryVoiceNumber#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationActive" class="control-label col-sm-3">Location Active:&nbsp;</label>
						<div class="col-sm-8"><cfselect name="LocationActive" class="form-control" disabled="Yes" Multiple="No" selected="#Session.getSelectedLocation.Active#" query="LocationActiveQuery" value="ID" Display="OptionName"  queryposition="below">
								</cfselect>
						</div>
					</div>
					<div class="panel-heading"><h1>Additional Information</h1></div>
					<div class="form-group">
						<label for="LocationCreated" class="control-label col-sm-3">Record Created:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationCreated" name="LocationCreated" value="#DateFormat(Session.getSelectedLocation.dateCreated, 'full')# at #TimeFormat(Session.getSelectedLocation.dateCreated,'HH:mm:ss tt')#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationUpdated" class="control-label col-sm-3">Record Last Updated:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationUpdated" name="LocationUpdated" value="#DateFormat(Session.getSelectedLocation.lastUpdated, 'full')# at #TimeFormat(Session.getSelectedLocation.lastUpdated,'HH:mm:ss tt')#" disabled="yes"></div>
					</div>
					<div class="form-group">
						<label for="LocationUpdatedBy" class="control-label col-sm-3">Record Last Updated By:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="LocationUpdatedBy" name="LocationUpdatedBy" value="#Session.getSelectedLocation.lastUpdateBy#" disabled="yes"></div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Delete Location Information"><br /><br />
				</div>
			</cfform>
			</div>
		</cfif>
	</div>
</cfoutput>