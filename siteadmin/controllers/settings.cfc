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


	<cffunction name="securitygroups" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">


	</cffunction>

	<cffunction name="users" returntype="any" output="false">
		<cfargument name="rc" required="true" type="struct" default="#StructNew()#">


	</cffunction>



</cfcomponent>