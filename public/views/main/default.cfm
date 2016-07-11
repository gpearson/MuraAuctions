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

		<cfif isDefined("Session.getSellerOrganizationInfo")>
			<cfif Session.getSellerOrganizationInfo.AccountType EQ 0>
				<cfoutput>#Variables.this.redirect("selleradmin:main.default")#</cfoutput>
			</cfif>
		</cfif>

		<cfif Session.Mura.SuperAdminRole EQ "true">
			<cfoutput>#Variables.this.redirect("siteadmin:main.default")#</cfoutput>
		</cfif>

		<cfif isDefined("Session.UserToPlaceBid")>
			<cfif isDefined("Session.UserToPlaceBid.AuctionID")>
				<cflocation addtoken="true" url="#CGI.Script_name##CGI.path_info#?#HTMLEditFormat(rc.pc.getPackage())#action=public:main.placebid&AuctionID=#Session.UserToPlaceBid.AuctionID#">
			</cfif>
		</cfif>
	<cfelse>
		<cfparam name="Session.Mura.AdminSiteAdminRole" default="0" type="boolean">
		<cfparam name="Session.Mura.SuperAdminRole" default="0" type="boolean">
		<cfparam name="Session.Mura.AuctionSellerRole" default="0" type="boolean">
	</cfif>
</cfsilent>
<cfoutput>
	<script>
		$.jgrid.defaults.responsive = true;
		$.jgrid.defaults.styleUI = 'Bootstrap';
	</script>
	<cfif Session.Mura.IsLoggedIn EQ True>
		<table class="table">
			<tr>
				<td><strong>Logged In:</strong> #Session.Mura.Fname# #Session.Mura.Lname#</td>
				<td><strong>Login Last:</strong> #DateFormat(Session.Mura.LastLogin, "Full")#</td>
			</tr>
		</table>
	</cfif>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Current Live Auctions</h1></div>
		<div class="panel-body">
			<cfif isDefined("Session.getSellerOrganizationInfo")>
				<cfif Session.getSellerOrganizationInfo.RecordCount EQ 0>
					<div class="alert alert-warning">
						The system is in the process of sending you an email to your registered email address asking for additional information that is currently missing for your account. Until this information has been completed, you will have limited access to this website.
					</div>
				</cfif>
				<CFIF Session.getSellerOrganizationInfo.RecordCount NEQ 0 and Session.getSellerOrganizationinfo.ReceivedSellerContract EQ 0>
					<br />
					<div class="alert alert-warning">
						The system is in the process of sending you an email regarding the Seller's Contract for review, to be signed and returned to us. Once we receive it, your account will be updated and have full access to this site.
					</div>
				</cfif>
			</cfif>
			<cfif isDefined("URL.UserAction")>
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="AuctionWon">
						<cfif URL.Successful EQ "True">
							<div class="alert alert-success">
								You have sucessfully won an auction item. We are in the process of sending you a confirmation email that will give you instructions on what to bring to the pickup location.
							</div>
						<cfelse>
							<div class="alert alert-error">
								An error has occurred and your bid was not placed for the item you were looking at. Please try to place your bid again.
							</div>
						</cfif>
					</cfcase>
					<cfcase value="BidSuccessful">
						<cfif URL.Successful EQ "True">
							<div class="alert alert-success">
								You have sucessfully placed your bid for the item.
							</div>
						<cfelse>
							<div class="alert alert-error">
								An error has occurred and your bid was not placed for the item you were looking at. Please try to place your bid again.
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
				url: "/plugins/#rc.pc.getPackage()#/public/controllers/main.cfc?method=getAllActiveAuctions",
				// we set the changes to be made at client side using predefined word clientArray
				datatype: "json",
				colNames: ["Auction ID","Item Name","Starting Bid","Current Bid","Begin Date","End Date","Active"],
				colModel: [
					{ label: 'Auction ID', name: 'TContent_ID', width: 75, key: true, editable: false },
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