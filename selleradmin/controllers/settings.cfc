/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="getAllLocations" access="remote" returnformat="json">
		<cfargument name="page" required="no" default="1" hint="Page user is on">
		<cfargument name="rows" required="no" default="10" hint="Number of Rows to display per page">
		<cfargument name="sidx" required="no" default="" hint="Sort Column">
		<cfargument name="sord" required="no" default="ASC" hint="Sort Order">

		<cfset var arrLocations = ArrayNew(1)>
		<cfquery name="getLocations" dbtype="Query">
			Select TContent_ID, LocationName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, Active
			From Session.getLocations
			<cfif Arguments.sidx NEQ "">
				Order By #Arguments.sidx# #Arguments.sord#
			<cfelse>
				Order by LocationName #Arguments.sord#
			</cfif>
		</cfquery>

		<!--- Calculate the Start Position for the loop query. So, if you are on 1st page and want to display 4 rows per page, for first page you start at: (1-1)*4+1 = 1.
				If you go to page 2, you start at (2-)1*4+1 = 5 --->
		<cfset start = ((arguments.page-1)*arguments.rows)+1>

		<!--- Calculate the end row for the query. So on the first page you go from row 1 to row 4. --->
		<cfset end = (start-1) + arguments.rows>

		<!--- When building the array --->
		<cfset i = 1>

		<cfloop query="getLocations" startrow="#start#" endrow="#end#">
			<!--- Array that will be passed back needed by jqGrid JSON implementation --->
			<cfif #Active# EQ 1>
				<cfset strActive = "Yes">
			<cfelse>
				<cfset strActive = "No">
			</cfif>
			<cfset arrLocations[i] = [#TContent_ID#,#LocationName#,#PhysicalAddress#,#PhysicalCity#,#PhysicalState#,#PhysicalZipCode#,#PhysicalZip4#,#strActive#,#PrimaryVoiceNumber#,#GeoCode_Latitude#,#GeoCode_Longitude#]>
			<cfset i = i + 1>
		</cfloop>

		<!--- Calculate the Total Number of Pages for your records. --->
		<cfset totalPages = Ceiling(getLocations.recordcount/arguments.rows)>

		<!--- The JSON return.
			Total - Total Number of Pages we will have calculated above
			Page - Current page user is on
			Records - Total number of records
			rows = our data
		--->
		<cfset stcReturn = {total=#totalPages#,page=#Arguments.page#,records=#getLocations.recordcount#,rows=arrLocations}>
		<cfreturn stcReturn>
	</cffunction>

	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

	</cffunction>

	<cffunction name="locations" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfquery name="Session.getLocations" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select TContent_ID, LocationName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude, Active, dateCreated, lastUpdated, lastUpdateBy
			From p_Auction_Organization_Locations
			Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
				Organization_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.getSellerOrganizationInfo.Organization_ID#">
			Order by LocationName
		</cfquery>
	</cffunction>

	<cffunction name="newlocation" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfset GeoCodeCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/GoogleGeocoder")>
			<cfset AddressGeoCoded = #GeoCodeCFC.GeoCodeAddress(Form.PhysicalAddress, FORM.PhysicalCity, FORM.PhysicalState, FORM.PhysicalZipCode)#>

			<cfif AddressGeoCoded[1].ErrorMessage NEQ "OK">
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						address = {property="BusinessAddress",message="#Variables.AddressGeoCoded[1].ErrorMessageText#"};
						arrayAppend(Session.FormErrors, address);
					</cfscript>
				</cflock>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.newlocation&FormRetry=True&ReEnterAddress=True">
			<cfelse>
				<cfset CombinedPhysicalAddress = #AddressGeoCoded[1].AddressStreetNumber# & " " & #AddressGeoCoded[1].AddressStreetNameShort#>

				<cfquery name="insertOrganizationInfo" result="InsertNewRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Insert into p_Auction_Organization_Locations(Organization_ID, Site_ID, LocationName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PrimaryVoiceNumber, dateCreated, lastUpdated, lastUpdateBy)
					Values(
						<cfqueryparam value="#FORM.OrganizationID#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#FORM.LocationName#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Variables.CombinedPhysicalAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressCityName)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressStateNameShort)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressZipCode)#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#FORM.LocationPhone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.Fname# #Session.Mura.LName#">
					)
				</cfquery>
				<cfset newRecordID = InsertNewRecord.generatedkey>
				<cfif isDefined("Variables.AddressGeoCoded[1].AddressZipCodeFour")>
					<cfquery name="updateFacilityZip4" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Organization_Locations
						Set PhysicalZip4 = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressZipCodeFour)#" cfsqltype="cf_sql_varchar">
						Where TContent_ID = <cfqueryparam value="#variables.newRecordID#" cfsqltype="cf_sql_integer"> and
							Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
				<cfquery name="updateFacilityGeoCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Organization_Locations
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
						lastUpdated = #Now()#, lastUpdateBy = <cfqueryparam value="#Session.Mura.Fname# #Session.Mura.LName#" cfsqltype="cf_sql_varchar">
					Where TContent_ID = <cfqueryparam value="#variables.newRecordID#" cfsqltype="cf_sql_integer"> and
						Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.locations&UserAction=LocationCreated&Successful=True">
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="editlocation" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfquery name="Session.getSelectedLocation" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select TContent_ID, LocationName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, dateCreated, lastUpdated, lastUpdateBy, Active
					From p_Auction_Organization_Locations
					Where Site_ID = <cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar"> and
						TContent_ID = <cfqueryparam value="#URL.LocationID#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif not isDefined("FORM.PerformAction")>
				<cfset GeoCodeCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/GoogleGeocoder")>
				<cfset AddressGeoCoded = #GeoCodeCFC.GeoCodeAddress(Form.PhysicalAddress, FORM.PhysicalCity, FORM.PhysicalState, FORM.PhysicalZipCode)#>

				<cfif AddressGeoCoded[1].ErrorMessage NEQ "OK">
					<cflock timeout="60" scope="SESSION" type="Exclusive">
						<cfscript>
							address = {property="BusinessAddress",message="#Variables.AddressGeoCoded[1].ErrorMessageText#"};
							arrayAppend(Session.FormErrors, address);
						</cfscript>
					</cflock>
					<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.newlocation&FormRetry=True&ReEnterAddress=True">
				<cfelse>
					<cfset CombinedPhysicalAddress = #AddressGeoCoded[1].AddressStreetNumber# & " " & #AddressGeoCoded[1].AddressStreetNameShort#>

					<cfquery name="updateLocationInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Organization_Locations
						Set LocationName = <cfqueryparam value="#FORM.LocationName#" cfsqltype="cf_sql_varchar">,
							PhysicalAddress = <cfqueryparam value="#Variables.CombinedPhysicalAddress#" cfsqltype="cf_sql_varchar">,
							PhysicalCity = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressCityName)#" cfsqltype="cf_sql_varchar">,
							PhysicalState = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressStateNameShort)#" cfsqltype="cf_sql_varchar">,
							PhysicalZipCode = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressZipCode)#" cfsqltype="cf_sql_varchar">,
							Active = <cfqueryparam value="#FORM.LocationActive#" cfsqltype="cf_sql_bit">,
							lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
							lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.Fname# #Session.Mura.LName#">
						Where TContent_ID = <cfqueryparam value="#FORM.LocationID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif isDefined("Variables.AddressGeoCoded[1].AddressZipCodeFour")>
						<cfquery name="updateFacilityZip4" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Update p_Auction_Organization_Locations
							Set PhysicalZip4 = <cfqueryparam value="#Trim(Variables.AddressGeoCoded[1].AddressZipCodeFour)#" cfsqltype="cf_sql_varchar">
							Where TContent_ID = <cfqueryparam value="#FORM.LocationID#" cfsqltype="cf_sql_integer">
						</cfquery>
					</cfif>
					<cfquery name="updateFacilityGeoCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Organization_Locations
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
							lastUpdated = #Now()#, lastUpdateBy = <cfqueryparam value="#Session.Mura.Fname# #Session.Mura.LName#" cfsqltype="cf_sql_varchar">
						Where TContent_ID = <cfqueryparam value="#FORM.LocationID#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.locations&UserAction=LocationUpdated&Successful=True">
				</cfif>
			<cfelse>
				<cfquery name="deleteLocationInformation" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Delete from p_Auction_Organization_Locations
					Where TContent_ID = <cfqueryparam value="#FORM.LocationID#" cfsqltype="cf_sql_integer">
				</cfquery>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.locations&UserAction=LocationDeleted&Successful=True">
			</cfif>

		</cfif>
	</cffunction>

	<cffunction name="updateorganization" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>

		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfset GeoCodeCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/GoogleGeocoder")>
			<cfset PhysicalAddressGeoCoded = #GeoCodeCFC.GeoCodeAddress(Form.PhysicalAddress, FORM.PhysicalCity, FORM.PhysicalState, FORM.PhysicalZipCode)#>

			<cfif PhysicalAddressGeoCoded[1].ErrorMessage NEQ "OK">
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						address = {property="BusinessAddress",message="#Variables.AddressGeoCoded[1].ErrorMessageText#"};
						arrayAppend(Session.FormErrors, address);
					</cfscript>
				</cflock>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.updateorganization&FormRetry=True&ReEnterAddress=True">
			<cfelse>
				<cfset CombinedPhysicalAddress = #PhysicalAddressGeoCoded[1].AddressStreetNumber# & " " & #PhysicalAddressGeoCoded[1].AddressStreetNameShort#>

				<cfquery name="updateOrganizationInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Organizations
					Set BusinessName = <cfqueryparam value="#FORM.OrganizationName#" cfsqltype="cf_sql_varchar">,
						PhysicalAddress = <cfqueryparam value="#Variables.CombinedPhysicalAddress#" cfsqltype="cf_sql_varchar">,
						PhysicalCity = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressCityName)#" cfsqltype="cf_sql_varchar">,
						PhysicalState = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressStateNameShort)#" cfsqltype="cf_sql_varchar">,
						PhysicalZipCode = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressZipCode)#" cfsqltype="cf_sql_varchar">,
						lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.Fname# #Session.Mura.LName#">
					Where TContent_ID = <cfqueryparam value="#FORM.OrganizationID#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif isDefined("Variables.AddressGeoCoded[1].AddressZipCodeFour")>
					<cfquery name="updateOrganizationZip4" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Organizations
						Set PhysicalZip4 = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressZipCodeFour)#" cfsqltype="cf_sql_varchar">
						Where TContent_ID = <cfqueryparam value="#FORM.OrganizationID#" cfsqltype="cf_sql_integer">
					</cfquery>
				</cfif>
				<cfquery name="updateOrganizationGeoCode" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Organizations
					Set GeoCode_Latitude = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressLatitude)#" cfsqltype="cf_sql_varchar">,
						GeoCode_Longitude = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressLongitude)#" cfsqltype="cf_sql_varchar">,
						<cfif isDefined("Variables.PhysicalAddressGeoCoded[1].AddressTownshipNameLong")>
							GeoCode_Township = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressTownshipNameLong)#" cfsqltype="cf_sql_varchar">,
						</cfif>
						<cfif isDefined("Variables.PhysicalAddressGeoCoded[1].NeighborhoodNameLong")>
							GeoCode_Neighborhood = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].NeighborhoodNameLong)#" cfsqltype="cf_sql_varchar">,
						</cfif>
						GeoCode_StateLongName = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressStateNameLong)#" cfsqltype="cf_sql_varchar">,
						GeoCode_CountryShortName = <cfqueryparam value="#Trim(Variables.PhysicalAddressGeoCoded[1].AddressCountryNameShort)#" cfsqltype="cf_sql_varchar">,
						isAddressVerified = <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
						lastUpdated = #Now()#, lastUpdateBy = <cfqueryparam value="#Session.Mura.Fname# #Session.Mura.LName#" cfsqltype="cf_sql_varchar">
					Where TContent_ID = <cfqueryparam value="#FORM.OrganizationID#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cfif>

			<cfif Len(Form.MailingAddress) and LEN(FORM.MailingCity) and LEN(FORM.MailingState) and LEN(FORM.MailingZipCode)>
				<cfset MailingAddressGeoCoded = #GeoCodeCFC.GeoCodeAddress(Form.MailingAddre, FORM.MailingCity, FORM.MailingState, FORM.MailingZipCode)#>
				<cfif MailingAddressGeoCoded[1].ErrorMessage NEQ "OK">
					<cflock timeout="60" scope="SESSION" type="Exclusive">
						<cfscript>
							address = {property="BusinessAddress",message="#Variables.AddressGeoCoded[1].ErrorMessageText#"};
							arrayAppend(Session.FormErrors, address);
						</cfscript>
					</cflock>
					<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:settings.updateorganization&FormRetry=True&ReEnterAddress=True">
				<cfelse>
					<cfset CombinedMailingAddress = #MailingAddressGeoCoded[1].AddressStreetNumber# & " " & #MailingAddressGeoCoded[1].AddressStreetNameShort#>
					<cfquery name="updateOrganizationInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Organizations
						Set MailingAddress = <cfqueryparam value="#Variables.CombinedMailingAddress#" cfsqltype="cf_sql_varchar">,
							MailingCity = <cfqueryparam value="#Trim(Variables.MailingAddressGeoCoded[1].AddressCityName)#" cfsqltype="cf_sql_varchar">,
							MailingState = <cfqueryparam value="#Trim(Variables.MailingAddressGeoCoded[1].AddressStateNameShort)#" cfsqltype="cf_sql_varchar">,
							MailingZipCode = <cfqueryparam value="#Trim(Variables.MailingAddressGeoCoded[1].AddressZipCode)#" cfsqltype="cf_sql_varchar">,
							lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
							lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.Fname# #Session.Mura.LName#">
						Where TContent_ID = <cfqueryparam value="#FORM.OrganizationID#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif isDefined("Variables.MailingAddressGeoCoded[1].AddressZipCodeFour")>
						<cfquery name="updateOrganizationZip4" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Update p_Auction_Organizations
							Set PhysicalZip4 = <cfqueryparam value="#Trim(Variables.MailingAddressGeoCoded[1].AddressZipCodeFour)#" cfsqltype="cf_sql_varchar">
							Where TContent_ID = <cfqueryparam value="#FORM.OrganizationID#" cfsqltype="cf_sql_integer">
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
			<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:main.default&UserAction=OrganizationUpdated&Successful=True">
		</cfif>

	</cffunction>

</cfcomponent>