<cfset CategoryActiveQuery = QueryNew("ID,OptionName", "Integer,VarChar")>
<cfset temp = QueryAddRow(CategoryActiveQuery, 1)>
<cfset temp = #QuerySetCell(CategoryActiveQuery, "ID", 0)#>
<cfset temp = #QuerySetCell(CategoryActiveQuery, "OptionName", "No")#>
<cfset temp = QueryAddRow(CategoryActiveQuery, 1)>
<cfset temp = #QuerySetCell(CategoryActiveQuery, "ID", 1)#>
<cfset temp = #QuerySetCell(CategoryActiveQuery, "OptionName", "Yes")#>

<cfoutput>
	<div class="panel panel-default">
		<cfif not isDefined("URL.PerformAction")>
			<div class="panel-heading"><h1>Edit Auction Category</h1></div>
				<cfform action="" method="post" id="EditCategory" class="form-horizontal">
					<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<cfinput type="hidden" name="formSubmit" value="true">
					<cfinput type="hidden" name="CategoryID" value="#URL.CategoryID#">
					<div class="panel-body">
						<div class="form-group">
							<label for="CategoryName" class="control-label col-sm-3">Category Title:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="CategoryName" name="CategoryName" value="#Session.getSelectedCategory.Category_Name#" required="yes"></div>
						</div>
						<div class="form-group">
							<label for="CategoryParentID" class="control-label col-sm-3">Category Parent:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="CategoryParentID" class="form-control" Required="Yes" Multiple="No" selected="#Session.getSelectedCategory.ParentCategory_ID#" query="Session.getParentCategories" value="Category_ID" Display="Category_Name"  queryposition="below">
									<option value="0">Top Level Category</option>
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="CategoryActive" class="control-label col-sm-3">Category Active:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="CategoryActive" class="form-control" Required="Yes" Multiple="No" selected="#Session.getSelectedCategory.isActive#" query="CategoryActiveQuery" value="ID" Display="OptionName"  queryposition="below">
								</cfselect>
							</div>
						</div>
					</div>
					<div class="panel-footer">
						<cfinput type="Submit" name="EditCategory" class="btn btn-primary pull-right" value="Edit Category"><br /><br />
					</div>
				</cfform>
			</div>
		<cfelse>
			<div class="panel-heading"><h1>Delete Auction Category</h1></div>
				<cfform action="" method="post" id="EditCategory" class="form-horizontal">
					<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<cfinput type="hidden" name="formSubmit" value="true">
					<cfinput type="hidden" name="PerformAction" value="#URL.PerformAction#">
					<cfinput type="hidden" name="CategoryID" value="#URL.CategoryID#">
					<div class="panel-body">
						<div class="form-group">
							<label for="CategoryName" class="control-label col-sm-3">Category Title:&nbsp;</label>
							<div class="col-sm-8"><cfinput type="text" class="form-control" id="CategoryName" name="CategoryName" value="#Session.getSelectedCategory.Category_Name#" disabled="yes"></div>
						</div>
						<div class="form-group">
							<label for="CategoryParentID" class="control-label col-sm-3">Category Parent:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="CategoryParentID" class="form-control" disabled="Yes" Multiple="No" selected="#Session.getSelectedCategory.ParentCategory_ID#" query="Session.getParentCategories" value="Category_ID" Display="Category_Name"  queryposition="below">
									<option value="0">Top Level Category</option>
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="CategoryActive" class="control-label col-sm-3">Category Active:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="CategoryActive" class="form-control" disabled="Yes" Multiple="No" selected="#Session.getSelectedCategory.isActive#" query="CategoryActiveQuery" value="ID" Display="OptionName"  queryposition="below">
								</cfselect>
							</div>
						</div>
						<div class="form-group">
							<label for="CategoryDelete" class="control-label col-sm-3">Delete Category:&nbsp;</label>
							<div class="col-sm-8">
								<cfselect name="CategoryDelete" class="form-control" required="Yes" Multiple="No" query="CategoryActiveQuery" value="ID" Display="OptionName"  queryposition="below">
								</cfselect>
							</div>
						</div>
					</div>
					<div class="panel-footer">
						<cfinput type="Submit" name="DeleteCategory" class="btn btn-primary pull-right" value="Delete Category"><br /><br />
					</div>
				</cfform>
			</div>
		</cfif>
	</div>
</cfoutput>