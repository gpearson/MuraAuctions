/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

	</cffunction>

	<cffunction name="getAllAuctions" access="remote" returnformat="json">
		<cfargument name="page" required="no" default="1" hint="Page user is on">
		<cfargument name="rows" required="no" default="10" hint="Number of Rows to display per page">
		<cfargument name="sidx" required="no" default="" hint="Sort Column">
		<cfargument name="sord" required="no" default="ASC" hint="Sort Order">

		<cfset var arrAuctions = ArrayNew(1)>
		<cfquery name="getAuctions" dbtype="Query">
			Select TContent_ID, Item_Title, Location_ID, Item_ModelNumber, Item_Description, Item_Condition, Item_UPC, Item_PrimaryPhoto, Item_SecondaryPhoto, Item_TertiaryPhoto, Auction_StartDate, Auction_EndDate, Auction_Category, Auction_Type, Starting_Price, dateCreated, lastUpdated, lastUpdateBy, lastUpdateById, Active
			From Session.getOrganizationAllAuctions
			<cfif Arguments.sidx NEQ "">
				Order By #Arguments.sidx# #Arguments.sord#
			<cfelse>
				Order by Auction_StartDate #Arguments.sord#, Item_Title #Arguments.sord#
			</cfif>
		</cfquery>

		<!--- Calculate the Start Position for the loop query. So, if you are on 1st page and want to display 4 rows per page, for first page you start at: (1-1)*4+1 = 1.
				If you go to page 2, you start at (2-)1*4+1 = 5 --->
		<cfset start = ((arguments.page-1)*arguments.rows)+1>

		<!--- Calculate the end row for the query. So on the first page you go from row 1 to row 4. --->
		<cfset end = (start-1) + arguments.rows>

		<!--- When building the array --->
		<cfset i = 1>

		<cfloop query="getAuctions" startrow="#start#" endrow="#end#">
			<!--- Array that will be passed back needed by jqGrid JSON implementation --->
			<cfif #Active# EQ 1>
				<cfset strActive = "Yes">
			<cfelse>
				<cfset strActive = "No">
			</cfif>
			<cfset arrAuctions[i] = [#TContent_ID#,#Item_Title#,#Starting_Price#,0,#DateFormat(Auction_StartDate, 'mm/dd/yy')#,#DateFormat(Auction_EndDate, 'mm/dd/yy')#,#strActive#]>
			<cfset i = i + 1>
		</cfloop>

		<!--- Calculate the Total Number of Pages for your records. --->
		<cfset totalPages = Ceiling(getAuctions.recordcount/arguments.rows)>

		<!--- The JSON return.
			Total - Total Number of Pages we will have calculated above
			Page - Current page user is on
			Records - Total number of records
			rows = our data
		--->
		<cfset stcReturn = {total=#totalPages#,page=#Arguments.page#,records=#getAuctions.recordcount#,rows=arrAuctions}>
		<cfreturn stcReturn>
	</cffunction>

	<cffunction name="addauction" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit") and not isDefined("FORM.UpdateAuctionInfo")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfquery name="Session.getLocations" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select TContent_ID, LocationName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, GeoCode_Latitude, GeoCode_Longitude
					From p_Auction_Organization_Locations
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
						Organization_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.getSellerOrganizationInfo.Organization_ID#">
				</cfquery>
				<cfquery name="getParentCategories" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Category_ID, Category_Name
					From p_Auction_ProductCategories
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
						isActive = <cfqueryparam cfsqltype="cf_sql_bit" value="1"> and
						ParentCategory_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
				</cfquery>

				<cfset Session.CategoryQuery = QueryNew("ID,CategoryName", "Integer,VarChar")>
				<cfloop query="getParentCategories">
					<cfset temp = QueryAddRow(Session.CategoryQuery, 1)>
					<cfset temp = #QuerySetCell(Session.CategoryQuery, "ID", getParentCategories.Category_ID)#>
					<cfset temp = #QuerySetCell(Session.CategoryQuery, "CategoryName", getParentCategories.Category_Name)#>

					<cfquery name="getChildrenCategories" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select Category_ID, Category_Name
						From p_Auction_ProductCategories
						Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
							isActive = <cfqueryparam cfsqltype="cf_sql_bit" value="1"> and
							ParentCategory_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getParentCategories.Category_ID#">
					</cfquery>
					<cfif getChildrenCategories.RecordCount>
						<cfloop query="getChildrenCategories">
							<cfset tmpCategoryName = #getParentCategories.Category_Name# & " -> " & #getChildrenCategories.Category_Name#>
							<cfset temp = QueryAddRow(Session.CategoryQuery, 1)>
							<cfset temp = #QuerySetCell(Session.CategoryQuery, "ID", getChildrenCategories.Category_ID)#>
							<cfset temp = #QuerySetCell(Session.CategoryQuery, "CategoryName", Variables.tmpCategoryName)#>
						</cfloop>
					</cfif>
				</cfloop>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit") and not isDefined("FORM.UpdateAuctionInfo")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif not isValid("usdate", FORM.AuctionStartDate)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						address = {property="BusinessAddress",message="The Auction Start Date did not appear to be in a valid United States Date Format"};
						arrayAppend(Session.FormErrors, address);
					</cfscript>
				</cflock>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:auctions.addauction&FormRetry=True">
			</cfif>

			<cffile action="upload" fileField="FORM.ItemPrimaryPhoto" result="ItemPrimaryPhoto" destination="#GetTempDirectory()#" nameconflict="MakeUnique">
			<cfset NewServerPrimaryPhoto = #Replace(Variables.ItemPrimaryPhoto.ServerFile, " ", "_", "ALL")#>
			<cfset NewServerPrimaryPhoto = #Replace(Variables.NewServerPrimaryPhoto, "'", "_", "ALL")#>
			<cffile action="rename" source="#GetTempDirectory()#/#Variables.ItemPrimaryPhoto.ServerFile#" Destination="#GetTempDirectory()#/#Variables.NewServerPrimaryPhoto#">
			<cfdirectory action="list" directory="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#" name="DoesDirectoryExists">
			<cfif DoesDirectoryExists.RecordCount EQ 0><cfdirectory action="Create" directory="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#"></cfif>
			<cffile action="move" source="#GetTempDirectory()#/#Variables.NewServerPrimaryPhoto#" Destination="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#/#Variables.NewServerPrimaryPhoto#">

			<cfif LEN(FORM.ItemSecondaryPhoto)>
				<cffile action="upload" fileField="FORM.ItemSecondaryPhoto" result="ItemSecondaryPhoto" destination="#GetTempDirectory()#" nameconflict="MakeUnique">
				<cfset NewServerSecondaryPhoto = #Replace(Variables.ItemSecondaryPhoto.ServerFile, " ", "_", "ALL")#>
				<cfset NewServerSecondaryPhoto = #Replace(Variables.NewServerSecondaryPhoto, "'", "_", "ALL")#>
				<cffile action="rename" source="#GetTempDirectory()#/#Variables.ItemSecondaryPhoto.ServerFile#" Destination="#GetTempDirectory()#/#Variables.NewServerSecondaryPhoto#">
				<cfdirectory action="list" directory="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#" name="DoesDirectoryExists">
				<cfif DoesDirectoryExists.RecordCount EQ 0><cfdirectory action="Create" directory="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#"></cfif>
				<cffile action="move" source="#GetTempDirectory()#/#Variables.NewServerSecondaryPhoto#" Destination="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#/#Variables.NewServerSecondaryPhoto#">
			</cfif>

			<cfif LEN(FORM.ItemTertiaryPhoto)>
				<cffile action="upload" fileField="FORM.ItemTertiaryPhoto" result="ItemTertiaryPhoto" destination="#GetTempDirectory()#" nameconflict="MakeUnique">
				<cfset NewServerTertiaryPhoto = #Replace(Variables.ItemTertiaryPhoto.ServerFile, " ", "_", "ALL")#>
				<cfset NewServerTertiaryPhoto = #Replace(Variables.NewServerTertiaryPhoto, "'", "_", "ALL")#>
				<cffile action="rename" source="#GetTempDirectory()#/#Variables.NewServerTertiaryPhoto.ServerFile#" Destination="#GetTempDirectory()#/#Variables.NewServerTertiaryPhoto#">
				<cfdirectory action="list" directory="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#" name="DoesDirectoryExists">
				<cfif DoesDirectoryExists.RecordCount EQ 0><cfdirectory action="Create" directory="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#"></cfif>
				<cffile action="move" source="#GetTempDirectory()#/#Variables.NewServerTertiaryPhoto#" Destination="#rc.pc.getFullPath()#/includes/assets/#Session.Mura.UserID#/#Variables.NewServerTertiaryPhoto#">
			</cfif>

			<cfset AuctionEndDate = #DateAdd("d", FORM.AuctionLength, FORM.AuctionStartDate)#>

			<cfquery name="insertNewAuction" result="InsertNewRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Insert into p_Auction_Items(Item_Title, Organization_ID, Site_ID, Item_ModelNumber, Item_Description, Item_Condition, Item_WebDirectory, Item_PrimaryPhoto, Auction_StartDate, Auction_EndDate, Auction_Category, Auction_Type, dateCreated, lastUpdateBy, lastUpdateByID, Active)
				Values(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemName#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.OrganizationID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemModelNumber#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemDescription#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#FORM.ItemCondition#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/photos/#Session.Mura.UserID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Variables.NewServerPrimaryPhoto#">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#FORM.AuctionStartDate#">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#Variables.AuctionEndDate#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionCategory#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.AuctionType#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
					<cfqueryparam cfsqltype="cf_sql_bit" value="1">
				)
			</cfquery>

			<cfif LEN(FORM.ItemUPC)>
				<cfquery name="updateAuctionRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Items
					Set Item_UPC = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.ItemUPC#">,
						lastUpdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
						lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
						lastUpdateByID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
					Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Variables.InsertNewRecord.generatedKey#">
				</cfquery>
			</cfif>

			<cfif LEN(FORM.ItemSecondaryPhoto)>
				<cfquery name="updateAuctionRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Items
					Set Item_SecondaryPhoto = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Variables.NewServerSecondaryPhoto#">,
						lastUpdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
						lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
						lastUpdateByID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
					Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Variables.InsertNewRecord.generatedKey#">
				</cfquery>
			</cfif>

			<cfif LEN(FORM.ItemTertiaryPhoto)>
				<cfquery name="updateAuctionRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Items
					Set Item_TertiaryPhoto = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Variables.NewServerTertiaryPhoto#">,
						lastUpdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
						lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
						lastUpdateByID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
					Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Variables.InsertNewRecord.generatedKey#">
				</cfquery>
			</cfif>

			<cfif FORM.LocationIDParent EQ "true">
				<cfquery name="updateAuctionRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Items
					Set Location_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="0">,
						lastUpdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
						lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
						lastUpdateByID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
					Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Variables.InsertNewRecord.generatedKey#">
				</cfquery>
			<cfelse>
				<cfquery name="updateAuctionRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_Items
					Set Location_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.LocationID#">,
						lastUpdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
						lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
						lastUpdateByID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
					Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Variables.InsertNewRecord.generatedKey#">
				</cfquery>
			</cfif>

			<cfswitch expression="#FORM.AuctionType#">
				<cfcase value="Fixed">
					<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:auctions.addauction&AuctionID=#Variables.InsertNewRecord.generatedKey#&AuctionType=Fixed">
				</cfcase>
				<cfcase value="Auction">
					<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:auctions.addauction&AuctionID=#Variables.InsertNewRecord.generatedKey#&AuctionType=Auction">
				</cfcase>
			</cfswitch>
		<cfelseif isDefined("FORM.formSubmit") and isDefined("FORM.UpdateAuctionInfo")>
			<cfswitch expression="#FORM.AuctionType#">
				<cfcase value="Fixed">
					<cfquery name="updateAuctionRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Items
						Set Starting_Price = <cfqueryparam cfsqltype="cf_sql_double" value="#FORM.AuctionStartPrice#">,
							Current_Bid = <cfqueryparam cfsqltype="cf_sql_double" value="#FORM.AuctionStartPrice#">,
							lastUpdated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
							lastUpdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.currentUser('userName')#">,
							lastUpdateByID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
						Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
					</cfquery>
					<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=selleradmin:main.default&UserAction=AuctionCreated&Successful=True">
				</cfcase>
				<cfcase value="Auction">

				</cfcase>
			</cfswitch>
		</cfif>

	</cffunction>

</cfcomponent>