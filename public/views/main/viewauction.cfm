<cfoutput>
	<style type="text/css">
		/* Customization Style of SyoTimer */
        .timer{
			text-align: center;
			margin: 30px auto 0;
			padding: 0 0 10px;
			border-bottom: 2px solid ##80a3ca;
		}
		.timer .table-cell{
			display: inline-block;
			margin: 0 5px;
			width: 79px;
			background: url(/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/images/timer.png) no-repeat 0 0;
		}
        .timer .table-cell .tab-val{
            font-size: 35px;
            color: ##80a3ca;
            height: 81px;
            line-height: 81px;
            margin: 0 0 5px;
        }
        .timer .table-cell .tab-metr{
            font-family: Arial;
            font-size: 12px;
            text-transform: uppercase;
        }
        ##simple_timer.timer .table-cell.day,
        ##periodic_timer_days.timer .table-cell.hour{
            width: 120px;
            background-image: url(/plugins/#HTMLEditFormat(rc.pc.getPackage())#/includes/assets/images/timer_long.png);
        }
		.vcenter {
			display: inline-block;
			vertical-align: middle;
			float: none;
		}
    </style>
	<cfif Session.Mura.IsLoggedIn EQ True>
		<table class="table">
			<tr>
				<td><strong>Logged In:</strong> #Session.Mura.Fname# #Session.Mura.Lname#</td>
				<td><strong>Login Last:</strong> #DateFormat(Session.Mura.LastLogin, "Full")#</td>
			</tr>
		</table>
	</cfif>
	<script type="text/javascript">
		$(document).ready(function(){
			/* Simple Timer. The countdown to 20:30 2100.05.09
			* --------------------------------------------------------- */
			$('##AuctionEndTimer').syotimer({
				year: #Year(Session.getSelectedAuction.Auction_EndDate)#,
				month: #Month(Session.getSelectedAuction.Auction_EndDate)#,
				day: #Day(Session.getSelectedAuction.Auction_EndDate)#,
				hour: 23,
				minute: 59,
			});
			$('##AuctionStartsTimer').syotimer({
				year: #Year(Session.getSelectedAuction.Auction_StartDate)#,
				month: #Month(Session.getSelectedAuction.Auction_StartDate)#,
				day: #Day(Session.getSelectedAuction.Auction_StartDate)#,
				hour: 0,
				minute: 0,
			});
		});
    </script>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Viewing Auction: #Session.getSelectedAuction.Item_Title#</h1></div>
		<div class="panel-body">
			<cfif isDefined("URL.UserAction")>
				<cfswitch expression="#URL.UserAction#">
					<cfcase value="BidSuccessful">
						<cfif URL.Successful EQ "true">
							<div class="alert alert-success">
								You have successfully placed your bid for this time.
							</div>
						<cfelse>
							<div class="alert alert-danger">
								An error has occurred and the category information was not added to the database.
							</div>
						</cfif>
					</cfcase>
				</cfswitch>
			</cfif>

			<div class="container-fluid">
				<div class="row">
					<div class="col-sm-3"><cfif Session.getSelectedAuctionPhotos.RecordCount>
						<cfset NumPhotos = #Session.getSelectedAuctionPhotos.RecordCount#>
						<cfset PhotoDir = "/plugins/" &#HTMLEditFormat(rc.pc.getPackage())# & "/includes/assets/photos/" & #URL.AuctionID# & "/">

						<cfswitch expression="#Variables.NumPhotos#">
							<cfcase value="1">
								<img src="#Variables.PhotoDir#/#Session.getSelectedAuctionPhotos.Filename[1]#" width="250" height="150" alt="Auction Item Photo" data-toggle="lightbox">
							</cfcase>
							<cfcase value="2">
								<img src="#Variables.PhotoDir#/#Session.getSelectedAuctionPhotos.Filename[1]#" id="AuctionImage1" width="250" height="150" alt="Auction Item Photo"></a>
								<img src="#Variables.PhotoDir#/#Session.getSelectedAuctionPhotos.Filename[2]#" id="AuctionImage2" width="75" height="75" alt="Auction Item Photo"></a>
							</cfcase>
							<cfcase value="3">
								<img src="#Variables.PhotoDir#/#Session.getSelectedAuctionPhotos.Filename[1]#" width="250" height="150" alt="Auction Item Photo" data-toggle="lightbox">
								<img src="#Variables.PhotoDir#/#Session.getSelectedAuctionPhotos.Filename[2]#" width="75" height="75" alt="Auction Item Photo" data-toggle="lightbox">
								<img src="#Variables.PhotoDir#/#Session.getSelectedAuctionPhotos.Filename[3]#" width="75" height="75" alt="Auction Item Photo" data-toggle="lightbox">
							</cfcase>
						</cfswitch>
						<div class="modal fade" id="ImageModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
							<div class="modal-dialog">
								<div class="modal-content">
									<div class="modal-header">
										<h4 class="modal-title" id="image-gallery-title">Full Sized Image</h4>
									</div>
									<div class="modal-body">
										<img id="AuctionImg" class="modal-content">
									</div>
									<div class="modal-footer">
										<span class="close" onclick="document.getElementById('ImageModal').style.display='none'"></span>
										<div id="caption"></div>
									</div>
								</div>
							</div>
						</div>
						<script language="javascript">
							// Get the modal
							var modal = document.getElementById('ImageModal');
							// Get the image and insert it inside the modal - use its "alt" text as a caption
							var img = document.getElementById('AuctionImage1');
							var modalImg = document.getElementById("AuctionImg");
							var captionText = document.getElementById("caption");
							img.onclick = function(){
								modal.style.display = "block";
								modalImg.src = this.src;
								modalImg.alt = this.alt;
								captionText.innerHTML = this.alt;
							}
							// Get the <span> element that closes the modal
							var span = document.getElementsByClassName("close")[0];

							// When the user clicks on <span> (x), close the modal
							span.onclick = function() {
								modal.style.display = "none";
							}
						</script>
					</cfif></div>
					<div class="col-sm-9">
						<div class="row">
							<div class="col-sm-3"><strong>Item Number</strong></div>
							<div class="col-sm-6">#Session.getSelectedAuction.Item_ModelNumber#</div>
						</div>
						<div class="row">
							<div class="col-sm-3"><strong>Description</strong></div>
							<div class="col-sm-6">#Session.getSelectedAuction.Item_Description#</div>
						</div>
						<div class="row">
							<div class="col-sm-9">&nbsp;</div>
						</div>
						<cfif Len(Session.getSelectedAuction.Item_UPC)>
							<div class="row"><div class="col-sm-12">&nbsp</div></div>
							<div class="row">
								<div class="col-sm-3"><strong>UPC BarCode</strong></div>
								<div class="col-sm-6">#Session.getSelectedAuction.Item_UPC#</div>
							</div>
						</cfif>
						<div class="row">
							<div class="col-sm-3"><strong>Condition</strong></div>
							<div class="col-sm-6">#Session.getSelectedAuction.Item_Condition#</div>
						</div>
						<div class="row">
							<div class="col-sm-3"><strong>Category</strong></div>
							<div class="col-sm-6">#Session.getSelectedAuction.Category_Name#</div>
						</div>
						<cfif Len(Session.getSelectedAuction.Item_YearsInService)>
							<div class="row">
								<div class="col-sm-3"><strong>Years In Service</strong></div>
								<div class="col-sm-6">#Session.getSelectedAuction.Item_YearsInService#</div>
							</div>
						</cfif>
						<cfif Len(Session.getSelectedAuction.Item_InfoWebsite)>
							<div class="row">
								<div class="col-sm-3"><strong>Item Info Website</strong></div>
								<div class="col-sm-6">#Session.getSelectedAuction.Item_InfoWebsite#</div>
							</div>
						</cfif>
						<cfif Len(Session.getSelectedAuction.AssetTag_Number)>
							<div class="row">
								<div class="col-sm-3"><strong>Asset Tag Number</strong></div>
								<div class="col-sm-6">#Session.getSelectedAuction.AssetTag_Number#</div>
							</div>
						</cfif>

						<div class="row">
							<div class="col-sm-3 vcenter"><strong>
								<cfif DateDiff("d", Now(), Session.getSelectedAuction.Auction_StartDate) GTE 1>
									Auction Starts in
								<cfelse>
									Auction Started
								</cfif>
								</strong></div>
							<div class="col-sm-7 vcenter">
								<cfif DateDiff("d", Now(), Session.getSelectedAuction.Auction_StartDate) GTE 1>
									<div id="AuctionStartsTimer"></div>
								<cfelse>
									#DateFormat(Session.getSelectedAuction.Auction_StartDate, "dddd, mmm dd, yyyy")#
								</cfif>
							</div>
						</div>
						<cfif DateDiff("d", Now(), Session.getSelectedAuction.Auction_StartDate) LT 1>
							<div class="row">
								<div class="col-sm-3 vcenter"><strong>Auction Ends</strong></div>
								<div class="col-sm-7 vcenter">
									<div id="AuctionEndTimer"></div>
								</div>
							</div>
						</cfif>
					</div>
				</div>
			</div>
		</div>
		<div class="panel-heading"><h1>Item Location Information</h1></div>
		<div class="panel-body">
			<div class="row">
				<div class="col-sm-3"><strong>Location</strong></div>
				<div class="col-sm-6">#Session.getLocationInfo.BusinessName#<br>#Session.getLocationInfo.PhysicalAddress#<br>#Session.getLocationInfo.PhysicalCity#, #Session.getLocationInfo.PhysicalState# #Session.getLocationInfo.PhysicalZipCode#</div>
				<div class="col-sm-3">Map Goes Here</div>
			</div>
		</div>

		<div class="panel-heading"><h1>Bid Information</h1></div>
		<cfform action="" method="post" id="BidOnAuction" class="form-horizontal">
			<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
			<cfinput type="hidden" name="formSubmit" value="true">
			<cfinput type="hidden" name="AuctionID" value="#URL.AuctionID#">
			<div class="panel-body">
				<div class="alert alert-info">Item must be picked up at the designated location within the Organization that is offering this item for auction.</div>
				<cfif isDefined("URL.BidToLow")>
					<br /><br />
					<div class="alert alert-danger"><p>#Session.FormErrors[1].Message#</p></div>
				</cfif>
				<cfif isDefined("URL.AlreadyHighestBidder")>
					<br /><br />
					<div class="alert alert-danger"><p>#Session.FormErrors[1].Message#</p></div>
				</cfif>

				<cfif DateDiff("d", Now(), Session.getSelectedAuction.Auction_StartDate) LTE 0>
					<cfswitch expression="#Session.getSelectedAuction.Auction_Type#">
						<cfcase value="Auction">
							<div class="container-fluid">
								<div class="row">
									<div class="col-sm-3"><strong>Starting Bid</strong></div>
									<div class="col-sm-6">#DollarFormat(Session.getSelectedAuction.Starting_Price)#</div>
									<div class="col-sm-3"><strong>Place Your Bid</strong></div>
								</div>
								<div class="row">
									<div class="col-sm-3"><strong>Current Bid</strong></div>
									<div class="col-sm-6">#DollarFormat(Session.getSelectedAuction.Current_Bid)#</div>
									<div class="col-sm-3"><input type="text" name="UserBid" id="UserBid"></div>
								</div>
								<div class="row">
									<div class="col-sm-3"><strong>Highest Bidder</strong></div>
									<div class="col-sm-6">
										<cfif Session.getSelectedAuctionCurrentBid.RecordCount>
											#Session.getSelectedAuctionCurrentBid.Fname# #Session.getSelectedAuctionCurrentBid.Lname#
										</cfif>
									</div>
									<div class="col-sm-3"></div>
								</div>
							</div>
						</cfcase>
						<cfcase value="Fixed">
							<input type="hidden" name="UserBid" id="UserBid" Value="#Session.getSelectedAuction.Starting_Price#">
							<div class="container-fluid">
								<div class="row">
									<div class="col-sm-3"><strong>Fixed Bid Amount</strong></div>
									<div class="col-sm-6">#DollarFormat(Session.getSelectedAuction.Starting_Price)#</div>
									<div class="col-sm-3"></div>
								</div>
							</div>
						</cfcase>
					</cfswitch>
				</cfif>
			</div>
			<div class="panel-footer">
				<a href="#buildURL('public:main.default')#" class="btn btn-primary pull-left">Aucton Listing</a>
				<cfif DateDiff("d", Now(), Session.getSelectedAuction.Auction_StartDate) LTE 0>
					<cfswitch expression="#Session.getSelectedAuction.Auction_Type#">
						<cfcase value="Fixed">
							<input type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Buy Now">
						</cfcase>
						<cfcase value="Auction">
							<input type="Submit" name="CreateUserAccount" class="btn btn-primary pull-right" value="Bid on Item">
						</cfcase>
					</cfswitch>
					<br /><br />
				<cfelse>
					<br /><br />
				</cfif>
			</div>
		</cfform>
	</div>

</cfoutput>