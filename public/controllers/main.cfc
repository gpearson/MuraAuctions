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
					Select p_Auction_UserMatrix.AccountType, p_Auction_UserMatrix.Organization_ID, p_Auction_Organizations.BusinessName, p_Auction_Organizations.PhysicalAddress, p_Auction_Organizations.PhysicalCity, p_Auction_Organizations.PhysicalState, p_Auction_Organizations.PhysicalZipCode, p_Auction_Organizations.PhysicalZip4, p_Auction_Organizations.Federal_EIN, p_Auction_Organizations.PrimaryVoiceNumber, p_Auction_Organizations.BusinessWebsite, p_Auction_Organizations.GeoCode_Latitude, p_Auction_Organizations.GeoCode_Longitude, p_Auction_UserMatrix.ReceivedSellerContract,
						p_Auction_Organizations.MailingAddress, p_Auction_Organizations.MailingCity, p_Auction_Organizations.MailingState, p_Auction_Organizations.MailingZipCode, p_Auction_Organizations.BusinessFax, p_Auction_Organizations.BusinessWebsite
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
				p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
				p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Auction_Category, p_Auction_Organizations.TContent_ID AS OrganizationRecID,
				p_Auction_Items.Current_Bid
			FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
				INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
			WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND p_Auction_Items.Active = <cfqueryparam cfsqltype="cf_sql_bit" value="1"> and p_Auction_Items.Auction_Won = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			Order by p_Auction_Items.Auction_StartDate ASC
		</cfquery>
	</cffunction>

	<cffunction name="getAllActiveAuctions" access="remote" returnformat="json">
		<cfargument name="page" required="no" default="1" hint="Page user is on">
		<cfargument name="rows" required="no" default="10" hint="Number of Rows to display per page">
		<cfargument name="sidx" required="no" default="" hint="Sort Column">
		<cfargument name="sord" required="no" default="ASC" hint="Sort Order">
		<cfargument name="CategoryID" required="no" hint="Display Category To Display">

		<cfset var arrAuctions = ArrayNew(1)>
		<cfquery name="getAuctions" dbtype="Query">
			Select TContent_ID, Item_Title, Starting_Price, Auction_StartDate, Auction_EndDate, Active, Current_Bid, Auction_Category
			From Session.getActiveAuctions
			<cfif Arguments.CategoryID NEQ "">
				Where Auction_Category = #Arguments.CategoryID#
			</cfif>
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
						p_Auction_Items.Item_YearsInService, p_Auction_Items.Location_ID, p_Auction_Items.Item_AtParentLocation, p_Auction_Items.Item_InfoWebsite, p_Auction_Items.AssetTag_Number,
						p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
						p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Active, p_Auction_Organizations.TContent_ID AS OrganizationRecID
					FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
						INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
					WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
						p_Auction_Items.TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.AuctionID#">
				</cfquery>
				<cfquery name="Session.getSelectedAuctionCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select p_Auction_Bids.Bid_Amount, tusers.Fname, tusers.Lname, tusers.UserName
					From p_Auction_Bids INNER JOIN tusers on tusers.UserID = p_Auction_Bids.User_ID
					Where p_Auction_Bids.Auction_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.AuctionID#">
					Order by p_Auction_Bids.Bid_Amount DESC
				</cfquery>

				<cfquery name="Session.getSelectedAuctionPhotos" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Filename, FileContent
					From p_Auction_ItemPhotos
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
						Auction_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.AuctionID#">
				</cfquery>

				<cfif Session.getSelectedAuction.Item_AtParentLocation EQ 0>
					<cfquery name="Session.getLocationInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select BusinessName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, GeoCode_Latitude, GeoCode_Longitude
						From p_Auction_Organizations
						Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.getSelectedAuction.OrganizationRecID#">
					</cfquery>
				<cfelse>

				</cfif>

			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif Session.Mura.IsLoggedIn eq "false">
				<cfset Session.UserToPlaceBid = StructNew()>
				<cfset Session.UserToPlaceBid.AuctionID = #URL.AuctionID#>
				<cfset Session.UserToPlaceBid.BidAmount = #FORM.UserBid#>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?display=login">
			</cfif>


			<cfquery name="getSelectedAuction" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				SELECT p_Auction_Items.TContent_ID, p_Auction_Items.Item_Title, p_Auction_Items.Item_ModelNumber, p_Auction_Items.Item_Description, p_Auction_Items.Starting_Price, p_Auction_Items.Current_Bid,
					p_Auction_Items.Item_YearsInService, p_Auction_Items.Location_ID, p_Auction_Items.Item_AtParentLocation, p_Auction_Items.Item_InfoWebsite, p_Auction_Items.AssetTag_Number,
					p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
					p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Active, p_Auction_Organizations.TContent_ID AS OrganizationRecID
				FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
					INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
				WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
					p_Auction_Items.TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
			</cfquery>

			<cfif #FORM.UserBid# LT #getSelectedAuction.Current_Bid#>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Current Bid is higher than the bid you tried to place. Please enter an amount that is higher than the current bid."};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&BidToLow=True&AuctionID=#FORM.AuctionID#">
			<cfelse>
				<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>
				<cfswitch expression="#getSelectedAuction.Auction_Type#">
					<cfcase value="Fixed">
						<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount, dateCreated)
							Values(
								<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
								<cfqueryparam cfsqltype="cf_sql_money" value="#FORM.UserBid#">,
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
							)
						</cfquery>
						<cfquery name="updateAuctionInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Update p_Auction_Items
							Set Auction_Won = <cfqueryparam cfsqltype="cf_sql_bit" value="1">,
								Auction_WonDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
								Auction_WonUserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,

							Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
						</cfquery>
						<cfset SendContactEmail = #SendEmailCFC.SendAuctionWonNotification(rc, Session.Mura.UserID, FORM.AuctionID)#>
						<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default&UserAction=AuctionWon&Successful=True">
					</cfcase>
					<cfcase value="Auction">
						<cfif #FORM.UserBid# EQ #getSelectedAuction.Current_Bid#>
							<cflock timeout="60" scope="SESSION" type="Exclusive">
								<cfscript>
									errormsg = {property="HumanChecker",message="The Current Bid is equal to the bid you tried to place. Please enter an amount that is higher than the current bid."};
									arrayAppend(Session.FormErrors, errormsg);
								</cfscript>
							</cflock>
							<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&BidToLow=True&AuctionID=#FORM.AuctionID#">
						</cfif>
						<cfquery name="getAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Select Bid_Amount, User_ID
							From p_Auction_Bids
							Where Auction_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
							Order by Bid_Amount DESC
							Limit 1
						</cfquery>
						<cfif getAuctionBids.RecordCount EQ 0>
							<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount, dateCreated)
								Values(
									<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
									<cfqueryparam cfsqltype="cf_sql_money" value="#FORM.UserBid#">,
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
								)
							</cfquery>
							<cfset newCurrentBid = #FORM.UserBid# + 1>
							<cfquery name="updateCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								Update p_Auction_Items
								Set Current_Bid = <cfqueryparam cfsqltype="cf_sql_money" value="#Variables.newCurrentBid#">,
									HighestBid_UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
								Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
							</cfquery>
							<cfset SendContactEmail = #SendEmailCFC.SendHighestBidderNotice(rc, Session.Mura.UserID, FORM.AuctionID)#>
							<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default&UserAction=BidSuccessful&AuctionID=#FORM.AuctionID#&Successful=True">
						<cfelse>
							<cfif getAuctionBids.User_ID[1] EQ Session.Mura.UserID>
								<cflock timeout="60" scope="SESSION" type="Exclusive">
									<cfscript>
										errormsg = {property="HumanChecker",message="You are the current higest bidder for this auction item"};
										arrayAppend(Session.FormErrors, errormsg);
									</cfscript>
								</cflock>
								<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&AlreadyHighestBidder=True&AuctionID=#FORM.AuctionID#">
							<cfelse>
								<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
									insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount, dateCreated)
									Values(
										<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
										<cfqueryparam cfsqltype="cf_sql_money" value="#FORM.UserBid#">,
										<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
									)
								</cfquery>
								<cfset newCurrentBid = #FORM.UserBid# + 1>
								<cfquery name="updateCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
									Update p_Auction_Items
									Set Current_Bid = <cfqueryparam cfsqltype="cf_sql_money" value="#Variables.newCurrentBid#">,
										HighestBid_UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
									Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
								</cfquery>
								<cfset SendOutBidEmail = #SendEmailCFC.SendOutBidNotice(rc, getAuctionBids.User_ID[1], FORM.AuctionID)#>
								<cfset SendHighBidEmail = #SendEmailCFC.SendHighestBidderNotice(rc, Session.Mura.UserID, FORM.AuctionID)#>
								<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&UserAction=BidSuccessful&AuctionID=#FORM.AuctionID#&Successful=True">
							</cfif>
						</cfif>
					</cfcase>
				</cfswitch>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="placebid" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif Session.Mura.IsLoggedIn eq "false"><cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default"></cfif>

		<cfquery name="getSelectedAuction" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			SELECT p_Auction_Items.TContent_ID, p_Auction_Items.Item_Title, p_Auction_Items.Item_ModelNumber, p_Auction_Items.Item_Description, p_Auction_Items.Starting_Price, p_Auction_Items.Current_Bid,
				p_Auction_Items.Item_YearsInService, p_Auction_Items.Location_ID, p_Auction_Items.Item_AtParentLocation, p_Auction_Items.Item_InfoWebsite, p_Auction_Items.AssetTag_Number,
				p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Item_WebDirectory, p_Auction_Items.Item_PrimaryPhoto,
				p_Auction_Items.Item_SecondaryPhoto, p_Auction_Items.Item_TertiaryPhoto, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
				p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Active, p_Auction_Organizations.TContent_ID AS OrganizationRecID
			FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
				INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
			WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
				p_Auction_Items.TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.UserToPlaceBid.AuctionID#">
		</cfquery>

		<cfif #Session.UserToPlaceBid.BidAmount# LT #getSelectedAuction.Current_Bid#>
			<cflock timeout="60" scope="SESSION" type="Exclusive">
				<cfscript>
					errormsg = {property="HumanChecker",message="The Current Bid is higher than the bid you tried to place. Please enter an amount that is higher than the current bid."};
					arrayAppend(Session.FormErrors, errormsg);
				</cfscript>
			</cflock>
			<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&BidToLow=True&AuctionID=#Session.UserToPlaceBid.AuctionID#">
		<cfelse>
			<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>
			<cfswitch expression="#getSelectedAuction.Auction_Type#">
				<cfcase value="Fixed">
					<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount, dateCreated)
						Values(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
							<cfqueryparam cfsqltype="cf_sql_money" value="#FORM.UserBid#">,
							<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
						)
					</cfquery>
					<cfquery name="updateAuctionInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Update p_Auction_Items
						Set Auction_Won = <cfqueryparam cfsqltype="cf_sql_bit" value="1">,
							Auction_WonDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
							Auction_WonUserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
						Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.AuctionID#">
					</cfquery>
					<cfset SendContactEmail = #SendEmailCFC.SendAuctionWonNotification(rc, Session.Mura.UserID, FORM.AuctionID)#>
				</cfcase>
				<cfcase value="Auction">
					<cfif #FORM.UserBid# EQ #getSelectedAuction.Current_Bid#>
							<cflock timeout="60" scope="SESSION" type="Exclusive">
								<cfscript>
									errormsg = {property="HumanChecker",message="The Current Bid is equal to the bid you tried to place. Please enter an amount that is higher than the current bid."};
									arrayAppend(Session.FormErrors, errormsg);
								</cfscript>
							</cflock>
							<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&BidToLow=True&AuctionID=#FORM.AuctionID#">
						</cfif>
					<cfquery name="getAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select Bid_Amount, User_ID
						From p_Auction_Bids
						Where Auction_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.UserToPlaceBid.AuctionID#">
						Order by Bid_Amount DESC
						Limit 1
					</cfquery>
					<cfif getAuctionBids.RecordCount EQ 0>
						<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount, dateCreated)
							Values(
								<cfqueryparam cfsqltype="cf_sql_integer" value="#Session.UserToPlaceBid.AuctionID#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
								<cfqueryparam cfsqltype="cf_sql_money" value="#Session.UserToPlaceBid.BidAmount#">,
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
							)
						</cfquery>
						<cfset newCurrentBid = #Session.UserToPlaceBid.BidAmount# + 1>
						<cfquery name="updateCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Update p_Auction_Items
							Set Current_Bid = <cfqueryparam cfsqltype="cf_sql_money" value="#Variables.newCurrentBid#">,
								HighestBid_UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
							Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.UserToPlaceBid.AuctionID#">
						</cfquery>
						<cfset SendContactEmail = #SendEmailCFC.SendHighestBidderNotice(rc, Session.Mura.UserID, Session.UserToPlaceBid.AuctionID)#>
						<cfset temp = StructDelete(Session, "UserToPlaceBid")>
						<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default&UserAction=BidSuccessful&AuctionID=#URL.AuctionID#&Successful=True">
					<cfelse>
						<cfif getAuctionBids.User_ID[1] EQ Session.Mura.UserID>
							<cflock timeout="60" scope="SESSION" type="Exclusive">
								<cfscript>
									errormsg = {property="HumanChecker",message="You are the current higest bidder for this auction item"};
									arrayAppend(Session.FormErrors, errormsg);
								</cfscript>
							</cflock>
							<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&AlreadyHighestBidder=True&AuctionID=#Session.UserToPlaceBid.AuctionID#">
						<cfelse>
							<cfquery name="insertAuctionBids" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								insert into p_Auction_Bids(Auction_ID, User_ID, Bid_Amount, dateCreated)
								Values(
									<cfqueryparam cfsqltype="cf_sql_integer" value="#Session.UserToPlaceBid.AuctionID#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
									<cfqueryparam cfsqltype="cf_sql_money" value="#Session.UserToPlaceBid.BidAmount#">,
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
								)
							</cfquery>
							<cfset newCurrentBid = #Session.UserToPlaceBid.BidAmount# + 1>
							<cfquery name="updateCurrentBid" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								Update p_Auction_Items
								Set Current_Bid = <cfqueryparam cfsqltype="cf_sql_money" value="#Variables.newCurrentBid#">,
									HighestBid_UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
								Where TContent_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.UserToPlaceBid.AuctionID#">
							</cfquery>
							<cfset SendOutBidEmail = #SendEmailCFC.SendOutBidNotice(rc, getAuctionBids.User_ID[1], Session.UserToPlaceBid.AuctionID)#>
							<cfset SendHighBidEmail = #SendEmailCFC.SendHighestBidderNotice(rc, Session.Mura.UserID, Session.UserToPlaceBid.AuctionID)#>
							<cfset temp = StructDelete(Session, "UserToPlaceBid")>
							<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&UserAction=BidSuccessful&AuctionID=#URL.AuctionID#&Successful=True">
						</cfif>
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>

	</cffunction>

	<cffunction name="processpayment" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cfif not isDefined("URL.Key")>

			<cfelseif isDefined("URL.Key")>
				<cfset DecodedKey = #ToString(ToBinary(URL.Key))#>

				<cfif ListFirst(ListFirst(Variables.DecodedKey, "&"), "=") NEQ "AuctionID">
					<cfdump var="#Variables.DecodedKey#">
					<cfabort>
				<cfelseif ListFirst(ListLast(Variables.DecodedKey, "&"), "=") NEQ "UserID">
					<cfdump var="#Variables.DecodedKey#">
					<cfabort>
				</cfif>

				<cfset AuctionID = #ListLast(ListFirst(Variables.DecodedKey, "&"), "=")#>
				<cfset UserID = #ListLast(ListLast(Variables.DecodedKey, "&"), "=")#>
				<cfset Session.AuctionWon = StructNew()>

				<cfif Session.Mura.IsLoggedIn EQ "false">
					<cfset Session.AuctionWon.URLKey = #URL.Key#>
					<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?display=login">
				<cfelseif Session.Mura.IsLoggedIn EQ "true">
					<cfif Session.Mura.UserID NEQ Variables.UserID>
						<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?doaction=logout">
					</cfif>
				</cfif>

				<cfquery name="Session.SiteSettings" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select TContent_ID, DateCreated, lastUpdateBy, lastUpdated, SellerPercentageFee, ProcessPayments_Stripe, Stripe_TestMode, Stripe_TestAPIKey, Stripe_LiveAPIKey
					From p_Auction_SiteConfig
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#">
				</cfquery>

				<cfquery name="Session.AuctionWon.getAuction" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					SELECT p_Auction_Items.TContent_ID, p_Auction_Items.Item_Title, p_Auction_Items.Item_ModelNumber, p_Auction_Items.Item_Description, p_Auction_Items.Starting_Price, p_Auction_Items.Current_Bid,
						p_Auction_Items.Item_YearsInService, p_Auction_Items.Location_ID, p_Auction_Items.Item_AtParentLocation, p_Auction_Items.Item_InfoWebsite, p_Auction_Items.AssetTag_Number,
						p_Auction_Items.Item_Condition, p_Auction_Items.Item_UPC, p_Auction_Organizations.BusinessName, p_Auction_Items.Auction_StartDate, p_Auction_Items.Auction_EndDate,
						p_Auction_ProductCategories.Category_Name, p_Auction_Items.Auction_Type, p_Auction_Items.Active, p_Auction_Items.Location_ID, p_Auction_Organizations.TContent_ID AS OrganizationRecID
					FROM p_Auction_Items INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_Items.Organization_ID
						INNER JOIN p_Auction_ProductCategories ON p_Auction_ProductCategories.Category_ID = p_Auction_Items.Auction_Category
					WHERE p_Auction_Items.Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
						p_Auction_Items.TContent_ID = <cfqueryparam value="#Variables.AuctionID#" cfsqltype="cf_sql_integer"> and
						p_Auction_Items.Auction_WonUserID = <cfqueryparam value="#Variables.UserID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="Session.AuctionWon.getSelectedAuctionPhotos" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Filename, FileContent
					From p_Auction_ItemPhotos
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> AND
						Auction_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Variables.AuctionID#">
				</cfquery>

				<cfquery name="Session.AuctionWon.getOrganization" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select BusinessName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber, BusinessWebsite
					From p_Auction_Organizations
					Where TContent_ID = <cfqueryparam value="#Session.AuctionWon.getAuction.OrganizationRecID#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif Session.AuctionWon.getAuction.Location_ID NEQ 0>
					<cfquery name="Session.AuctionWon.getLocationOfAuctionItem" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Select LocationName, PhysicalAddress, PhysicalCity, PhysicalState, PhysicalZipCode, PhysicalZip4, PrimaryVoiceNumber
						From p_Auction_Organizations
						Where TContent_ID = <cfqueryparam value="#Session.AuctionWon.getAuction.Location_ID#" cfsqltype="cf_sql_integer">
					</cfquery>
				</cfif>
			</cfif>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset card = StructNew()>
			<cfset card.number = #FORM.Number#>
			<cfset card.cvc = #FORM.CVC#>
			<cfset card.EXP_Year = #FORM.expyear#>
			<cfset card.EXP_Month = #FORM.expmonth#>
			<cfswitch expression="#Session.AuctionWon.getAuction.Auction_Type#">
				<cfcase value="Fixed">
					<cfset Session.StripeToken = Session.Stripe.createToken(card, Session.AuctionWon.getAuction.Current_Bid)>
				</cfcase>
				<cfcase value="Auction">

				</cfcase>
			</cfswitch>
			<cfset GetAllCustomers = #Session.Stripe.readCustomer()#>
			<cfset CustomerID = "">
			<cfloop from="1" to="#ArrayLen(GetAllCustomers.data)#" index="cust">
				<cfif GetAllCustomers.data[cust]["email"] EQ #Session.Mura.Email#>
					<cfset CustomerID = GetAllCustomers.data[cust].id>
					<cfbreak>
				</cfif>
			</cfloop>
			<cfif LEN(CustomerID) EQ 0>
				<cfset Session.StripeCustomer = Session.Stripe.createCustomer(card = Session.StripeToken.id, email="#Session.Mura.Email#", description="#Session.Mura.FName# #Session.Mura.LName#")>
				<cfswitch expression="#Session.AuctionWon.getAuction.Auction_Type#">
					<cfcase value="Fixed">
						<cfset Session.StripeCharge = Session.Stripe.createcharge(amount=Session.AuctionWon.getAuction.Current_Bid, customer=Session.StripeCustomer.id, card=Session.StripeToken.card.id, description="Auction ID: #Session.AuctionWon.getAuction.TContent_ID# ; #Session.AuctionWon.getAuction.Item_Title#")>
					</cfcase>
					<cfcase value="Auction">

					</cfcase>
				</cfswitch>
			<cfelse>
				<cfset Session.StripeCustomer = Session.Stripe.updateCustomer(customerid = Variables.CustomerID, card = Session.StripeToken.id)>
				<cfswitch expression="#Session.AuctionWon.getAuction.Auction_Type#">
					<cfcase value="Fixed">
						<cfset Session.StripeCharge = Session.Stripe.createcharge(amount=Session.AuctionWon.getAuction.Current_Bid, customer=CustomerID, card=Session.StripeToken.card.id, description="Auction ID: #Session.AuctionWon.getAuction.TContent_ID# ; #Session.AuctionWon.getAuction.Item_Title#")>
					</cfcase>
					<cfcase value="Auction">

					</cfcase>
				</cfswitch>
			</cfif>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif not isDefined("Session.StripeCharge.failure_code")>
				<cfswitch expression="#Session.AuctionWon.getAuction.Auction_Type#">
					<cfcase value="Fixed">
						<cfquery name="insertPaymentRecord" result="InsertNewRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Insert into p_Auction_PaymentRecords(Organization_ID, Payment_Amount, User_ID, Auction_ID, Processor_Company, Processor_CustomerID, Processor_ID, Processor_Amount, Processor_Paid, Processor_CardUsed, Processor_Status, dateCreated, lastUpdated, lastUpdateBy, lastUpdateByID, Site_ID, OrganizationPaid)
							Values(
								<cfqueryparam cfsqltype="cf_sql_integer" value="#Session.AuctionWon.getAuction.OrganizationRecID#">,
								<cfqueryparam cfsqltype="cf_sql_money" value="#Session.AuctionWon.getAuction.Current_Bid#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="#Session.AuctionWon.getAuction.TContent_ID#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="Stripe">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.StripeCharge.customer#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.StripeCharge.id#">,
								<cfqueryparam cfsqltype="cf_sql_float" value="#Session.AuctionWon.getAuction.Current_Bid#">,
								<cfqueryparam cfsqltype="cf_sql_bit" value="#Session.StripeCharge.paid#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.StripeCharge.source.brand#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.StripeCharge.status#">,
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
								<cfqueryparam value="#Session.Mura.Fname# #Session.Mura.LName#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">,
								<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam cfsqltype="cf_sql_bit" value="0">
							)
						</cfquery>
					</cfcase>
				</cfswitch>
				<cfset newRecordID = InsertNewRecord.generatedkey>
				<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>
				<cfset temp = #SendEmailCFC.SendPaymentEmailToAdministrators(rc, Variables.newRecordID)#>
			</cfif>
			<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.default&ProcessPayment=True">
		</cfif>
	</cffunction>

</cfcomponent>