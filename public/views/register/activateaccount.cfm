<cfif not isDefined("URL.Key")><cflocation url="/index.cfm" addtoken="false"></cfif>
<cfif isDefined("URL.Key")>
	<cfset DecryptedURLString = #ToString(ToBinary(URL.Key))#>
	<cfset UserID = #ListFirst(Variables.DecryptedURLString, "&")#>
	<cfset DateSentCreated = #ListLast(Variables.DecryptedURLString, "&")#>

	<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>

	<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
		Select Fname, Lname, UserName, Email, created
		From tusers
		Where UserID = <cfqueryparam value="#ListLast(Variables.UserID, '=')#" cfsqltype="cf_sql_varchar">
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
		<cfset SendActivationEmailConfirmation = #SendEmailCFC.SendAccountActivationEmailConfirmation(rc, ListLast(Variables.UserID, '='))#>
	<cfelse>
		<cfoutput>
			<div class="panel panel-default">
				<div class="panel-heading"><h1>Account Activated</h1></div>
				<div class="panel-body">
					<div class="alert alert-danger">
						Your account is not activated due to the Expiration of the Key which was in the activation email when you created your account. Please use the Contact Us Form on the main page so we can manually activate your account.
					</div>
				</div>
			</div>
		</cfoutput>
	</cfif>
</cfif>
