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
						<li class="<cfif rc.action eq 'public:main.default'>active</cfif>"><a href="#buildURL('public:main')#">Home</a></li>
					</ul>
					<ul class="nav navbar-nav navbar-right">
						<li class="<cfif rc.action contains 'public:license'>active</cfif>">
							<a href="#buildURL('public:license')#"><i class="icon-book"></i> License</a>
						</li>
						<li class="<cfif rc.action contains 'public:contactus'>active</cfif>">
							<a href="#buildURL('public:contactus.sendfeedback')#"><i class="icon-info-sign"></i> Contact Us</a>
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