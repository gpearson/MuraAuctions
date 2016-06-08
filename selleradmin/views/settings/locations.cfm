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
		<div class="panel-heading"><h1>Organization's Surplus Property Locations</h1></div>
		<div class="panel-body">
			<cfif isDefined("URL.UserAction")>
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="LocationCreated">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully created a new location where surplus property items are located for future auctions.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the location information was not added to the database.
							</div>
						</cfif>
					</cfcase>
					<cfcase value="LocationUpdated">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully updated a location where surplus property items are located.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the location information was not updated in the database.
							</div>
						</cfif>
					</cfcase>
					<cfcase value="LocationDeleted">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully deleted a location from the organization's database.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the location information was not deleted from the database.
							</div>
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
				url: "/plugins/#rc.pc.getPackage()#/selleradmin/controllers/settings.cfc?method=getAllLocations",
				// we set the changes to be made at client side using predefined word clientArray
				datatype: "json",
				colNames: ["Rec No","Location Name","Address","City","State","ZipCode","Zip4","Active"],
				colModel: [
					{ label: 'Rec ##', name: 'TContent_ID', width: 75, key: true, editable: false },
					{ label: 'Location Name', name: 'LocationName', editable: true },
					{ label: 'Address', name: 'PhysicalAddress', editable: true },
					{ label: 'City', name: 'PhysicalCity', editable: true },
					{ label: 'State', name: 'PhysicalState', editable: true },
					{ label: 'ZipCode', name: 'PhysicalZipCode', editable: true },
					{ label: 'Zip4', name: 'PhysicalZip4', editable: true },
					{ label: 'Active', name: 'Active', width: 50, editable: true, edittype: "select", editoptions: { value: "1:Yes;0:No"}}
				],
				sortname: 'TContent_ID',
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
						var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=selleradmin:settings.newlocation";
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
							var grid = $('##jqGrid');
							var RowIDValue = grid.getCell(selectedRow, 'TContent_ID');
							var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=selleradmin:settings.editlocation&LocationID="+ RowIDValue;
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
							var grid = $('##jqGrid');
							var RowIDValue = grid.getCell(selectedRow, 'TContent_ID');
							var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=selleradmin:settings.editlocation&PerformAction=DeleteLocation&LocationID="+ RowIDValue;
							window.open(urlToGo,"_self");
						}
					},
					position: "last"
				}
			)
		});
	</script>
</cfoutput>