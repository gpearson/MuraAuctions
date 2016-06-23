/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif Session.Mura.IsLoggedIn EQ true>
			<cfquery name="checkForSellerAccount" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Select AccountType
				From p_Auction_UserMatrix
				Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and User_ID = <cfqueryparam value="#Session.Mura.UserID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif checkForSellerAccount.AccountType EQ 0>
				<cfquery name="Session.getSellerOrganizationInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select p_Auction_UserMatrix.AccountType, p_Auction_UserMatrix.Organization_ID, p_Auction_Organizations.BusinessName, p_Auction_Organizations.PhysicalAddress, p_Auction_Organizations.PhysicalCity, p_Auction_Organizations.PhysicalState, p_Auction_Organizations.PhysicalZipCode, p_Auction_Organizations.PhysicalZip4, p_Auction_Organizations.Federal_EIN, p_Auction_Organizations.PrimaryVoiceNumber, p_Auction_Organizations.BusinessWebsite, p_Auction_Organizations.GeoCode_Latitude, p_Auction_Organizations.GeoCode_Longitude, p_Auction_UserMatrix.ReceivedSellerContract
					From tusers INNER JOIN p_Auction_UserMatrix ON p_Auction_UserMatrix.User_ID = tusers.UserID
						INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_UserMatrix.Organization_ID
					Where tusers.UserID = <cfqueryparam value="#Session.Mura.UserID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>
				<cfif Session.getSellerOrganizationInfo.RecordCount EQ 0>
					<cfset SendSellerAccountNeedOrganizationInfoEmail = #SendEmailCFC.SendSellerAccountOrganizationInfoEmail(rc, Session.Mura.UserID)#>
				</cfif>
				<cfif Session.getSellerOrganizationInfo.RecordCount NEQ 0 and Session.getSellerOrganizationinfo.ReceivedSellerContract EQ 0>
					<cfset SendContactEmail = #SendEmailCFC.SendSellerAccountContractEmail(rc, Session.Mura.UserID)#>
				</cfif>
			</cfif>

		</cfif>

		<cfquery name="Session.getActiveAuctions" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			SELECT p_Auction_Items.TContent_ID, p_Auction_Items.Item_Title, p_Auction_Items.Item_ModelNumber, p_Auction_Items.Item_Description, p_Auction_Items.Starting_Price,
				p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Item_PrimaryPhoto,
				p_Auction_Items.Item_SecondaryPhoto, p_Auction_Items.Item_TertiaryPhoto, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
				p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Active, p_Auction_Organizations.TContent_ID AS OrganizationRecID
			FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
				INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
			WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND p_Auction_Items.Active = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
			Order by p_Auction_Items.Auction_StartDate ASC
		</cfquery>
	</cffunction>

	<cffunction name="getAllActiveAuctions" access="remote" returnformat="json">
		<cfargument name="page" required="no" default="1" hint="Page user is on">
		<cfargument name="rows" required="no" default="10" hint="Number of Rows to display per page">
		<cfargument name="sidx" required="no" default="" hint="Sort Column">
		<cfargument name="sord" required="no" default="ASC" hint="Sort Order">

		<cfset var arrAuctions = ArrayNew(1)>
		<cfquery name="getAuctions" dbtype="Query">
			Select TContent_ID, Item_Title, Starting_Price, Auction_StartDate, Auction_EndDate, Active, Current_Bid
			From Session.getActiveAuctions

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
			<cfset arrAuctions[i] = [#TContent_ID#,#Item_Title#,#Starting_Price#,#Current_Bid#,#DateFormat(Auction_StartDate, 'mm/dd/yy')#,#DateFormat(Auction_EndDate, 'mm/dd/yy')#,#strActive#]>
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

	<cffunction name="viewauction" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfquery name="Session.getSelectedAuction" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					SELECT p_Auction_Items.TContent_ID, p_Auction_Items.Item_Title, p_Auction_Items.Item_ModelNumber, p_Auction_Items.Item_Description, p_Auction_Items.Starting_Price, p_Auction_Items.Current_Bid,
						p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Item_WebDirectory, p_Auction_Items.Item_PrimaryPhoto,
						p_Auction_Items.Item_SecondaryPhoto, p_Auction_Items.Item_TertiaryPhoto, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
						p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Active, p_Auction_Organizations.TContent_ID AS OrganizationRecID
					FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
						INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
					WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
						p_Auction_Items.TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.AuctionID#">
				</cfquery>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif Session.Mura.IsLoggedIn eq "false"><cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?display=login"></cfif>

			<cfif #FORM.UserBid# LTE #Session.getSelectedAuction.Current_Bid#>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Current Bid is higher than the bid you tried to place. Please enter an amount that is higher than the current bid."};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&BidToLow=True&AuctionID=#FORM.AuctionID#">
			<cfelse>
				<cfquery name="getAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Bid_Amount
					From p_Auction_Bids
					Where Auction_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
				</cfquery>

				<cfif getAuctionBids.RecordCount EQ 0>
					<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount)
						Values(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
							<cfqueryparam cfsqltype="cf_sql_money" value="#FORM.UserBid#">
						)
					</cfquery>
					<cfquery name="getCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select Current_Bid
						From p_Auction_Items
						Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
					</cfquery>
					<cfset newCurrentBid = #getCurrentBid.Current_Bid# + 1>
					<cfquery name="updateCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Items
						Set Current_Bid = <cfqueryparam cfsqltype="cf_sql_money" value="#Variables.newCurrentBid#">,
							HighestBid_UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
						Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
					</cfquery>
					<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&UserAction=BidSuccessful&AuctionID=#FORM.AuctionID#&Successful=True">

				</cfif>

			</cfif>

		</cfif>





	</cffunction>

</cfcomponent>