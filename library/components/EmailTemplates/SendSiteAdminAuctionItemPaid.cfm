<cfset AmountInDollars = #DollarFormat(GetPaymentInformation.Payment_Amount)#>
<cfmail To="#GetAdminEmailAddress.Email# <#GetAdminEmailAddress.Email#>" from="#GetUserInfo.Fname# #GetUserInfo.Lname# <donotreply@#CGI.Server_Name#>" subject="Group Messaging - User Posted Funds to Account" server="127.0.0.1">
<cfmailpart type="text/plain">
Group Mesasge Service Administrator,

The individual listed below posted funds to their account and information regarding transaction is listed below.

Processor_Company   : Stripe
Processor_CustomerID: #GetPaymentInformation.Processor_CustomerID#
Processor_ID        : #GetPaymentInformation.Processor_ID#
Processor_Amount    : #Variables.AmountInDollars#
Processor_Paid      : #GetPaymentInformation.Processor_Paid#
Processor_CardUsed  : #GetPaymentInformation.Processor_CardUsed#
Processor_Status    : #GetPaymentInformation.Processor_Status#

Organization Name: #GetOrganizationInfo.BusinessName#
Individual Applied Funds: #GetUserInfo.Fname# #GetUserInfo.Lname#


Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Group Mesasge Service Administrator,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">The individual listed below posted funds to their account and information regarding transaction is listed below.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Company   : Stripe</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_CustomerID: #GetPaymentInformation.Processor_CustomerID#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_ID        : #GetPaymentInformation.Processor_ID#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Amount    : #Variables.AmountInDollars#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Paid      : #GetPaymentInformation.Processor_Paid#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_CardUsed  : #GetPaymentInformation.Processor_CardUsed#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Status    : #GetPaymentInformation.Processor_Status#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Organization Name: #GetOrganizationInfo.BusinessName#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Individual Applied Funds: #GetUserInfo.Fname# #GetUserInfo.Lname#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>