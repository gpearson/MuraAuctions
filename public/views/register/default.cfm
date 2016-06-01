<cfoutput>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Account Information</h1></div>
		<cfif isDefined("URL.UserAction")>
			<div class="panel-body">
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="AccountCreated">
						<cfif isDefined("URL.Successful")>
							<cfif URL.Successful EQ "true">
								<div class="alert alert-success">
									You have successfully created an account. You will be receiving an email with a link to click on that will activate your account.
								</div>
							<cfelse>
								<div class="alert alert-danger">
									An error has occurred and the customer record was not added to the database.
								</div>
							</cfif>
						</cfif>
					</cfcase>
				</cfswitch>
			</div>
		</cfif>
	</div>
</cfoutput>