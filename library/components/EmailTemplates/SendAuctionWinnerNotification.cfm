<cfmail To="#getWinnerInfo.FName# #getWinnerInfo.LName# <#getWinnerInfo.Email#>" from="Auction Surplus <donotreply@#CGI.Server_Name#>" subject="Auction Surplus - Auction Winner Information" server="127.0.0.1">
<cfmailpart type="text/plain">
#getWinnerInfo.FName# #getWinnerInfo.LName#,

This is just a confirmation email notifying you are the winning auction bidder of the item #getAuction.Item_Title#. Simply click on the link below to start the processing of your payment for this auction item. Once the payment processing has been successfully completed, you will receive an email notification with a document attached that you will take to the pickup location. You will also need to bring a government issued picture identification card.

http://#cgi.server_name##CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.processpayment&Key=#Variables.URLKey#

Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#getWinnerInfo.FName# #getWinnerInfo.LName#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">This is just a confirmation email notifying you are the winning auction bidder of the item #getAuction.Item_Title#. Simply click on the link below to start the processing of your payment for this auction item. Once the payment processing has been successfully completed, you will receive an email notification with a document attached that you will take to the pickup location. You will also need to bring a government issued picture identification card.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;"><a href="http://#cgi.server_name##CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.processpayment&Key=#Variables.URLKey#">http://#cgi.server_name##CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.processpayment&Key=#Variables.URLKey#</a></td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>