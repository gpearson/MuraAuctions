<cfoutput>
	<div class="container">
		<!--- PRIMARY NAV --->
		<div class="row-fluid">
			<nav class="navbar">
				<div class="navbar-inner">
					<div class="navbar-header">
						<a class="navbar-brand"><!--- #HTMLEditFormat(rc.pc.getPackage())# ---></a>
					</div>
					<ul class="nav navbar-nav">
						<li class="<cfif rc.action eq 'public:main'>active</cfif> dropdown">
							<a class="dropdown-toggle" data-toggle="dropdown" href="#buildURL('public:main')#">Home <span class="caret"></span></a>
							<ul class="dropdown-menu">
								<cfif Session.Mura.IsLoggedIn EQ True>
									<li class="<cfif rc.action eq 'public:main.login'>active</cfif>">
										<a href="/index.cfm/auction-site/?doaction=logout">Account Logout</a>
									</li>
									<li class="<cfif rc.action eq 'public:main.login'>active</cfif>">
										<a href="?display=login">Manage Profile</a>
									</li>
								<cfelse>
									<li class="<cfif rc.action eq 'public:main.login'>active</cfif>">
										<a href="?display=login">Account Login</a>
									</li>
									<li class="<cfif rc.action eq 'public:register.account'>active</cfif>">
										<a href="#buildURL('public:register.account')#">Register Account</a>
									</li>
									<li class="<cfif rc.action eq 'public:main.forgotpassword'>active</cfif>">
										<a href="#buildURL('public:main.forgotpassword')#">Forgot Password</a>
									</li>
								</cfif>

							</ul>
						</li>
					</ul>
					<ul class="nav navbar-nav navbar-right">
						<li class="<cfif rc.action eq 'public:main'>active</cfif> dropdown">
							<a class="dropdown-toggle" data-toggle="dropdown" href="#buildURL('siteadmin:settings.default')#">Settings <span class="caret"></span></a>
							<ul class="dropdown-menu">
								<li class="<cfif rc.action eq 'siteadmin:settings.categories'>active</cfif>">
									<a href="#buildURL('siteadmin:settings.categories')#"> Categories</a>
								</li>
								<li class="<cfif rc.action eq 'siteadmin:settings.securitygroups'>active</cfif>">
									<a href="#buildURL('siteadmin:settings.securitygroups')#">Security Groups</a>
								</li>
								<li class="<cfif rc.action eq 'siteadmin:settings.users'>active</cfif>">
									<a href="#buildURL('siteadmin:settings.users')#">Users</a>
								</li>
							</ul>
						</li>
						<li class="<cfif rc.action contains 'siteadmin:license'>active</cfif>">
							<a href="#buildURL('siteadmin:license')#">License</a>
						</li>
						<li class="<cfif rc.action contains 'siteadmin:contactus'>active</cfif>">
							<a href="#buildURL('siteadmin:contactus.sendfeedback')#">Contact Us</a>
						</li>
					</ul>
				</div>
			</nav>
		</div>
		<div class="row-fluid">
			<!--- SUB-NAV --->
			<div class="span3">
				<ul class="nav nav-list">

				</ul>
			</div>
			<!--- BODY --->
			<div class="span9">
				#body#
			</div>
		</div>
	</div>
</cfoutput>