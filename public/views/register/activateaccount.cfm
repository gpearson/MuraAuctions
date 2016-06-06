<cfif not isDefined("URL.Key")><cflocation url="/index.cfm" addtoken="false"></cfif>
<cfif isDefined("URL.Key")>
	<cfset DecryptedURLString = #ToString(ToBinary(URL.Key))#>
	<cfset UserID = #ListFirst(Variables.DecryptedURLString, "&")#>
	<cfset DateSentCreated = #ListLast(Variables.DecryptedURLString, "&")#>

	<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>

	<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
		Select tusers.Fname, tusers.Lname, tusers.Email, tusers.InActive, tusers.SiteID, p_Auction_UserMatrix.AccountType, p_Auction_UserMatrix.ZipCode, p_Auction_UserMatrix.TelephoneNumber
		From tusers INNER JOIN p_Auction_UserMatrix ON p_Auction_UserMatrix.User_ID = tusers.UserID
		Where tusers.UserID = <cfqueryparam value="#ListLast(Variables.UserID, '=')#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfif DateDiff("n", ListLast(Variables.DateSentCreated, '='), Now()) LTE 45>
		<!--- Allow Up To 45 Minutes for user to click on the link to activate the account --->
		<cftry>
			<cfquery name="updateUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Update tusers
				Set inActive = 0, LastUpdateBy = 'System', LastUpdateByID = '', LastUpdate = #Now()#
				Where UserID = <cfqueryparam value="#ListLast(Variables.UserID, '=')#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfcatch type="database">
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfswitch expression="#getUserAccount.AccountType#">
			<cfcase value="1">
				<cfoutput>
					<div class="panel panel-default">
						<div class="panel-heading"><h1>Account Activated</h1></div>
						<div class="panel-body">
							<div class="alert alert-success">
								You have successfully activated your account on this website. You will be receiving an email about this for your records. You can now login to this site with your email address and provided password.
							</div>
						</div>
					</div>
				</cfoutput>
				<cfset SendActivationEmailConfirmation = #SendEmailCFC.SendBuyerAccountActivationEmailConfirmation(rc, ListLast(Variables.UserID, '='))#>
			</cfcase>
			<cfcase value="0">
				<cfquery name="CheckOrganizationInformation" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Organization_ID
					from p_Auction_UserMatrix
					Where User_ID = <cfqueryparam value="#ListLast(Variables.UserID, '=')#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif Len(CheckOrganizationInformation.Organization_ID)>
					<cfoutput>
						<div class="panel panel-default">
							<div class="panel-heading"><h1>Account Email Verified</h1></div>
							<div class="panel-body">
								<div class="alert alert-success">
									You have successfully verified your email address on this website. The system is in the process of generating the service contract for you. You will need to Print, Sign and send this service contract back to us in order for your account to be fully activated. Once your account is fully activated, you will receive an email stating this. At the time you receive this last email you will be able to post items for sale.
								</div>
							</div>
						</div>
					</cfoutput>
					<cfset SendActivationEmailConfirmation = #SendEmailCFC.SendSellerAccountActivationEmailConfirmation(rc, ListLast(Variables.UserID, '='))#>
					<cfset SendSellerContractEmail = #SendEmailCFC.SendSellerAccountContractEmail(rc, ListLast(Variables.UserID, '='))#>
				<cfelse>
					<cfoutput>
						<div class="panel panel-default">
							<div class="panel-heading"><h1>Account Email Verified</h1></div>
							<div class="panel-body">
								<div class="alert alert-success">
									You have successfully verified your email address on this website. We are in need of the organization information before we can continue with your seller's account.We are in the process of sending you an email with a request to complete the Organization Information to your email address.
								</div>
							</div>
						</div>
					</cfoutput>
					<cfset SendActivationEmailConfirmation = #SendEmailCFC.SendSellerAccountActivationEmailConfirmation(rc, ListLast(Variables.UserID, '='))#>
					<cfset SendSellerAccountNeedOrganizationInfoEmail = #SendEmailCFC.SendSellerAccountOrganizationInfoEmail(rc, ListLast(Variables.UserID, '='))#>
				</cfif>
			</cfcase>
		</cfswitch>
	<cfelse>
		<cfoutput>
			<div class="panel panel-default">
				<div class="panel-heading"><h1>Account Not Activated</h1></div>
				<div class="panel-body">
					<div class="alert alert-danger">
						Your account is not activated due to the Expiration of the Key which was in the activation email when you created your account. Please use the Contact Us Form on the main page so we can manually activate your account.
					</div>
				</div>
			</div>
		</cfoutput>
	</cfif>
</cfif>
