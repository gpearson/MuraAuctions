<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfquery name="Session.getOrganizationAllAuctions" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select TContent_ID, Item_Title, Location_ID, Item_ModelNumber, Item_Description, Item_Condition, Item_UPC, Item_PrimaryPhoto, Item_SecondaryPhoto, Item_TertiaryPhoto, Auction_StartDate, Auction_EndDate, Auction_Category, Auction_Type, Starting_Price, dateCreated, lastUpdated, lastUpdateBy, lastUpdateById, Active
			From p_Auction_Items
			Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
				Organization_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Session.getSellerOrganizationInfo.Organization_ID#">
			Order by Auction_StartDate ASC, Item_Title ASC
		</cfquery>

		<cfquery name="checkForSignedContract" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select ReceivedSellerContract, ReceivedSellerContractDate
			From p_Auction_UserMatrix
			Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
				User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.Mura.UserID#">
		</cfquery>

		<cfif checkForSignedContract.ReceivedSellerContract EQ 0>
			<cfset Session.Mura.NeedSignedContractOnFile = True>
		<cfelse>
			<cfset Session.Mura.NeedSignedContractOnFile = false>
		</cfif>

	</cffunction>
</cfcomponent>