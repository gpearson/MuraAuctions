<cfsilent>
<!---

This file is part of MuraFW1

Copyright 2010-2015 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
	<cfif Session.Mura.IsLoggedIn EQ True>
		<cfparam name="Session.Mura.AdminSiteAdminRole" default="0" type="boolean">
		<cfparam name="Session.Mura.AuctionSellerRole" default="0" type="boolean">
		<cfparam name="Session.Mura.SuperAdminRole" default="0" type="boolean">
		<cfset UserMembershipQuery = #$.currentUser().getMembershipsQuery()#>
		<cfloop query="#Variables.UserMembershipQuery#">
			<cfif UserMembershipQuery.GroupName EQ "Auction Site Admin"><cfset Session.Mura.AdminSiteAdminRole = true></cfif>
		</cfloop>
		<cfif Session.Mura.Username EQ "admin"><cfset Session.Mura.SuperAdminRole = true></cfif>

		<cfif Session.Mura.AdminSiteAdminRole EQ "True">
			<cfoutput>#Variables.this.redirect("siteadmin:main.default")#</cfoutput>
		</cfif>

		<cfif Session.getSellerOrganizationInfo.AccountType EQ 0>
			<cfoutput>#Variables.this.redirect("selleradmin:main.default")#</cfoutput>
		</cfif>
	<cfelse>
		<cfparam name="Session.Mura.AdminSiteAdminRole" default="0" type="boolean">
		<cfparam name="Session.Mura.SuperAdminRole" default="0" type="boolean">
	</cfif>
</cfsilent>
<cfoutput>
	<script>
		$.jgrid.defaults.responsive = true;
		$.jgrid.defaults.styleUI = 'Bootstrap';
	</script>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Current Live Auctions</h1></div>
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
				url: "/plugins/#rc.pc.getPackage()#/public/controllers/main.cfc?method=getAllActiveAuctions",
				// we set the changes to be made at client side using predefined word clientArray
				datatype: "json",
				colNames: ["Rec No","Item Name","Starting Bid","Current Bid","Begin Date","End Date","Active"],
				colModel: [
					{ label: 'Rec ##', name: 'TContent_ID', width: 75, key: true, editable: false },
					{ label: 'Business Name', name: 'BusinessName', editable: true },
					{ label: 'Physical Address', name: 'PhysicalAddress', width: 100, editable: true },
					{ label: 'City', name: 'PhysicalCity', width: 75, editable: true },
					{ label: 'State', name: 'PhysicalState', width: 50, editable: true },
					{ label: 'Zip Code', name: 'PhysicalZipCode', width: 100, editable: true },
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
					buttonicon: "glyphicon-search",
					onClickButton: function(id) {
						if (selectedRow == 0) {
							alert("Please Select a Row to view current infomation about an auction item");
						} else {
							var grid = $('##jqGrid');
							var auctionIDValue = grid.getCell(selectedRow, 'TContent_ID');
							var urlToGo = "http://" + window.location.hostname + "#cgi.script_name#" + "#cgi.path_info#?#rc.pc.getPackage()#action=public:main.viewauction&AuctionID=" + auctionIDValue;
							window.open(urlToGo,"_self");
						}
					},
					position: "last"
				}
			)
		});
	</script>
</cfoutput>