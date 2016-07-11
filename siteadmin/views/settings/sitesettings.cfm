<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2015 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
<cfset YesNoQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(YesNoQuery, 1)>
<cfset temp = #QuerySetCell(YesNoQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(YesNoQuery, "OptionName", "No")#>
<cfset temp = QueryAddRow(YesNoQuery, 1)>
<cfset temp = #QuerySetCell(YesNoQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(YesNoQuery, "OptionName", "Yes")#>
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
				<div class="panel-heading"><h1>Stripe Processing Settings</h1></div>
				<div class="form-group">
					<label for="StripePaymentProcessing" class="control-label col-sm-3">Process with Stripe:&nbsp;</label>
					<div class="col-sm-8">
						<cfselect name="ProcessWithStripe" class="form-control" Required="Yes" Multiple="No" query="Variables.YesNoQuery" selected="#Session.SiteSettings.ProcessPayments_Stripe#" value="ID" Display="OptionName"  queryposition="below">
							<option value="----">Use Stripe Proceessing</option>
						</cfselect>
					</div>
				</div>
				<div class="form-group">
					<label for="StripeMode" class="control-label col-sm-3">Stripe Test Mode:&nbsp;</label>
					<div class="col-sm-8">
						<cfselect name="StripeTestMode" class="form-control" Required="Yes" Multiple="No" query="Variables.YesNoQuery" selected="#Session.SiteSettings.Stripe_TestMode#" value="ID" Display="OptionName"  queryposition="below">
							<option value="----">Process with Test Information</option>
						</cfselect>
					</div>
				</div>
				<div class="form-group">
					<label for="StripeTestAPIKey" class="control-label col-sm-3">Stripe Test Secret API Key:&nbsp;</label>
					<div class="col-sm-8">
						<cfif LEN(Session.SiteSettings.Stripe_TestAPIKey)>
							<cfinput type="text" class="form-control" id="Stripe_TestAPIKey" name="Stripe_TestAPIKey" value="#Session.SiteSettings.Stripe_TestAPIKey#" required="no">
						<cfelse>
							<cfinput type="text" class="form-control" id="Stripe_TestAPIKey" name="Stripe_TestAPIKey" required="no">
						</cfif>
					</div>
				</div>
				<div class="form-group">
					<label for="StripeLiveAPIKey" class="control-label col-sm-3">Stripe Live Secret API Key:&nbsp;</label>
					<div class="col-sm-8">
						<cfif LEN(Session.SiteSettings.Stripe_LiveAPIKey)>
							<cfinput type="text" class="form-control" id="Stripe_LiveAPIKey" name="Stripe_LiveAPIKey" value="#Session.SiteSettings.Stripe_LiveAPIKey#" required="no">
						<cfelse>
							<cfinput type="text" class="form-control" id="Stripe_LiveAPIKey" name="Stripe_LiveAPIKey" required="no">
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

