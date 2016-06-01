/*


*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="true">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

	</cffunction>

	<cffunction name="account" returntype="any" output="true">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfset Session.Captcha = #makeRandomString()#>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>
			<cfif #HASH(FORM.ValidateCaptcha)# NEQ FORM.CaptchaEncrypted>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Characters entered in the Image did not match those that were displayed"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="/index.cfm/auction-site/index.cfm?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif FORM.YourDesiredPassword NEQ FORM.VerifyDesiredPassword>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Password Field did not match the Verify Password Field. Please correct this before proceeding"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="/index.cfm/auction-site/index.cfm?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif not isValid("email", FORM.ContactEmail)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Email Address entered did not look like it was in proper email format. Please check the email address again before proceeding"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="/index.cfm/auction-site/index.cfm?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif not isValid("telephone", FORM.ContactPhone)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Contact Telephone Number entered was not a standard United States Telephone Number. Please check this telephone number again before proceeding."};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="/index.cfm/auction-site/index.cfm?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif not isValid("zipcode", FORM.YourZipCode)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Zip Code entered was not a standard United States ZipCode. Please check the zipcode entered and correct this field before proceeding."};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="/index.cfm/auction-site/index.cfm?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<!--- Initiates the User Bean --->
			<cfset NewUser = #Application.userManager.readByUsername(form.ContactEmail, rc.$.siteConfig('siteID'))#>
			<cfset NewUser.setInActive(1)>
			<cfset NewUser.setSiteID(rc.$.siteConfig('siteID'))>
			<cfset NewUser.setFname(FORM.ContactFirstName)>
			<cfset NewUser.setLname(FORM.ContactLastName)>
			<cfset NewUser.setUsername(FORM.ContactEmail)>
			<cfset NewUser.setPassword(FORM.YourDesiredPassword)>
			<cfset NewUser.setEmail(FORM.ContactEmail)>

			<cfif NewUser.checkUsername() EQ "false">
				<!--- Username already exists within the database. --->
				<cfscript>
					UsernameExists = {property="UserName",message="The Email Address already exists within the database as the Username to your account. If this Email Address is your account, you can request a forgot password by clicking on the Forgot Password Link under the Home Navigation Menu at the top of this screen. Otherwise please enter a different email address so your account can be created."};
					arrayAppend(Session.FormErrors, UsernameExists);
				</cfscript>
				<cflocation url="/index.cfm/auction-site/?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			<cfelse>
				<cfset AddNewAccount = #Application.userManager.save(NewUser)#>

				<cfif LEN(AddNewAccount.getErrors()) EQ 0>
					<cfset NewUserID = #AddNewAccount.getUserID()#>

					<cfquery name="insertUserMatrixInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Insert into p_Auction_UserMatrix(User_ID,Site_ID,ZipCode,AccountType,TelephoneNumber,lastUpdateBy,lastUpdated)
						Values(
							<cfqueryparam value="#Variables.NewUserID#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#FORM.YourZipCode#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#FORM.TypeOfAccountRequested#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#FORM.ContactPhone#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="System" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>

					<cfset SendActivationEmail = #SendEmailCFC.SendAccountActivationEmail(rc, Variables.NewUserID)#>

					<cflocation url="/index.cfm/auction-site/?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&UserAction=AccountCreated&Successful=True">
				<cfelse>
					<cfdump var="#AddNewAccount.getErrors()#"><cfabort>
				</cfif>
			</cfif>

		</cfif>

	</cffunction>

	<cffunction name="activateaccount" returntype="any" output="true">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

	</cffunction>

	<cffunction name="makeRandomString" ReturnType="String" output="False">
		<cfset var chars = "23456789ABCDEFGHJKMNPQRSTUVWXYZ">
		<cfset var length = RandRange(4,7)>
		<cfset var result = "">
		<cfset var i = "">
		<cfset var char = "">
		<cfscript>
			for (i = 1; i < length; i++) {
				char = mid(chars, randRange(1, len(chars)), 1);
				result &= char;
			}
		</cfscript>
		<cfreturn result>
	</cffunction>

</cfcomponent>