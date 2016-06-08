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

	<cffunction name="SendBuyerAccountActivationEmail" returntype="Any" Output="false">
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
		<cfset AccountActiveLink = "http://" & #CGI.Server_Name# & "#CGI.Script_name##CGI.path_info#?#rc.pc.getPackage()#action=public:register.activateaccount&" & #Variables.AccountVars#>

		<cfinclude template="EmailTemplates/SendBuyerAccountActivationEmailToIndividual.cfm">
	</cffunction>

	<cffunction name="SendSellerAccountActivationEmail" returntype="Any" Output="false">
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
		<cfset AccountActiveLink = "http://" & #CGI.Server_Name# & "#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.activateaccount&" & #Variables.AccountVars#>

		<cfinclude template="EmailTemplates/SendSellerAccountActivationEmailToIndividual.cfm">
	</cffunction>

	<cffunction name="SendSellerAccountOrganizationInfoEmail" returntype="Any" Output="false">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset AccountActiveLink = "http://" & #CGI.Server_Name# & "#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&UserAction=AccountCreated&AccountType=Seller&Successful=True&User=#Arguments.UserID#">

		<cfinclude template="EmailTemplates/SendSellerAccountOrganizationInfoToIndividual.cfm">
	</cffunction>

	<cffunction name="SendSellerAccountContractEmail" returntype="Any" Output="False">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="UserID" type="String" Required="True">

		<cfset ContractTemplateDir = #Left(ExpandPath("*"), Find("*", ExpandPath("*")) - 1)# & "plugins/" & #rc.pc.getPackage()#>
		<cfset ContractExportTemplateDir = #Variables.ContractTemplateDir# & "/library/reports/completedcontracts/">
		<cfset ContractMasterTemplate = #Variables.ContractTemplateDir# & "/library/reports/AuctionSurplusContract.rtf">
		<cfset CompletedContractFile = #Variables.ContractExportTemplateDir# & #Arguments.UserID# & "-CompletedContract.doc">
		<cfset CompletedContractPDFFile = #Variables.ContractExportTemplateDir# & #Arguments.UserID# & "-CompletedContract.pdf">

		<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select tusers.Fname, tusers.Lname, tusers.Email,  p_Auction_UserMatrix.AccountType, p_Auction_UserMatrix.ZipCode, p_Auction_UserMatrix.TelephoneNumber, p_Auction_UserMatrix.Organization_ID, p_Auction_Organizations.BusinessName, p_Auction_Organizations.PhysicalAddress, p_Auction_Organizations.PhysicalCity, p_Auction_Organizations.PhysicalState, p_Auction_Organizations.PhysicalZipCode, p_Auction_Organizations.PhysicalZip4, p_Auction_Organizations.PrimaryVoiceNumber, p_Auction_Organizations.BusinessWebsite, p_Auction_Organizations.Federal_EIN
			From tusers
				INNER JOIN p_Auction_UserMatrix ON p_Auction_UserMatrix.User_ID = tusers.UserID
				INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_UserMatrix.Organization_ID
			Where tusers.UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar"> and
				tusers.SiteID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="getSiteFees" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select SellerPercentageFee
			From p_Auction_SiteConfig
			Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
		</cfquery>



		<cfif getUserAccount.RecordCount>
			<cfset RTFFile = FileRead(Variables.ContractMasterTemplate)>
			<cfset RTFFile = Replace(RTFFile,"%DayOfMonth%", DateFormat(Now(), "dd"))>
			<cfset RTFFile = Replace(RTFFile,"%Month%", DateFormat(Now(), "mmmm"))>
			<cfset RTFFile = Replace(RTFFile,"%Year%", DateFormat(Now(), "yyyy"))>
			<cfset RTFFile = Replace(RTFFile,"%ClientName%", getUserAccount.BusinessName)>
			<cfset RTFFile = Replace(RTFFile,"%PhysicalAddress%", getUserAccount.PhysicalAddress)>
			<cfset RTFFile = Replace(RTFFile,"%PhysicalCity%", getUserAccount.PhysicalCity)>
			<cfset RTFFile = Replace(RTFFile,"%PhysicalState%", getUserAccount.PhysicalState)>
			<cfset RTFFile = Replace(RTFFile,"%PhysicalZipCode%", getUserAccount.PhysicalZipCode)>
			<cffile action="write" file="#Variables.CompletedContractFile#" output="#Variables.RTFFile#">
			<cfscript>
				// create editor objects used for the conversion
				fis = createObject("java", "java.io.FileInputStream").init( CompletedContractFile );
				rtfEditor = createObject("java", "javax.swing.text.rtf.RTFEditorKit");
				htmlEditor = createObject("java", "javax.swing.text.html.HTMLEditorKit");

				// create a default document and load the rtf file
				document = rtfEditor.createDefaultDocument();
				rtfEditor.read(fis, document, 0);

				// convert the document to html
				stringWriter = createObject("java", "java.io.StringWriter").init( document.getLength() );
				htmlEditor.write(stringWriter, document, 0, document.getLength());

				// get the html content as a string
				htmlOutput = stringWriter.getBuffer().toString();
			</cfscript>

			<cfoutput><cfdocument format="pdf" filename="#CompletedContractPDFFile#" overwrite="true">#htmlOutput#</cfdocument></cfoutput>
			<cfinclude template="EmailTemplates/SendSellerContractForSignature.cfm">
		</cfif>


	</cffunction>

	<cffunction name="SendBuyerAccountActivationEmailConfirmation" ReturnType="Any" Output="False">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfinclude template="EmailTemplates/BuyerAccountActivationConfirmationEmailToIndividual.cfm">
	</cffunction>

	<cffunction name="SendSellerAccountActivationEmailConfirmation" ReturnType="Any" Output="False">
		<cfargument name="rc" type="struct" Required="True">
		<cfargument name="UserID" type="String" Required="True">

		<cfquery name="getUserAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select Fname, Lname, UserName, Email, created
			From tusers
			Where UserID = <cfqueryparam value="#Arguments.UserID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfinclude template="EmailTemplates/SellerAccountActivationConfirmationEmailToIndividual.cfm">
	</cffunction>
</cfcomponent>