/*


*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="true">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

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
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&FormRetry=True&User=#URL.User#&Successful=#URL.Successful#">
			</cfif>

			<cfset AddressGeoCoded = #GeoCodeAddress(Form.PhysicalAddress, FORM.PhysicalCity, FORM.PhysicalState, FORM.PhysicalZipCode)#>

			<cfif AddressGeoCoded[1].ErrorMessage NEQ "OK">
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						address = {property="BusinessAddress",message="#Variables.AddressGeoCoded[1].ErrorMessageText#"};
						arrayAppend(Session.FormErrors, address);
					</cfscript>
				</cflock>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&FormRetry=True&ReEnterAddress=True">
			<cfelse>
				<cfset CombinedPhysicalAddress = #AddressGeoCoded[1].AddressStreetNumber# & " " & #AddressGeoCoded[1].AddressStreetNameShort#>

				<cfquery name="insertOrganizationInfo" result="InsertNewRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Insert into p_Auction_Organizations(BusinessName, Site_ID, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PrimaryVoiceNumber, Federal_EIN, dateCreated, lastUpdated, lastUpdateBy)
					Values(
						<cfqueryparam value="#FORM.OrganizationName#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Variables.CombinedPhysicalAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressCityName)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressStateNameShort)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressZipCode)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#FORM.OrganizationPhone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#FORM.FederalEIN#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="System" cfsqltype="cf_sql_varchar">
					)
				</cfquery>
				<cfset newRecordID = InsertNewRecord.generatedkey>
				<cfif isDefined("Variables.AddressGeoCoded[1].AddressZipCodeFour")>
					<cfquery name="updateFacilityGeoCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Organizations
						Set PhysicalZip4 = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressZipCodeFour)#" cfsqltype="cf_sql_varchar">
						Where TContent_ID = <cfqueryparam value="#variables.newRecordID#" cfsqltype="cf_sql_integer"> and
							Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
				<cfquery name="updateFacilityGeoCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Organizations
					Set GeoCode_Latitude = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressLatitude)#" cfsqltype="cf_sql_varchar">,
						GeoCode_Longitude = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressLongitude)#" cfsqltype="cf_sql_varchar">,
						<cfif isDefined("Variables.AddressGeoCoded[1].AddressTownshipNameLong")>
							GeoCode_Township = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressTownshipNameLong)#" cfsqltype="cf_sql_varchar">,
						</cfif>
						<cfif isDefined("Variables.AddressGeoCoded[1].NeighborhoodNameLong")>
							GeoCode_Neighborhood = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].NeighborhoodNameLong)#" cfsqltype="cf_sql_varchar">,
						</cfif>
						GeoCode_StateLongName = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressStateNameLong)#" cfsqltype="cf_sql_varchar">,
						GeoCode_CountryShortName = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressCountryNameShort)#" cfsqltype="cf_sql_varchar">,
						isAddressVerified = <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
						Active = <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
						lastUpdated = #Now()#, lastUpdateBy = <cfqueryparam value="System" cfsqltype="cf_sql_varchar">
					Where TContent_ID = <cfqueryparam value="#variables.newRecordID#" cfsqltype="cf_sql_integer"> and
						Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfquery name="updateUserMatrix" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_UserMatrix
					Set Organization_ID = <cfqueryparam value="#variables.newRecordID#" cfsqltype="cf_sql_integer">
					Where User_ID = <cfqueryparam value="#FORM.UserID#" cfsqltype="cf_sql_varchar"> and
						Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>
				<cfset SendContactEmail = #SendEmailCFC.SendSellerAccountContractEmail(rc, FORM.UserID)#>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&UserAction=OrganizationInfoCreated&AccountType=Seller&Successful=True">
			</cfif>
		</cfif>
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
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif FORM.YourDesiredPassword NEQ FORM.VerifyDesiredPassword>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Password Field did not match the Verify Password Field. Please correct this before proceeding"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif not isValid("email", FORM.ContactEmail)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Email Address entered did not look like it was in proper email format. Please check the email address again before proceeding"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif not isValid("telephone", FORM.ContactPhone)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Contact Telephone Number entered was not a standard United States Telephone Number. Please check this telephone number again before proceeding."};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
			</cfif>

			<cfif not isValid("zipcode", FORM.YourZipCode)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Zip Code entered was not a standard United States ZipCode. Please check the zipcode entered and correct this field before proceeding."};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
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
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.account&FormRetry=True">
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

					<cfswitch expression="#FORM.TypeOfAccountRequested#">
						<cfcase value="1">
							<!--- This Account Type is Buyers --->
							<cfset SendActivationEmail = #SendEmailCFC.SendBuyerAccountActivationEmail(rc, Variables.NewUserID)#>
							<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&UserAction=AccountCreated&Successful=True">
						</cfcase>
						<cfcase value="0">
							<!--- This Account Type is Sellers --->
							<cfset SendActivationEmail = #SendEmailCFC.SendSellerAccountActivationEmail(rc, Variables.NewUserID)#>
							<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:register.default&UserAction=AccountCreated&AccountType=Seller&Successful=True&User=#Variables.NewUserID#">
						</cfcase>
					</cfswitch>

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


	<cffunction name="GeoCodeAddress" ReturnType="Array" Output="False">
		<cfargument name="Address" type="String" required="True">
		<cfargument name="City" type="String" required="True">
		<cfargument name="State" type="String" required="True">
		<cfargument name="ZipCode" type="String" required="True">

		<cfset GeoCodeStreetAddress = #Replace(Trim(Arguments.Address), " ", "+", "ALL")#>
		<cfset GeoCodeCity = #Replace(Trim(Arguments.City), " ", "+", "ALL")#>
		<cfset GeoCodeState = #Replace(Trim(Arguments.State), " ", "+", "ALL")#>
		<cfset GeoCodeZipCode = #Trim(Arguments.ZipCode)#>

		<cfset GeoCodeAddress = ArrayNew(1)>
		<cfset Temp = StructNew()>

		<cfhttp URL="http://maps.google.com/maps/api/geocode/xml?address=#Variables.GeoCodeStreetAddress#,+#Variables.GeoCodeCity#,+#Variables.GeoCodeState#,+#Variables.GeoCodeZipCode#&sensor=false" method="Get" result="GetCodePageContent" resolveurl="true"></cfhttp>

		<cfif GetCodePageContent.FileContent Contains "REQUEST_DENIED">
			<cfset Temp.ErrorMessage = "Google Request Denied">
			<cfset Temp.AddressStreetNumber = "">
			<cfset Temp.AddressStreetName = "">
			<cfset Temp.AddressCityName = "">
			<cfset Temp.AddressStateNameLong = "">
			<cfset Temp.AddressStateNameShort = "">
			<cfset Temp.AddressZipCode = "">
			<cfset Temp.AddressTownshipName = "">
			<cfset Temp.AddressNeighborhoodName = "">
			<cfset Temp.AddressCountyName = "">
			<cfset Temp.AddressCountryNameLong = "">
			<cfset Temp.AddressCountryNameShort = "">
			<cfset Temp.AddressLatitude = "">
			<cfset Temp.AddressLongitude = "">
			<cfset #arrayAppend(GeoCodeAddress, Temp)#>
		</cfif>

		<cfset XMLDocument = #XMLParse(GetCodePageContent.FileContent)#>
		<cfset GeoCodeResponseStatus = #XMLSearch(Variables.XMLDocument, "/GeocodeResponse/status")#>
		<cfset GeoCodeResultFormattedAddressType = #XmlSearch(Variables.XMLDocument, "/GeocodeResponse/result/type")#>
		<cfset GeoCodeResultFormattedAddress = #XmlSearch(Variables.XMLDocument, "/GeocodeResponse/result/formatted_address")#>
		<cfset GeoCodeResultAddressComponent = #XMLSearch(Variables.XMLDocument, "/GeocodeResponse/result/address_component")#>
		<cfset GeoCodeResultGeometryComponent = #XMLSearch(XMLDocument, "/GeocodeResponse/result/geometry")#>

		<cfswitch expression="#GeoCodeResponseStatus[1].XMLText#">
			<cfcase value="ZERO_RESULTS">
				<!--- Indicates that the geocode was successful but returned no results. This may occur if the geocode was passed a non-existent address
						or latlng in a remote location --->
			</cfcase>
			<cfcase value="OVER_QUERY_LIMIT">
				<!--- Indicates that you are over your quota --->
			</cfcase>
			<cfcase value="REQUEST_DENIED">
				<!--- Indicates that your request was denied, generally becasue of lack of a sensor parameter --->
			</cfcase>
			<cfcase value="INVALID_REQUEST">
				<!--- generally indicates that the query (address or latlng) is missing --->
			</cfcase>
			<cfcase value="UNKNOWN_ERROR">
				<!--- Indicates that the request could not be processed do to a server error. The request may sicceed if you try again --->
			</cfcase>
			<cfcase value="OK">
				<cfswitch expression="#GeoCodeResultFormattedAddressType[1].XMLText#">
					<cfcase value="route">
						<cfset Temp.ErrorMessage = "Unable Locate Address">
						<cfset Temp.ErrorMessageText = "Unable to locate the address you entered as a valid address.">
						<cfset Temp.Address = #Arguments.Address#>
						<cfset Temp.City = #Arguments.City#>
						<cfset Temp.State = #Arguments.State#>
						<cfset Temp.ZipCode = #Arguments.ZipCode#>
						<cfset #arrayAppend(GeoCodeAddress, Temp)#>
						<cfreturn GeoCodeAddress>
					</cfcase>
					<cfcase value="street_address">
						<cfswitch expression="#ArrayLen(GeoCodeResultAddressComponent)#">
							<cfcase value="10">
								<!--- Address Example: 57405 Horseshoe Court, Goshen, IN 46528 --->
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultNeighborhoodName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultTownshipName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[8].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[9].XmlChildren;
									GeoCodeResultZipCodeSuffix = GeoCodeResultAddressComponent[10].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>
								<cfset Temp.RawInformation = StructNew()>
								<cfset Temp.RawInformation.XMLDocument = #Variables.XMLDocument#>
								<cfset Temp.RawInformation.ResponseStatus = #Variables.GeoCodeResponseStatus#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddressType = #Variables.GeoCodeResultFormattedAddressType#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddress = #Variables.GeoCodeResultFormattedAddress#>
								<cfset Temp.RawInformation.GeoCodeResultAddressComponent = #Variables.GeoCodeResultAddressComponent#>
								<cfset Temp.RawInformation.GeoCodeResultGeometryComponent = #Variables.GeoCodeResultGeometryComponent#>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressZipCodeFour = #GeoCodeResultZipCodeSuffix[1].XMLText#>
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset Temp.AddressTownshipNameLong = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset Temp.AddressTownshipNameShort = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset Temp.NeighborhoodNameLong = #GeoCodeResultNeighborhoodName[1].XMLText#>
								<cfset Temp.NeighborhoodNameShort = #GeoCodeResultNeighborhoodName[2].XMLText#>
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfcase>
							<cfcase value="9">
								<!--- Address Example: 56535 Magnetic Drive, Mishwaka, IN 46545 --->
								<!--- Address Example: 2307 Edison Road, South Bend, IN 46615 --->
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultTownshipName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[8].XmlChildren;
									GeoCodeResultZipCodeSuffix = GeoCodeResultAddressComponent[9].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>

								<cfset Temp.RawInformation = StructNew()>
								<cfset Temp.RawInformation.XMLDocument = #Variables.XMLDocument#>
								<cfset Temp.RawInformation.ResponseStatus = #Variables.GeoCodeResponseStatus#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddressType = #Variables.GeoCodeResultFormattedAddressType#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddress = #Variables.GeoCodeResultFormattedAddress#>
								<cfset Temp.RawInformation.GeoCodeResultAddressComponent = #Variables.GeoCodeResultAddressComponent#>
								<cfset Temp.RawInformation.GeoCodeResultGeometryComponent = #Variables.GeoCodeResultGeometryComponent#>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressTownshipNameLong = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset Temp.AddressTownshipNameShort = #GeoCodeResultTownshipName[2].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressZipCodeFour = #GeoCodeResultZipCodeSuffix[1].XMLText#>
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfcase>
							<cfcase value="8">
								<!--- Address Example: 410 N First St, Argos IN 46501 --->
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultTownshipName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[8].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>
								<cfset Temp.RawInformation = StructNew()>
								<cfset Temp.RawInformation.XMLDocument = #Variables.XMLDocument#>
								<cfset Temp.RawInformation.ResponseStatus = #Variables.GeoCodeResponseStatus#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddressType = #Variables.GeoCodeResultFormattedAddressType#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddress = #Variables.GeoCodeResultFormattedAddress#>
								<cfset Temp.RawInformation.GeoCodeResultAddressComponent = #Variables.GeoCodeResultAddressComponent#>
								<cfset Temp.RawInformation.GeoCodeResultGeometryComponent = #Variables.GeoCodeResultGeometryComponent#>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressTownshipNameLong = #GeoCodeResultTownshipName[1].XMLText#>
								<cfset Temp.AddressTownshipNameShort = #GeoCodeResultTownshipName[2].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressZipCodeFour = "">
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfcase>
							<cfdefaultcase>
								<cfscript>
									GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
									GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
									GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
									GeoCodeResultCountyName = GeoCodeResultAddressComponent[4].XmlChildren;
									GeoCodeResultStateName = GeoCodeResultAddressComponent[5].XmlChildren;
									GeoCodeResultCountryName = GeoCodeResultAddressComponent[6].XmlChildren;
									GeoCodeResultZipCode = GeoCodeResultAddressComponent[7].XmlChildren;
									GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
									GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
								</cfscript>

								<cfset Temp.RawInformation = StructNew()>
								<cfset Temp.RawInformation.XMLDocument = #Variables.XMLDocument#>
								<cfset Temp.RawInformation.ResponseStatus = #Variables.GeoCodeResponseStatus#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddressType = #Variables.GeoCodeResultFormattedAddressType#>
								<cfset Temp.RawInformation.GeoCodeResultFormattedAddress = #Variables.GeoCodeResultFormattedAddress#>
								<cfset Temp.RawInformation.GeoCodeResultAddressComponent = #Variables.GeoCodeResultAddressComponent#>
								<cfset Temp.RawInformation.GeoCodeResultGeometryComponent = #Variables.GeoCodeResultGeometryComponent#>
								<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
								<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
								<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
								<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
								<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
								<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
								<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
								<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
								<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
								<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
								<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
								<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
								<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
								<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
								<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
								<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
								<cfset Temp.AddressTownshipNameLong = "">
								<cfset Temp.AddressTownshipNameShort = "">
								<cfset Temp.NeighborhoodNameLong = "">
								<cfset Temp.NeighborhoodNameShort = "">
								<cfset #arrayAppend(GeoCodeAddress, Temp)#>
							</cfdefaultcase>
						</cfswitch>
					</cfcase>
					<cfcase value="postal_code">
						<cfset Temp.ErrorMessage = "Unable Locate Address">
						<cfset Temp.ErrorMessageText = "Unable to locate the address you entered as a valid address.">
						<cfset Temp.Address = #Arguments.Address#>
						<cfset Temp.City = #Arguments.City#>
						<cfset Temp.State = #Arguments.State#>
						<cfset Temp.ZipCode = #Arguments.ZipCode#>
						<cfset #arrayAppend(GeoCodeAddress, Temp)#>
						<cfreturn GeoCodeAddress>
					</cfcase>
					<cfcase value="premise">
						<!--- Address Example: 29125 Co Rd 22, Elkhart, IN 46517, USA --->
						<cfscript>
							GeoCodeResultStreetNumber = GeoCodeResultAddressComponent[1].XmlChildren;
							GeoCodeResultStreetName = GeoCodeResultAddressComponent[2].XmlChildren;
							GeoCodeResultCityName = GeoCodeResultAddressComponent[3].XmlChildren;
							GeoCodeResultTownshipName = GeoCodeResultAddressComponent[4].XmlChildren;
							GeoCodeResultCountyName = GeoCodeResultAddressComponent[5].XmlChildren;
							GeoCodeResultStateName = GeoCodeResultAddressComponent[6].XmlChildren;
							GeoCodeResultCountryName = GeoCodeResultAddressComponent[7].XmlChildren;
							GeoCodeResultZipCode = GeoCodeResultAddressComponent[8].XmlChildren;
							GeoCodeAddressLocation = GeoCodeResultGeometryComponent[1].XmlChildren;
							GeoCodeFormattedAddress = GeoCodeResultFormattedAddress[1].XmlText;
						</cfscript>

						<cfset Temp.RawInformation = StructNew()>
						<cfset Temp.RawInformation.XMLDocument = #Variables.XMLDocument#>
						<cfset Temp.RawInformation.ResponseStatus = #Variables.GeoCodeResponseStatus#>
						<cfset Temp.RawInformation.GeoCodeResultFormattedAddressType = #Variables.GeoCodeResultFormattedAddressType#>
						<cfset Temp.RawInformation.GeoCodeResultFormattedAddress = #Variables.GeoCodeResultFormattedAddress#>
						<cfset Temp.RawInformation.GeoCodeResultAddressComponent = #Variables.GeoCodeResultAddressComponent#>
						<cfset Temp.RawInformation.GeoCodeResultGeometryComponent = #Variables.GeoCodeResultGeometryComponent#>
						<cfset Temp.ErrorMessage = #GeoCodeResponseStatus[1].XMLText#>
						<cfset Temp.AddressStreetNumber = #GeoCodeResultStreetNumber[1].XMLText#>
						<cfset Temp.AddressStreetNameLong = #GeoCodeResultStreetName[1].XMLText#>
						<cfset Temp.AddressStreetNameShort = #GeoCodeResultStreetName[2].XMLText#>
						<cfset Temp.AddressStreetNameType = #GeoCodeResultStreetName[3].XMLText#>
						<cfset Temp.AddressCityName = #GeoCodeResultCityName[1].XMLText#>
						<cfset Temp.AddressCountyNameLong = #GeoCodeResultCountyName[1].XMLText#>
						<cfset Temp.AddressCountyNameShort = #GeoCodeResultCountyName[2].XMLText#>
						<cfset Temp.AddressStateNameLong = #GeoCodeResultStateName[1].XMLText#>
						<cfset Temp.AddressStateNameShort = #GeoCodeResultStateName[2].XMLText#>
						<cfset Temp.AddressCountryNameLong = #GeoCodeResultCountryName[1].XMLText#>
						<cfset Temp.AddressCountryNameShort = #GeoCodeResultCountryName[2].XMLText#>
						<cfset Temp.AddressZipCode = #GeoCodeResultZipCode[1].XMLText#>
						<cfset Temp.AddressLocation = #GeoCodeAddressLocation[1].XMLChildren#>
						<cfset Temp.AddressLatitude = #Temp.AddressLocation[1].XMLText#>
						<cfset Temp.AddressLongitude = #Temp.AddressLocation[2].XMLText#>
						<cfset Temp.AddressTownshipNameLong = #GeoCodeResultTownshipName[1].XMLText#>
						<cfset Temp.AddressTownshipNameShort = #GeoCodeResultTownshipName[2].XMLText#>
						<cfset Temp.NeighborhoodNameLong = "">
						<cfset Temp.NeighborhoodNameShort = "">
						<cfset #arrayAppend(GeoCodeAddress, Temp)#>
					</cfcase>
					<cfdefaultcase>
						<cfoutput>#GeoCodeResultFormattedAddressType[1].XMLText#</cfoutput><hr>
						<cfdump var="#XMLDocument#">
						<cfdump var="#GeoCodeResponseStatus#">
						<cfdump var="#GeoCodeResultFormattedAddressType#">
						<cfdump var="#GeoCodeResultFormattedAddress#">
						<cfabort>
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
		</cfswitch>
		<cfreturn GeoCodeAddress>
	</cffunction>
</cfcomponent>