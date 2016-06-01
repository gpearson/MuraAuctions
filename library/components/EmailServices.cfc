<cfcomponent displayName="Auction Site Email Routines">
	<cffunction name="SendCommentInquiryToAdministrators" ReturnType="Any" Output="False">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="ContactInfo" type="struct" Required="True">

		<cfquery name="GetAdmins" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select tusersmemb.UserID
			From tusersmemb INNER JOIN tusers on tusers.UserID = tusersmemb.GroupID
			Where tusers.GroupName = 'Admin'
		</cfquery>

		<cfif GetAdmins.RecordCount EQ 0>
			<cfquery name="GetAdminEmailAddress" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Select Email
				From tusers
				Where UserName = 'Admin'
			</cfquery>
		</cfif>
		<cfinclude template="EmailTemplates/UserHasQuestions.cfm">
	</cffunction>

	<cffunction name="SendAccountActivationEmail" returntype="Any" Output="false">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar"> and
				InActive = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
		</cfquery>

		<cfset ValueToEncrypt = "UserID=" & #Arguments.UserID# & "&" & "Created=" & #getUserAccount.created# & "&DateSent=" & #Now()#>
		<cfset EncryptedValue = #Tobase64(Variables.ValueToEncrypt)#>
		<cfset AccountVars = "Key=" & #Variables.EncryptedValue#>
		<cfset AccountActiveLink = "http://" & #CGI.Server_Name# & "/index.cfm/auction-site/?MuraAuctionsaction=public:register.activateaccount&" & #Variables.AccountVars#>

		<cfinclude template="EmailTemplates/SendAccountActivationEmailToIndividual.cfm">
	</cffunction>

	<cffunction name="SendAccountActivationEmailConfirmation" ReturnType="Any" Output="False">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfinclude template="EmailTemplates/AccountActivationConfirmationEmailToIndividual.cfm">
	</cffunction>
</cfcomponent>