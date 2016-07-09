<cfmail To="#getOutbidUser.FName# #getOutbidUser.LName# <#getOutbidUser.Email#>" from="Auction Surplus <donotreply@#CGI.Server_Name#>" subject="Auction Surplus - Outbid Notification" server="127.0.0.1">
<cfmailpart type="text/plain">
#getOutbidUser.FName# #getOutbidUser.LName#,

This is just a confirmation email notifying that you have just been outbid for the auction item of #getAuction.Item_Title#. If you really would like this item, you can place a higher bid by visiting http://#CGI.Server_Name#/#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&AuctionID=#Arguments.AuctionID#

Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#getOutbidUser.FName# #getOutbidUser.LName#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">This is just a confirmation email notifying that you have just been outbid for the auction item of #getAuction.Item_Title#. If you really would like this item, you can place a higher bid by visiting http://#CGI.Server_Name#/#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.viewauction&AuctionID=#Arguments.AuctionID#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>