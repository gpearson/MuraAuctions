<cfmail To="#getUserAccount.FName# #getUserAccount.LName# <#getUserAccount.Email#>" from="Auction Surplus <donotreply@#CGI.Server_Name#>" subject="Auction Surplus - User Account Activation Email" server="127.0.0.1">
<cfmailpart type="text/plain">
#getUserAccount.FName# #getUserAccount.LName#,

You have successfully verified your email address on the Auction Surplus Website. Since this account was created to Sell items, the activation process is multiple steps. You will need to click on the link below to validate your email address. Within the next few minutes you will be receiving a PDF Document that is our Service Contract which you will need to print, sign and send back to us. Once we receive this contact, we will update your account. When your account has been updated, you will receive an email message letting you know this which then you will be able to login and post items for sell.

#Variables.AccountActiveLink#

Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#getUserAccount.FName# #getUserAccount.LName#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">You have successfully verified your email address on the Auction Surplus Website. Since this account was created to Sell items, the activation process is multiple steps. You will need to click on the link below to validate your email address. Within the next few minutes you will be receiving a PDF Document that is our Service Contract which you will need to print, sign and send back to us. Once we receive this contact, we will update your account. When your account has been updated, you will receive an email message letting you know this which then you will be able to login and post items for sell.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#Variables.AccountActiveLink#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>