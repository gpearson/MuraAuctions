
<cfset TypeAccountQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(TypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(TypeAccountQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(TypeAccountQuery, "OptionName", "Seller's Account")#>
<cfset temp = QueryAddRow(TypeAccountQuery, 1)>
<cfset temp = #QuerySetCell(TypeAccountQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(TypeAccountQuery, "OptionName", "Buyer's Account")#>

<cfset UserInActiveQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(UserInActiveQuery, 1)>
<cfset temp = #QuerySetCell(UserInActiveQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(UserInActiveQuery, "OptionName", "No")#>
<cfset temp = QueryAddRow(UserInActiveQuery, 1)>
<cfset temp = #QuerySetCell(UserInActiveQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(UserInActiveQuery, "OptionName", "Yes")#>

<cfoutput>
	<div class="panel panel-default">
		<cfif not isDefined("URL.PerformAction")>
			<div class="panel-heading"><h1>Edit User Account</h1></div>
			<cfform action="" method="post" id="CreateNewUser" class="form-horizontal">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<cfinput type="hidden" name="UserID" value="#URL.UserID#">
				<cfif not isDefined("URL.FormRetry")>
					<div class="panel-body">
						<div class="form-group">
							<label for="UserFirstName" class="control-label col-sm-3">First Name:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserFirstName" name="UserFirstName" value="#Session.getSelectedUser.Fname#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="UserLastName" class="control-label col-sm-3">Last Name:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserLastName" name="UserLastName" value="#Session.getSelectedUser.Lname#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="UserEmail" class="control-label col-sm-3">Email Address:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserEmail" name="UserEmail" value="#Session.getSelectedUser.Email#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="DesiredPassword" class="control-label col-sm-3">Desired Password:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="password" class="form-control" id="DesiredPassword" name="DesiredPassword" required="no"></div>
						</div>
						<div class="form-group">
							<label for="VerifyDesiredPassword" class="control-label col-sm-3">Verify Password:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="password" class="form-control" id="VerifyDesiredPassword" name="VerifyDesiredPassword" required="no"></div>
						</div>
						<div class="form-group">
							<label for="UserSecurityRole" class="control-label col-sm-3">User Role:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="UserSecurityRole" class="form-control" Required="Yes" Multiple="No" query="Session.getSecurityRoles" selected="#Session.getSelectedUserSecurityRole.GroupID#" value="UserID" Display="GroupName"  queryposition="below">
									<option value="0">No Additional Security Role</option>
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="UserActive" class="control-label col-sm-3">InActive:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="UserActive" class="form-control" Required="Yes" Multiple="No" query="UserInActiveQuery" selected="#Session.getSelectedUser.InActive#" value="ID" Display="OptionName"  queryposition="below">
									<option value="0">Is User InActive in System</option>
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="ZipCode" class="control-label col-sm-3">ZipCode:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="ZipCode" name="ZipCode" value="#Session.getSelectedUser.ZipCode#" required="no"></div>
						</div>
						<div class="form-group">
							<label for="ContactNumber" class="control-label col-sm-3">Contact Number:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactNumber" name="ContactNumber" value="#Session.getSelectedUser.TelephoneNumber#" required="no"></div>
						</div>
						<br /><br />
						<div class="panel-heading"><h2>Type of Account</h2></div>
						<div class="well">Seller accounts are for Public/Private School Districts, College/Universities, Non-Profit Organizations, and Government Organizations. Seller Accounts must sign a service contract that will be sent to the email address used on this form before the account is activated in the system.</div>
						<div class="form-group">
							<label for="AccountType" class="control-label col-sm-3">Account Type:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="TypeOfAccountRequested" class="form-control" Required="Yes" Multiple="No" query="TypeAccountQuery" selected="#Session.getSelectedUser.AccountType#" value="ID" Display="OptionName"  queryposition="below">
									<option value="----">Select Account Type</option>
								</cfselect>
							</div>
						</div>
					</div>
					<div class="panel-footer">
						<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Update User Account"><br /><br />
					</div>
				<cfelseif isDefined("URL.FormRetry")>
					<div class="panel-body">
						<cfif ArrayLen(Session.FormErrors) GTE 1>
							<div class="alert alert-danger"><p>#Session.FormErrors[1].Message#</p></div>
						</cfif>
						<div class="form-group">
							<label for="UserFirstName" class="control-label col-sm-3">First Name:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserFirstName" name="UserFirstName" value="#Session.FormData.UserFirstName#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="UserLastName" class="control-label col-sm-3">Last Name:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserLastName" name="UserLastName" value="#Session.FormData.UserLastName#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="UserEmail" class="control-label col-sm-3">Email Address:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserEmail" name="UserEmail" value="#Session.FormData.UserEmail#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="DesiredPassword" class="control-label col-sm-3">Desired Password:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="password" class="form-control" id="DesiredPassword" name="DesiredPassword" value="#Session.FormData.DesiredPassword#" required="no"></div>
						</div>
						<div class="form-group">
							<label for="VerifyDesiredPassword" class="control-label col-sm-3">Verify Password:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="password" class="form-control" id="VerifyDesiredPassword" name="VerifyDesiredPassword" value="#Session.FormData.VerifyDesiredPassword#" required="no"></div>
						</div>
						<div class="form-group">
							<label for="UserSecurityRole" class="control-label col-sm-3">User Role:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="UserSecurityRole" class="form-control" Required="Yes" Multiple="No" query="Session.getSecurityRoles" selected="#Session.FormData.UserSecurityRole#" value="UserID" Display="GroupName"  queryposition="below">
									<option value="0">No Additional Security Role</option>
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="UserActive" class="control-label col-sm-3">InActive:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="UserActive" class="form-control" Required="Yes" Multiple="No" query="UserInActiveQuery" selected="#Session.FormData.UserActive#" value="ID" Display="OptionName"  queryposition="below">
									<option value="0">Is User InActive in System</option>
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="ZipCode" class="control-label col-sm-3">ZipCode:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="ZipCode" name="ZipCode" value="#Session.FormData.ZipCode#" required="no"></div>
						</div>
						<div class="form-group">
							<label for="ContactNumber" class="control-label col-sm-3">Contact Number:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactNumber" name="ContactNumber" value="#Session.FormData.ContactNumber#" required="no"></div>
						</div>
						<br /><br />
						<div class="panel-heading"><h2>Type of Account</h2></div>
						<div class="well">Seller accounts are for Public/Private School Districts, College/Universities, Non-Profit Organizations, and Government Organizations. Seller Accounts must sign a service contract that will be sent to the email address used on this form before the account is activated in the system.</div>
						<div class="form-group">
							<label for="AccountType" class="control-label col-sm-3">Account Type:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="TypeOfAccountRequested" class="form-control" Required="Yes" Multiple="No" query="TypeAccountQuery" selected="#Session.FormData.TypeOfAccountRequested#" value="ID" Display="OptionName"  queryposition="below">
									<option value="----">Select Account Type</option>
								</cfselect>
							</div>
						</div>
					</div>
					<div class="panel-footer">
						<cfinput type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Update User Account"><br /><br />
					</div>
				</cfif>
			</cfform>
		<cfelse>
			<div class="panel-heading"><h1>Delete User Account</h1></div>
			<cfform action="" method="post" id="CreateNewUser" class="form-horizontal">
				<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
				<cfinput type="hidden" name="formSubmit" value="true">
				<cfinput type="hidden" name="PerformAction" value="DeleteUser">
				<cfinput type="hidden" name="UserID" value="#URL.UserID#">
				<div class="panel-body">
					<div class="form-group">
						<label for="UserFirstName" class="control-label col-sm-3">First Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserFirstName" name="UserFirstName" value="#Session.getSelectedUser.Fname#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="UserLastName" class="control-label col-sm-3">Last Name:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserLastName" name="UserLastName" value="#Session.getSelectedUser.Lname#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="UserEmail" class="control-label col-sm-3">Email Address:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="UserEmail" name="UserEmail" value="#Session.getSelectedUser.Email#" required="yes"></div>
					</div>
					<div class="form-group">
						<label for="DesiredPassword" class="control-label col-sm-3">Desired Password:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="password" class="form-control" id="DesiredPassword" name="DesiredPassword" required="no"></div>
					</div>
					<div class="form-group">
						<label for="VerifyDesiredPassword" class="control-label col-sm-3">Verify Password:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="password" class="form-control" id="VerifyDesiredPassword" name="VerifyDesiredPassword" required="no"></div>
					</div>
					<div class="form-group">
						<label for="UserSecurityRole" class="control-label col-sm-3">User Role:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="UserSecurityRole" class="form-control" Required="Yes" Multiple="No" query="Session.getSecurityRoles" selected="#Session.getSelectedUserSecurityRole.GroupID#" value="UserID" Display="GroupName"  queryposition="below">
								<option value="0">No Additional Security Role</option>
							</cfselect>
						</div>
					</div>
					<div class="form-group">
						<label for="UserActive" class="control-label col-sm-3">InActive:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="UserActive" class="form-control" Required="Yes" Multiple="No" query="UserInActiveQuery" selected="#Session.getSelectedUser.InActive#" value="ID" Display="OptionName"  queryposition="below">
								<option value="0">Is User InActive in System</option>
							</cfselect>
						</div>
					</div>
					<div class="form-group">
						<label for="ZipCode" class="control-label col-sm-3">ZipCode:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ZipCode" name="ZipCode" value="#Session.getSelectedUser.ZipCode#" required="no"></div>
					</div>
					<div class="form-group">
						<label for="ContactNumber" class="control-label col-sm-3">Contact Number:&nbsp;</label>
						<div class="col-sm-8"><cfinput type="text" class="form-control" id="ContactNumber" name="ContactNumber" value="#Session.getSelectedUser.TelephoneNumber#" required="no"></div>
					</div>
					<br /><br />
					<div class="panel-heading"><h2>Type of Account</h2></div>
					<div class="well">Seller accounts are for Public/Private School Districts, College/Universities, Non-Profit Organizations, and Government Organizations. Seller Accounts must sign a service contract that will be sent to the email address used on this form before the account is activated in the system.</div>
					<div class="form-group">
						<label for="AccountType" class="control-label col-sm-3">Account Type:&nbsp;</label>
						<div class="col-sm-8">
							<cfselect name="TypeOfAccountRequested" class="form-control" Required="Yes" Multiple="No" query="TypeAccountQuery" selected="#Session.getSelectedUser.AccountType#" value="ID" Display="OptionName"  queryposition="below">
								<option value="----">Select Account Type</option>
							</cfselect>
						</div>
					</div>
				</div>
				<div class="panel-footer">
					<cfinput type="Submit" name="DeleteUserAccount" class="btn btn-primary pull-right" value="Delete User Account"><br /><br />
				</div>
			</cfform>
		</cfif>
	</div>
</cfoutput>