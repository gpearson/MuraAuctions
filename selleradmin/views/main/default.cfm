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
		<div class="panel-heading"><h1>Current Active Auctions for Account</h1></div>
		<cfif isDefined("URL.UserAction")>
			<cfswitch expression="#URL.UserAction#">
				<br /><br />
				<cfcase value="AuctionCreated">
					<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully created a new auction item that can be purchased by the registered buyers of this application.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the auction item was not added to the database.
							</div>
						</cfif>
				</cfcase>
			</cfswitch>
		</cfif>
		<div class="panel-body">
			<table id="jqGrid"></table>
			<div id="jqGridPager"></div>
			<div id="dialog" title="Feature not supported" style="display:none"><p>That feature is not supported.</p></div>
		</div>
	</div>
	<script type="text/javascript">
		$(document).ready(function () {
			var selectedRow = 0;
			$("##jqGrid").jqGrid({
				url: "/plugins/#rc.pc.getPackage()#/selleradmin/controllers/auctions.cfc?method=getAllAuctions",
				// we set the changes to be made at client side using predefined word clientArray
				datatype: "json",
				colNames: ["Rec No","Item Name","Starting Bid","Current Bid","Start Date","End Date","Active"],
				colModel: [
					{ label: 'Rec ##', name: 'TContent_ID', width: 75, key: true, editable: false },
					{ label: 'Item Name', name: 'Item_Title', editable: false },
					{ label: 'Starting Bid', name: 'Starting_Price', width: 100, editable: false },
					{ label: 'Current Bid', name: '', width: 75, editable: false },
					{ label: 'Start Date', name: 'Auction_StartDate', width: 50, editable: false },
					{ label: 'End Date', name: 'Auction_EndDate', width: 100, editable: true },
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
					buttonicon: "glyphicon-pencil",
					onClickButton: function(id) {
						if (selectedRow == 0) {
							alert("Please Select a Row to edit a current auction item in the database");
						} else {
							var grid = $('##jqGrid');
							var auctionIDValue = grid.getCell(selectedRow, 'TContent_ID');
							var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=selleradmin:auctions.editauction&AuctionID=" + auctionIDValue;
							window.open(urlToGo,"_self");
						}
						},
					position: "last"
				}
			)
		});
	</script>
</cfoutput>