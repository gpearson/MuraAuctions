/*

This file is part of MuraFW1

Copyright 2010-2013 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
<cfcomponent output="false" persistent="false" accessors="true">
	<cffunction name="default" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

	</cffunction>

	<cffunction name="getAllCategories" access="remote" returnformat="json">
		<cfargument name="page" required="no" default="1" hint="Page user is on">
		<cfargument name="rows" required="no" default="10" hint="Number of Rows to display per page">
		<cfargument name="sidx" required="no" default="" hint="Sort Column">
		<cfargument name="sord" required="no" default="ASC" hint="Sort Order">

		<cfset var arrCategories = ArrayNew(1)>
		<cfquery name="getCategories" dbtype="Query">
			Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
			From Session.getCategories
			<cfif Arguments.sidx NEQ "">
				Order By #Arguments.sidx# #Arguments.sord#
			<cfelse>
				Order by Category_Name #Arguments.sord#
			</cfif>
		</cfquery>

		<!--- Calculate the Start Position for the loop query. So, if you are on 1st page and want to display 4 rows per page, for first page you start at: (1-1)*4+1 = 1.
				If you go to page 2, you start at (2-)1*4+1 = 5 --->
		<cfset start = ((arguments.page-1)*arguments.rows)+1>

		<!--- Calculate the end row for the query. So on the first page you go from row 1 to row 4. --->
		<cfset end = (start-1) + arguments.rows>

		<!--- When building the array --->
		<cfset i = 1>

		<cfloop query="getCategories" startrow="#start#" endrow="#end#">
			<!--- Array that will be passed back needed by jqGrid JSON implementation --->
			<cfif #isActive# EQ 1>
				<cfset strActive = "Yes">
			<cfelse>
				<cfset strActive = "No">
			</cfif>
			<cfset arrCategories[i] = [#Category_ID#,#Category_Name#,#ParentCategory_ID#,#strActive#,#DateCreated#,#lastUpdateBy#,#lastUpdate#]>
			<cfset i = i + 1>
		</cfloop>

		<!--- Calculate the Total Number of Pages for your records. --->
		<cfset totalPages = Ceiling(getCategories.recordcount/arguments.rows)>

		<!--- The JSON return.
			Total - Total Number of Pages we will have calculated above
			Page - Current page user is on
			Records - Total number of records
			rows = our data
		--->
		<cfset stcReturn = {total=#totalPages#,page=#Arguments.page#,records=#getCategories.recordcount#,rows=arrCategories}>
		<cfreturn stcReturn>
	</cffunction>

	<cffunction name="getAllUsers" access="remote" returnformat="json">
		<cfargument name="page" required="no" default="1" hint="Page user is on">
		<cfargument name="rows" required="no" default="10" hint="Number of Rows to display per page">
		<cfargument name="sidx" required="no" default="" hint="Sort Column">
		<cfargument name="sord" required="no" default="ASC" hint="Sort Order">

		<cfset var arrUsers = ArrayNew(1)>

		<cfset userQuery = QueryNew("UserID,Fname,Lname,UserName,Email,GroupName,InActive", "VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,Integer")>

		<cfloop query="Session.getUsersWithGroupAccess">
			<cfset temp = QueryAddRow(userQuery, 1)>
			<cfset temp = #QuerySetCell(userQuery, "UserID", Session.getUsersWithGroupAccess.UserID)#>
			<cfset temp = #QuerySetCell(userQuery, "Fname", Session.getUsersWithGroupAccess.Fname)#>
			<cfset temp = #QuerySetCell(userQuery, "Lname", Session.getUsersWithGroupAccess.Lname)#>
			<cfset temp = #QuerySetCell(userQuery, "UserName", Session.getUsersWithGroupAccess.UserName)#>
			<cfset temp = #QuerySetCell(userQuery, "Email", Session.getUsersWithGroupAccess.Email)#>
			<cfset temp = #QuerySetCell(userQuery, "GroupName", Session.getUsersWithGroupAccess.GroupName)#>
			<cfset temp = #QuerySetCell(userQuery, "InActive", Session.getUsersWithGroupAccess.InActive)#>
		</cfloop>

		<cfloop query="Session.getBuyers">
			<cfquery name="CheckUsers" dbtype="Query">
				Select UserID, Fname, Lname, UserName, Email, GroupName, InActive
				From userQuery
				Where UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.getBuyers.UserID#">
			</cfquery>
			<cfif CheckUsers.RecordCount EQ 0>
				<cfset temp = QueryAddRow(userQuery, 1)>
				<cfset temp = #QuerySetCell(userQuery, "UserID", Session.getBuyers.UserID)#>
				<cfset temp = #QuerySetCell(userQuery, "Fname", Session.getBuyers.Fname)#>
				<cfset temp = #QuerySetCell(userQuery, "Lname", Session.getBuyers.Lname)#>
				<cfset temp = #QuerySetCell(userQuery, "UserName", Session.getBuyers.UserName)#>
				<cfset temp = #QuerySetCell(userQuery, "Email", Session.getBuyers.Email)#>
				<cfset temp = #QuerySetCell(userQuery, "GroupName", "")#>
				<cfset temp = #QuerySetCell(userQuery, "InActive", Session.getBuyers.InActive)#>
			</cfif>
		</cfloop>

		<cfquery name="getUsers" dbtype="Query">
			Select UserID, Fname, Lname, UserName, Email, GroupName, InActive
			From userQuery
			<cfif Arguments.sidx NEQ "">
				Order By #Arguments.sidx# #Arguments.sord#
			<cfelse>
				Order by Lname #Arguments.sord#, Fname #Arguments.sord#, Email #Arguments.sord#
			</cfif>
		</cfquery>

		<!--- Calculate the Start Position for the loop query. So, if you are on 1st page and want to display 4 rows per page, for first page you start at: (1-1)*4+1 = 1.
				If you go to page 2, you start at (2-)1*4+1 = 5 --->
		<cfset start = ((arguments.page-1)*arguments.rows)+1>

		<!--- Calculate the end row for the query. So on the first page you go from row 1 to row 4. --->
		<cfset end = (start-1) + arguments.rows>

		<!--- When building the array --->
		<cfset i = 1>

		<cfloop query="getUsers" startrow="#start#" endrow="#end#">
			<!--- Array that will be passed back needed by jqGrid JSON implementation --->
			<cfif #InActive# EQ 1>
				<cfset strActive = "Yes">
			<cfelse>
				<cfset strActive = "No">
			</cfif>
			<cfset arrUsers[i] = [#UserID#,#Lname#,#Fname#,#UserName#,#GroupName#,#strActive#]>
			<cfset i = i + 1>
		</cfloop>

		<!--- Calculate the Total Number of Pages for your records. --->
		<cfset totalPages = Ceiling(getUsers.recordcount/arguments.rows)>

		<!--- The JSON return.
			Total - Total Number of Pages we will have calculated above
			Page - Current page user is on
			Records - Total number of records
			rows = our data
		--->
		<cfset stcReturn = {total=#totalPages#,page=#Arguments.page#,records=#getUsers.recordcount#,rows=arrUsers}>
		<cfreturn stcReturn>
	</cffunction>

	<cffunction name="categories" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfquery name="Session.getCategories" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
			From p_Auction_ProductCategories
			Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#">
			Order by ParentCategory_ID, Category_Name
		</cfquery>

	</cffunction>

	<cffunction name="newcategory" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfquery name="Session.getParentCategories" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
					From p_Auction_ProductCategories
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
						ParentCategory_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
					Order by Category_Name
				</cfquery>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfquery name="insertCategory" result="InsertNewRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
				Insert into p_Auction_ProductCategories(Category_Name, DateCreated, isActive, Site_ID, ParentCategory_ID)
				Values(
					<cfqueryparam value="#FORM.CategoryName#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="1" cfsqltype="cf_sql_bit">,
					<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#FORM.CategoryParentID#" cfsqltype="cf_sql_integer">
				)
			</cfquery>
			<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.categories&UserAction=CategoryCreated&Successful=True">
		</cfif>

	</cffunction>

	<cffunction name="editcategory" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfquery name="Session.getParentCategories" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
					From p_Auction_ProductCategories
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
						ParentCategory_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
					Order by Category_Name
				</cfquery>

				<cfquery name="Session.getSelectedCategory" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
					From p_Auction_ProductCategories
					Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
						Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.CategoryID#">
					Order by Category_Name
				</cfquery>
			</cflock>
		<cfelseif isDefined("FORM.formSubmit")>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif not isDefined("FORM.PerformAction")>
				<cfquery name="updateCategory" result="InsertNewRecord" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Update p_Auction_ProductCategories
					Set Category_Name = <cfqueryparam value="#FORM.CategoryName#" cfsqltype="cf_sql_varchar">,
						ParentCategory_ID = <cfqueryparam value="#FORM.CategoryParentID#" cfsqltype="cf_sql_integer">,
						isActive = <cfqueryparam value="#FORM.CategoryActive#" cfsqltype="cf_sql_bit">,
						lastUpdate = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						lastUpdateBy = <cfqueryparam value="#rc.$.currentUser('userName')#" cfsqltype="cf_sql_varchar">
					Where Category_ID = <cfqueryparam value="#FORM.CategoryID#" cfsqltype="cf_sql_integer">
				</cfquery>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.categories&UserAction=CategoryUpdated&Successful=True">
			<cfelseif isDefined("FORM.PerformAction")>
				<cfswitch expression="#FORM.CategoryDelete#">
					<cfcase value="1">
						<cfquery name="getSelectedCategory" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
							Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
							From p_Auction_ProductCategories
							Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
								Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CategoryID#">
						</cfquery>
						<cfif getSelectedCategory.ParentCategory_ID NEQ 0>
							<cfquery name="DeleteSelectedCategory" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								Delete from p_Auction_ProductCategories
								Where Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CategoryID#">
							</cfquery>
							<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.categories&UserAction=CategoryDeleted&Successful=True">
						<cfelse>
							<cfquery name="getChildrenCategories" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
								Select Category_ID, Category_Name, DateCreated, lastUpdateBy, lastUpdate, isActive, ParentCategory_ID
								From p_Auction_ProductCategories
								Where Site_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
									ParentCategory_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CategoryID#">
							</cfquery>

							<cfif getChildrenCategories.RecordCount EQ 0>
								<cfquery name="DeleteSelectedCategory" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
									Delete from p_Auction_ProductCategories
									Where Category_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.CategoryID#">
								</cfquery>
								<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.categories&UserAction=CategoryDeleted&Successful=True">
							<cfelse>
								<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.categories&UserAction=CategoryDeleted&Successful=False&CategoryHasChildren=True">
							</cfif>
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.categories">
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="users" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfquery name="Session.getUsersWithGroupAccess" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select tusers.UserID, tusers.Fname, tusers.Lname, tusers.UserName, tusers.Email, tGroupUsers.GroupName, tusers.InActive
			From tusers INNER JOIN tusersmemb on tusersmemb.UserID = tusers.UserID
				INNER JOIN tusers as tGroupUsers on tGroupUsers.UserID = tusersmemb.GroupID
			Where tusers.SiteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#">
			Order by tusers.Lname ASC, tusers.Fname ASC
		</cfquery>

		<cfquery name="Session.getBuyers" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
			Select UserID, Fname, Lname, UserName, Email, InActive
			From tusers
			Where SiteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rc.$.siteConfig('siteID')#"> and
				Fname is not null and UserName <> 'admin'
			Order by Lname ASC, Fname ASC
		</cfquery>
	</cffunction>

	<cffunction name="newuser" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">

		<cfif not isDefined("FORM.formSubmit")>
			<cflock timeout="60" scope="Session" type="Exclusive">
				<cfif not isDefined("Session.FormErrors")>
					<cfset Session.FormErrors = #ArrayNew()#>
				</cfif>
				<cfquery name="Session.getSecurityRoles" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
					Select UserID, GroupName
					From tusers
					Where GroupName is not null and GroupName <> 'Admin'
				</cfquery>
			</cflock>
		<cfelse>
			<cfset Session.FormData = #StructCopy(FORM)#>
			<cfset Session.FormErrors = #ArrayNew()#>

			<cfif FORM.DesiredPassword NEQ FORM.VerifyDesiredPassword>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Password Field did not match the Verify Password Field. Please correct this before proceeding"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.newuser&FormRetry=True">
			</cfif>

			<cfif not isValid("email", FORM.UserEmail)>
				<cflock timeout="60" scope="SESSION" type="Exclusive">
					<cfscript>
						errormsg = {property="HumanChecker",message="The Email Address entered did not look like it was in proper email format. Please check the email address again before proceeding"};
						arrayAppend(Session.FormErrors, errormsg);
					</cfscript>
				</cflock>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.newuser&FormRetry=True">
			</cfif>

			<!--- Initiates the User Bean --->
			<cfset NewUser = #Application.userManager.readByUsername(form.UserEmail, rc.$.siteConfig('siteID'))#>
			<cfset NewUser.setInActive(1)>
			<cfset NewUser.setSiteID(rc.$.siteConfig('siteID'))>
			<cfset NewUser.setFname(FORM.UserFirstName)>
			<cfset NewUser.setLname(FORM.UserLastName)>
			<cfset NewUser.setUsername(FORM.UserEmail)>
			<cfset NewUser.setPassword(FORM.DesiredPassword)>
			<cfset NewUser.setEmail(FORM.UserEmail)>

			<cfif NewUser.checkUsername() EQ "false">
				<!--- Username already exists within the database. --->
				<cfscript>
					UsernameExists = {property="UserName",message="The Email Address already exists within the database as the Username to your account. If this Email Address is your account, you can request a forgot password by clicking on the Forgot Password Link under the Home Navigation Menu at the top of this screen. Otherwise please enter a different email address so your account can be created."};
					arrayAppend(Session.FormErrors, UsernameExists);
				</cfscript>
				<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.newuser&FormRetry=True">
			<cfelse>
				<cfset AddNewAccount = #Application.userManager.save(NewUser)#>

				<cfif LEN(AddNewAccount.getErrors()) EQ 0>
					<cfset NewUserID = #AddNewAccount.getUserID()#>
					<cfset SendEmailCFC = createObject("component","plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/EmailServices")>

					<cfquery name="insertUserMatrixInfo" Datasource="#rc.$.globalConfig('datasource')#" username="#rc.$.globalConfig('dbusername')#" password="#rc.$.globalConfig('dbpassword')#">
						Insert into p_Auction_UserMatrix(User_ID,Site_ID,AccountType,lastUpdateBy,lastUpdated)
						Values(
							<cfqueryparam value="#Variables.NewUserID#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#rc.$.siteConfig('siteID')#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#FORM.TypeOfAccountRequested#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#rc.$.currentUser('userName')#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
						)
					</cfquery>

					<cfswitch expression="#FORM.TypeOfAccountRequested#">
						<cfcase value="1">
							<!--- This Account Type is Buyers --->
							<cfset SendActivationEmail = #SendEmailCFC.SendBuyerAccountActivationEmail(rc, Variables.NewUserID)#>
							<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.users&UserAction=AccountCreated&Successful=True">
						</cfcase>
						<cfcase value="0">
							<!--- This Account Type is Sellers --->
							<cfset SendActivationEmail = #SendEmailCFC.SendSellerAccountActivationEmail(rc, Variables.NewUserID)#>
							<cfset SendOrganizationInfoEmail = #SendEmailCFC.SendSellerAccountOrganizationInfoEmail(rc, Variables.NewUserID)#>
							<cflocation url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=siteadmin:settings.users&UserAction=AccountCreated&Successful=True">
						</cfcase>
					</cfswitch>
				<cfelse>
					<cfdump var="#AddNewAccount.getErrors()#"><cfabort>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>


	<cffunction name="securitygroups" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">


	</cffunction>





</cfcomponent>