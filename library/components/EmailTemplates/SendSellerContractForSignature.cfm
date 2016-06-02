<cfmail To="#getUserAccount.FName# #getUserAccount.LName# <#getUserAccount.Email#>" from="Auction Surplus <donotreply@#CGI.Server_Name#>" subject="Auction Surplus - Seller Contract Email" server="127.0.0.1">
<cfmailparam file="#Variables.CompletedContractPDFFile#" type="application/pdf">
<cfmailpart type="text/plain">
#getUserAccount.FName# #getUserAccount.LName#,

Attached to this email message is our contract for the Internet Auction Surplus Website that you have created an account on. We ask that you print, sign and return this contract to us before you will be available to post surplus items to sell.


Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#getUserAccount.FName# #getUserAccount.LName#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Attached to this email message is our contract for the Internet Auction Surplus Website that you have created an account on. We ask that you print, sign and return this contract to us before you will be available to post surplus items to sell.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>