<cfset AmountInDollars = #DollarFormat(GetPaymentInformation.OrganizationPaid_Amount)#>
<cfmail To="#GetOrgAdminInfo.Email# <#GetOrgAdminInfo.Email#>" from="#GetBidderInfo.Fname# #GetBidderInfo.Lname# <donotreply@#CGI.Server_Name#>" subject="Auction Surplus - Auction Item Cleared Funds" server="127.0.0.1">
<cfmailpart type="text/plain">
#GetOrgAdminInfo.Fname# #GetOrgAdminInfo.Lname#,

The individual listed below has cleared the funds processing procedures for the Auction Item listed below.

Processor_Company   : Stripe
Processor_CustomerID: #GetPaymentInformation.Processor_CustomerID#
Processor_ID        : #GetPaymentInformation.Processor_ID#
Processor_Amount    : #Variables.AmountInDollars#
Processor_Paid      : #GetPaymentInformation.Processor_Paid#
Processor_CardUsed  : #GetPaymentInformation.Processor_CardUsed#
Processor_Status    : #GetPaymentInformation.Processor_Status#

Name of Bidder      : #GetBidderInfo.Fname# #GetBidderInfo.Lname#  Email: #GetBidderInfo.Email#
Auction Item Name   : #getAuction.Item_Title#


Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">#GetOrgAdminInfo.Fname# #GetOrgAdminInfo.Lname#,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">The individual listed below has cleared the funds processing procedures for the Auction Item listed below.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Company   : Stripe</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_CustomerID: #GetPaymentInformation.Processor_CustomerID#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_ID        : #GetPaymentInformation.Processor_ID#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Amount    : #Variables.AmountInDollars#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Paid      : #GetPaymentInformation.Processor_Paid#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_CardUsed  : #GetPaymentInformation.Processor_CardUsed#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Processor_Status    : #GetPaymentInformation.Processor_Status#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Name of Bidder      : #GetBidderInfo.Fname# #GetBidderInfo.Lname#  Email: #GetBidderInfo.Email#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Auction Item Name   : #getAuction.Item_Title#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>