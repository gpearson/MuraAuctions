<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2015 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfoutput>
	<script>
		$.jgrid.defaults.responsive = true;
		$.jgrid.defaults.styleUI = 'Bootstrap';
	</script>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Auction Users</h1></div>
		<div class="panel-body">
			<cfif isDefined("URL.UserAction")>
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="CategoryCreated">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully created a new category for auction items.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the category information was not added to the database.
							</div>
						</cfif>
					</cfcase>
					<cfcase value="CategoryUpdated">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully updated a category for auction items.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the category information was not updated in the database.
							</div>
						</cfif>
					</cfcase>
					<cfcase value="CategoryDeleted">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully deleted a category from the available auction items.
							</div>
						<cfelse>
							<cfif isDefined("URL.CategoryHasChildren")>
								<div class="alert alert-danger">
									This portal is unable to delete the selected category because the category has children categories below it. In order to delete the selected category, you first must either move its children to another parent category or delete all of the children under this parent category.
								</div>
							<cfelse>
								<div class="alert alert-danger">
									An error has occurred and the category information was not deleted from the database.
								</div>
							</cfif>
						</cfif>
					</cfcase>
				</cfswitch>
			</cfif>
			<table id="jqGrid"></table>
			<div id="jqGridPager"></div>
			<div id="dialog" title="Feature not supported" style="display:none"><p>That feature is not supported.</p></div>
		</div>
	</div>
	<script type="text/javascript">
		$(document).ready(function () {
			var selectedRow = 0;
			$("##jqGrid").jqGrid({
				url: "/plugins/#rc.pc.getPackage()#/siteadmin/controllers/settings.cfc?method=getAllUsers",
				// we set the changes to be made at client side using predefined word clientArray
				datatype: "json",
				colNames: ["User ID","Last Name","First Name","Username","Group Name","In Active"],
				colModel: [
					{ label: 'Rec ##', name: 'UserID', width: 75, key: true, editable: false },
					{ label: 'Last Name', name: 'Lname', editable: true },
					{ label: 'First Name', name: 'Fname', editable: true },
					{ label: 'UserName', name: 'UserName', editable: true },
					{ label: 'Security Role', name: 'GroupName', editable: true },
					{ label: 'In Active', name: 'InActive', width: 50, editable: true, edittype: "select", editoptions: { value: "1:Yes;0:No"}}
				],
				sortname: 'Lname',
				sortorder : 'asc',
				viewrecords: true,
				height: 500,
				autowidth: true,
				rowNum: 30,
				pgText: " of ",
				pager: "##jqGridPager",
				jsonReader: {
					root: "ROWS",
					page: "PAGE",
					total: "TOTAL",
					records: "RECORDS",
					cell: "",
					id: "0"
				},
				onSelectRow: function(id){
					//We verify a valid new row selection
					if(id && id!==selectedRow) {
						//If a previous row was selected, but the values were not saved, we restore it to the original data.
						$('##jqGrid').restoreRow(selectedRow);
						selectedRow=id;
					}
				}
			});
			$('##jqGrid').navGrid('##jqGridPager', {edit: false, add: false, del:false, search:false});

			$('##jqGrid').navButtonAdd('##jqGridPager',
				{
					caption: "",
					buttonicon: "glyphicon-plus",
					onClickButton: function(id) {
						var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=siteadmin:settings.newuser";
						window.open(urlToGo,"_self");
					},
					position: "last"
				}
			)

			$('##jqGrid').navButtonAdd('##jqGridPager',
				{
					caption: "",
					buttonicon: "glyphicon-pencil",
					onClickButton: function(id) {
						if (selectedRow == 0) {
							alert("Please Select a Row to edit a Category in the database");
						} else {
							var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=siteadmin:settings.edituser&UserID="+ selectedRow;
							window.open(urlToGo,"_self");
						}
						},
					position: "last"
				}
			)
			$('##jqGrid').navButtonAdd('##jqGridPager',
				{
					caption: "",
					buttonicon: "glyphicon-remove",
					onClickButton: function(id) {
						if (selectedRow == 0) {
							alert("Please Select a Row to deactivate a Category in the database");
						} else {
							var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=siteadmin:settings.edituser&PerformAction=DeleteUser&UserID="+ selectedRow;
							window.open(urlToGo,"_self");
						}
					},
					position: "last"
				}
			)
		});
	</script>
</cfoutput>