<cfset TypeAccountQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(TypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(TypeAccountQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(TypeAccountQuery, "OptionName", "Seller's Account")#>
<cfset temp = QueryAddRow(TypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(TypeAccountQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(TypeAccountQuery, "OptionName", "Buyer's Account")#>

<cfoutput>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Register Account</h1></div>
		<cfif not isDefined("URL.FormRetry")>
			<cfset captcha = #Session.Captcha#>
			<cfset captchaHash = Hash(captcha)>
			<cfform action="" method="post" id="RegisterAccountForm" class="form-horizontal">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="CaptchaEncrypted" value="#Variables.CaptchaHash#">
				<cfinput type="hidden" name="HumanValidation" value="#Variables.Captcha#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<!--- <cfinput type="hidden" name="captchaHash" id="captchaHash" value="#captchaHash#"> --->
				<div class="panel-body">
					<div class="well">Please complete this form to begin the process on registering for an account on this site. You can register for either a seller's account or a buyer's account.</div>
					<div class="panel-heading"><h2>Your Information</h2></div>
					<div class="form-group">
						<label for="YourFirstName" class="control-label col-sm-3">First Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactFirstName" name="ContactFirstName" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourLastName" class="control-label col-sm-3">Last Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactLastName" name="ContactLastName" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourEmail" class="control-label col-sm-3">Your Email:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactEmail" name="ContactEmail" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourTelephone" class="control-label col-sm-3">Contact Phone Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactPhone" name="ContactPhone" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourDesiredPassword" class="control-label col-sm-3">Desired Password:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="password" class="form-control" id="YourDesiredPassword" name="YourDesiredPassword" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="VerifyDesiredPassword" class="control-label col-sm-3">Verify Password:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="password" class="form-control" id="VerifyDesiredPassword" name="VerifyDesiredPassword" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourZipCode" class="control-label col-sm-3">Your ZipCode:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="YourZipCode" name="YourZipCode" required="yes"></div>
					</div>
					<br /><br />
					<div class="panel-heading"><h2>Type of Account Inquiry</h2></div>
					<div class="well">Seller accounts are for Public/Private School Districts, College/Universities, Non-Profit Organizations, and Government Organizations. Seller Accounts must sign a service contract that will be sent to the email address used on this form before the account is activated in the system.</div>
					<div class="form-group">
						<label for="AccountType" class="control-label col-sm-3">Account Type:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="TypeOfAccountRequested" class="form-control" Required="Yes" Multiple="No" query="TypeAccountQuery" value="ID" Display="OptionName"  queryposition="below">
								<option value="----">Select Account Type</option>
							</cfselect>
						</div>
					</div>
					<div class="panel-heading"><h2>Human Checker</h2></div>
					<div class="form-group">
						<label for="HumanChecker" class="control-label col-sm-3">Enter Text:&nbsp;</label>
						<div class="col-sm-8">
							<cfimage action="captcha" difficulty="medium" text="#captcha#" fonts="arial,times roman, tahoma" height="150" width="500" /><br>
							<cfinput name="ValidateCaptcha" type="text" required="yes" message="Input Captcha Text" />
						</div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Register Account"><br /><br />
				</div>
			</cfform>
		<cfelse>
			<cfif isDefined("Session.FormErrors")>
				<div class="panel-body">
					<cfif ArrayLen(Session.FormErrors) GTE 1>
						<div class="alert alert-danger"><p>#Session.FormErrors[1].Message#</p></div>
					</cfif>
				</div>
			</cfif>
			<cfform action="" method="post" id="RegisterAccountForm" class="form-horizontal">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="CaptchaEncrypted" value="#Session.FormData.CaptchaEncrypted#">
				<cfinput type="hidden" name="HumanValidation" value="#Session.FormData.HumanValidation#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<div class="panel-body">
					<div class="well">Please complete this form to begin the process on registering for an account on this site. You can register for either a seller's account or a buyer's account.</div>
					<div class="panel-heading"><h2>Your Information</h2></div>
					<div class="form-group">
						<label for="YourFirstName" class="control-label col-sm-3">First Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.ContactFirstName#" id="ContactFirstName" name="ContactFirstName" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourLastName" class="control-label col-sm-3">Last Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.ContactLastName#" id="ContactLastName" name="ContactLastName" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourEmail" class="control-label col-sm-3">Your Email:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.ContactEmail#" id="ContactEmail" name="ContactEmail" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourTelephone" class="control-label col-sm-3">Contact Phone Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.ContactPhone#" id="ContactPhone" name="ContactPhone" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourDesiredPassword" class="control-label col-sm-3">Desired Password:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="password" class="form-control" value="#Session.FormData.YourDesiredPassword#" id="YourDesiredPassword" name="YourDesiredPassword" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="VerifyDesiredPassword" class="control-label col-sm-3">Verify Password:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="password" class="form-control" value="#Session.FormData.VerifyDesiredPassword#" id="VerifyDesiredPassword" name="VerifyDesiredPassword" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="YourZipCode" class="control-label col-sm-3">Your ZipCode:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.YourZipCode#" id="YourZipCode" name="YourZipCode" required="yes"></div>
					</div>
					<br /><br />
					<div class="panel-heading"><h2>Type of Account Inquiry</h2></div>
					<div class="well">Seller accounts are for Public/Private School Districts, College/Universities, Non-Profit Organizations, and Government Organizations. Seller Accounts must sign a service contract that will be sent to the email address used on this form before the account is activated in the system.</div>
					<div class="form-group">
						<label for="AccountType" class="control-label col-sm-3">Account Type:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="TypeOfAccountRequested" class="form-control" selected="#Session.FormData.TypeOfAccountRequested#" Required="Yes" Multiple="No" query="TypeAccountQuery" value="ID" Display="OptionName"  queryposition="below">
								<option value="----">Select Account Type</option>
							</cfselect>
						</div>
					</div>
					<div class="panel-heading"><h2>Human Checker</h2></div>
					<div class="form-group">
						<label for="HumanChecker" class="control-label col-sm-3">Enter Text:&nbsp;</label>
						<div class="col-sm-8">
							<cfimage action="captcha" difficulty="medium" text="#Session.FormData.HumanValidation#" fonts="arial,times roman, tahoma" height="150" width="500" /><br>
							<cfinput name="ValidateCaptcha" type="text" required="yes" message="Input Captcha Text" />
						</div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Register Account"><br /><br />
				</div>
			</cfform>
		</cfif>
	</div>
</cfoutput>