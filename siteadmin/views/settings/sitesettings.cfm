<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2015 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfoutput>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Auction Site Settings</h1></div>
		<cfform action="" method="post" id="CreateNewUser" class="form-horizontal">
			<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
			<cfinput type="hidden" name="SiteSettingRecNo" value="#Session.SiteSettings.TContent_ID#">
			<cfinput type="hidden" name="formSubmit" value="true">
			<div class="panel-body">
				<div class="form-group">
					<label for="SellerPercentageFee" class="control-label col-sm-3">Seller's Percentage Fee:&nbsp;</label>
					<div class="col-sm-8">
						<cfif LEN(Session.SiteSettings.SellerPercentageFee)>
							<cfinput type="text" validate="numeric" class="form-control" id="SellerPercentageFee" name="SellerPercentageFee" value="#Session.SiteSettings.SellerPercentageFee#" required="yes">
						<cfelse>
							<cfinput type="text" validate="numeric" class="form-control" id="SellerPercentageFee" name="SellerPercentageFee" value=".13" required="yes">
						</cfif>
					</div>

				</div>
			</div>
			<div class="panel-footer">
				<cfinput type="Submit" name="UpdatePluginSettings" class="btn btn-primary pull-right" value="Update Auction Settings"><br /><br />
			</div>
		</cfform>
	</div>
</cfoutput>

