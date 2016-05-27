<cfmail To="#GetAdminEmailAddress.Email# <#GetAdminEmailAddress.Email#>" from="Auction Surplus Inquiry <donotreply@#CGI.Server_Name#>" subject="Auction Surplus Question - From Website Visitor" server="127.0.0.1">
<cfmailpart type="text/plain">
Auction Surplus Administrator,

The individual listed below submitted the following information through the Comment Form.


Individual's Name: #Arguments.ContactInfo.ContactFirstName# #Arguments.ContactInfo.ContactLastName#
Email Address: #Arguments.ContactInfo.ContactEmail#
Telephone Number: #Arguments.ContactInfo.ContactPhone#
Best Contact Method: <cfif #Arguments.ContactInfo.BestContactMethod# IS 0>By Email<cfelse>By Telephone</cfif>

Question:

#Arguments.ContactInfo.InquiryMessage#


Please contact this indivudal with the Best Contact Method Listed above.

Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.
</cfmailpart>
<cfmailpart type="text/html">
	<html><body>
		<table border="0" align="center" width="100%" cellspacing="0" cellpadding="0">
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Event Registration Administrator,</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">The individual listed below submitted the following information through the Comment Form.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Individual's Name: #Arguments.ContactInfo.ContactFirstName# #Arguments.ContactInfo.ContactLastName#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Email Address: #Arguments.ContactInfo.ContactEmail#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Telephone Number: #Arguments.ContactInfo.ContactPhone#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Best Contact Method: <cfif #Arguments.ContactInfo.BestContactMethod# IS 0>By Email<cfelse>By Telephone</cfif></td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Question: #Arguments.ContactInfo.InquiryMessage#</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Please contact this indivudal with the Best Contact Method Listed above.</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">&nbsp;</td></tr>
			<tr><td Style="Font-Family: Arial; Font-Size: 12px; Font-Weight: Normal; Color: Black;">Note: This email address is not valid and is not read by a human individual. This email address is strictly for system notifications that are sent from this system.</td></tr>
		</table>
	</body></html>
</cfmailpart>
</cfmail>