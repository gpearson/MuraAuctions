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
			<cfquery name="Session.getSellerOrganizationInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Select p_Auction_UserMatrix.AccountType, p_Auction_UserMatrix.Organization_ID, p_Auction_Organizations.BusinessName, p_Auction_Organizations.PhysicalAddress, p_Auction_Organizations.PhysicalCity, p_Auction_Organizations.PhysicalState, p_Auction_Organizations.PhysicalZipCode, p_Auction_Organizations.PhysicalZip4, p_Auction_Organizations.Federal_EIN, p_Auction_Organizations.PrimaryVoiceNumber, p_Auction_Organizations.BusinessWebsite, p_Auction_Organizations.GeoCode_Latitude, p_Auction_Organizations.GeoCode_Longitude
				From tusers INNER JOIN p_Auction_UserMatrix ON p_Auction_UserMatrix.User_ID = tusers.UserID
					INNER JOIN p_Auction_Organizations ON p_Auction_Organizations.TContent_ID = p_Auction_UserMatrix.Organization_ID
				Where tusers.UserID = <cfqueryparam value="#Session.Mura.UserID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	</cffunction>

</cfcomponent>