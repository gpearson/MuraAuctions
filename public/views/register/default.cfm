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

<cfoutput>
	<cfif isDefined("URL.UserAction") and isDefined("URL.AccountType")>
		<div class="panel panel-default">
			<div class="panel-heading"><h1>Account Information</h1></div>
			<div class="panel-body">
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="OrganizationInfoCreated">
						<div class="alert alert-success">
							You have successfully created the organization information for a Seller's Account. WIthin the next few minutes you will be receiving an email with a PDF Contract that will need to be printed, signed and returned to us. When we receive the signed contract and your account has been updated, you will receive an email stating that your account has been activated.
						</div>
					</cfcase>
					<cfcase value="AccountCreated">
						<cfif isDefined("URL.Successful")>
							<cfif URL.Successful EQ "true">
								<cfquery name="CheckOrganizationRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
									Select Organization_ID
									From p_Auction_UserMatrix
									Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
										User_ID = <cfqueryparam value="#URL.User#" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfif Len(CheckOrganizationRecord.Organization_ID) EQ 0>
									<div class="alert alert-success">
										You have successfully created an account and will be receiving an email message with a link to verify the entered email address. Please complete this form as this information is requried to create a Seller's Account on this website.
									</div>
									<div class="panel-heading"><h1>Seller Account Specific Information</h1></div>
									<cfset captcha = #Session.Captcha#>
									<cfset captchaHash = Hash(captcha)>
									<cfform action="" method="post" id="RegisterAccountForm" class="form-horizontal">
										<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
										<cfinput type="hidden" name="UserID" value="#URL.User#">
										<cfinput type="hidden" name="CaptchaEncrypted" value="#Variables.CaptchaHash#">
										<cfinput type="hidden" name="HumanValidation" value="#Variables.Captcha#">
										<cfinput type="hidden" name="formSubmit" value="true">
										<div class="panel-body">
											<div class="form-group">
												<label for="OrganizationType" class="control-label col-sm-3">Organization Type:&nbsp;</label>
												<div class="col-sm-8">
													<cfselect name="OrganizationType" class="form-control" Required="Yes" Multiple="No" query="OrganizationTypeAccountQuery" value="ID" Display="OptionName"  queryposition="below">
														<option value="----">Select Organization Type</option>
													</cfselect>
												</div>
											</div>
											<div class="form-group">
												<label for="FederalEIN" class="control-label col-sm-3">Federal EIN:&nbsp;</label>
												<div class="col-sm-8"><cfinput type="text" class="form-control" id="FederalEIN" name="FederalEIN" required="yes"></div>
											</div>
											<div class="form-group">
												<label for="OrganizationName" class="control-label col-sm-3">Organization Name:&nbsp;</label>
												<div class="col-sm-8"><cfinput type="text" class="form-control" id="OrganizationName" name="OrganizationName" required="yes"></div>
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
												<label for="OrganizationPhone" class="control-label col-sm-3">Organization Voice:&nbsp;</label>
												<div class="col-sm-8"><cfinput type="text" class="form-control" id="OrganizationPhone" name="OrganizationPhone" required="yes"></div>
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
											<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Submit Organization Information"><br /><br />
										</div>
									</cfform>
								<cfelse>
									<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default">
								</cfif>
							</cfif>
						</cfif>
					</cfcase>
				</cfswitch>
			</div>
		</div>
	<cfelseif isDefined("URL.FormRetry")>
		<div class="panel panel-default">
			<div class="panel-heading"><h1>Account Information</h1></div>
			<div class="panel-body">
				<cfif ArrayLen(Session.FormErrors) GTE 1>
					<br /><br />
					<div class="alert alert-danger"><p>#Session.FormErrors[1].Message#</p></div>
				</cfif>
				<cfquery name="CheckOrganizationRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Organization_ID
					From p_Auction_UserMatrix
					Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
						User_ID = <cfqueryparam value="#URL.User#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif Len(CheckOrganizationRecord.Organization_ID) EQ 0>
					<div class="alert alert-success">
						You have successfully created an account and will be receiving an email message with a link to verify the entered email address. Please complete this form as this information is requried to create a Seller's Account on this website.
					</div>
					<div class="panel-heading"><h1>Seller Account Specific Information</h1></div>
						<cfform action="" method="post" id="RegisterAccountForm" class="form-horizontal">
							<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
							<cfinput type="hidden" name="UserID" value="#URL.User#">
							<cfinput type="hidden" name="CaptchaEncrypted" value="#Session.FormData.CaptchaEncrypted#">
							<cfinput type="hidden" name="HumanValidation" value="#Session.FormData.HumanValidation#">
							<cfinput type="hidden" name="formSubmit" value="true">
							<div class="panel-body">
								<div class="form-group">
									<label for="OrganizationType" class="control-label col-sm-3">Organization Type:&nbsp;</label>
									<div class="col-sm-8">
										<cfselect name="OrganizationType" selected="#Session.FormData.OrganizationType#" class="form-control" Required="Yes" Multiple="No" query="OrganizationTypeAccountQuery" value="ID" Display="OptionName"  queryposition="below">
											<option value="----">Select Organization Type</option>
										</cfselect>
									</div>
								</div>
								<div class="form-group">
									<label for="FederalEIN" class="control-label col-sm-3">Federal EIN:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.FederalEIN#" id="FederalEIN" name="FederalEIN" required="yes"></div>
								</div>
								<div class="form-group">
									<label for="OrganizationName" class="control-label col-sm-3">Organization Name:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.OrganizationName#" id="OrganizationName" name="OrganizationName" required="yes"></div>
								</div>
								<div class="form-group">
									<label for="PhysicalAddress" class="control-label col-sm-3">Physical Address:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.PhysicalAddress#" id="PhysicalAddress" name="PhysicalAddress" required="yes"></div>
								</div>
								<div class="form-group">
									<label for="PhysicalCity" class="control-label col-sm-3">Physical City:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" value="#Session.FormData.PhysicalCity#" id="PhysicalCity" name="PhysicalCity" required="yes"></div>
								</div>
								<div class="form-group">
									<label for="PhysicalState" class="control-label col-sm-3">Physical State:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalState" value="#Session.FormData.PhysicalState#" name="PhysicalState" required="yes"></div>
								</div>
								<div class="form-group">
									<label for="PhysicalZipCode" class="control-label col-sm-3">Physical ZipCode:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" id="PhysicalZipCode" value="#Session.FormData.PhysicalZipCode#" name="PhysicalZipCode" required="yes"></div>
								</div>
								<div class="form-group">
									<label for="OrganizationPhone" class="control-label col-sm-3">Organization Voice:&nbsp;</label>
									<div class="col-sm-8"><cfinput type="text" class="form-control" id="OrganizationPhone" value="#Session.FormData.OrganizationPhone#" name="OrganizationPhone" required="yes"></div>
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
								<cfinput type="Submit" name="RegisterAccount" class="btn btn-primary pull-right" value="Submit Organization Information"><br /><br />
							</div>
						</cfform>
					<cfelse>
						<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default">
					</cfif>
				</div>
			</div>
	<cfelseif isDefined("URL.UserAction") and not isDefined("URL.AccountType")>
		<div class="panel panel-default">
			<div class="panel-heading"><h1>Check Email to Verify Email Address</h1></div>
			<div class="panel-body">
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="AccountCreated">
						<cfif isDefined("URL.Successful")>
							<cfif URL.Successful EQ "true">
								<div class="alert alert-success">
									You have successfully created an account. You will be receiving an email with a link to click on is being sent to the entered email address within the next few minutes. You will not be able to login to this website until your account has been activated.
								</div>
							<cfelse>
								<div class="alert alert-danger">
									An error has occurred and the customer record was not added to the database.
								</div>
							</cfif>
						</cfif>
					</cfcase>
				</cfswitch>
			</div>
		</div>
	</cfif>
</cfoutput>