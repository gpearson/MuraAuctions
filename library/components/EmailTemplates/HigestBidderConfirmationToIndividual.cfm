<cfmail To="#getAuction.FName# #getAuction.LName# <#getAuction.Email#>" from="Auction Surplus <donotreply@#CGI.Server_Name#>" subject="Auction Surplus - Higest Bidder Confirmation" server="127.0.0.1">
<cfmailpart type="text/plain">
#getAuction.FName# #getAuction.LName#,

This is just a confirmation email notifying you of being the Higest Bidder for the auction item of #getAuction.Item_Title#.

Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#getAuction.FName# #getAuction.LName#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">This is just a confirmation email notifying you of being the Higest Bidder for the auction item of #getAuction.Item_Title#.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>