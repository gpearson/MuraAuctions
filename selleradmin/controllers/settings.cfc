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

			<cfset AddressGeoCoded = #GeoCodeAddress(Form.PhysicalAddress, FORM.PhysicalCity, FORM.PhysicalState, FORM.PhysicalZipCode)#>

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
				<cfset AddressGeoCoded = #GeoCodeAddress(Form.PhysicalAddress, FORM.PhysicalCity, FORM.PhysicalState, FORM.PhysicalZipCode)#>

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

</cfcomponent>