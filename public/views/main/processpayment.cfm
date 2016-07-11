<cfoutput>
	<div class="panel panel-default">
		<div class="panel-heading"><h1>Auction Payment Processing</h1></div>
		<div class="panel-body">
			<div class="container-fluid">
				<div class="row">
					<div class="col-sm-3"><cfif Session.AuctionWon.getSelectedAuctionPhotos.RecordCount>
						<cfset NumPhotos = #Session.AuctionWon.getSelectedAuctionPhotos.RecordCount#>
						<cfset PhotoDir = "/plugins/" &#HTMLEditFormat(rc.pc.getPackage())# & "/includes/assets/photos/" & #Session.AuctionWon.getAuction.TContent_ID# & "/">
						<cfswitch expression="#Variables.NumPhotos#">
							<cfcase value="1">
								<img src="#Variables.PhotoDir#/#Session.AuctionWon.getSelectedAuctionPhotos.Filename[1]#" width="250" height="150" alt="Auction Item Photo" data-toggle="lightbox">
							</cfcase>
							<cfcase value="2">
								<img src="#Variables.PhotoDir#/#Session.AuctionWon.getSelectedAuctionPhotos.Filename[1]#" id="AuctionImage1" width="250" height="150" alt="Auction Item Photo"></a>
								<img src="#Variables.PhotoDir#/#Session.AuctionWon.getSelectedAuctionPhotos.Filename[2]#" id="AuctionImage2" width="75" height="75" alt="Auction Item Photo"></a>
							</cfcase>
							<cfcase value="3">
								<img src="#Variables.PhotoDir#/#Session.AuctionWon.getSelectedAuctionPhotos.Filename[1]#" width="250" height="150" alt="Auction Item Photo" data-toggle="lightbox">
								<img src="#Variables.PhotoDir#/#Session.AuctionWon.getSelectedAuctionPhotos.Filename[2]#" width="75" height="75" alt="Auction Item Photo" data-toggle="lightbox">
								<img src="#Variables.PhotoDir#/#Session.AuctionWon.getSelectedAuctionPhotos.Filename[3]#" width="75" height="75" alt="Auction Item Photo" data-toggle="lightbox">
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
							<div class="col-sm-6">#Session.AuctionWon.getAuction.Item_ModelNumber#</div>
						</div>
						<div class="row">
							<div class="col-sm-3"><strong>Description</strong></div>
							<div class="col-sm-6">#Session.AuctionWon.getAuction.Item_Description#</div>
						</div>
						<div class="row">
							<div class="col-sm-9">&nbsp;</div>
						</div>
						<cfif Len(Session.AuctionWon.getAuction.Item_UPC)>
							<div class="row"><div class="col-sm-12">&nbsp</div></div>
							<div class="row">
								<div class="col-sm-3"><strong>UPC BarCode</strong></div>
								<div class="col-sm-6">#Session.AuctionWon.getAuction.Item_UPC#</div>
							</div>
						</cfif>
						<div class="row">
							<div class="col-sm-3"><strong>Condition</strong></div>
							<div class="col-sm-6">#Session.AuctionWon.getAuction.Item_Condition#</div>
						</div>
						<div class="row">
							<div class="col-sm-3"><strong>Category</strong></div>
							<div class="col-sm-6">#Session.AuctionWon.getAuction.Category_Name#</div>
						</div>
						<cfif Len(Session.AuctionWon.getAuction.Item_YearsInService)>
							<div class="row">
								<div class="col-sm-3"><strong>Years In Service</strong></div>
								<div class="col-sm-6">#Session.AuctionWon.getAuction.Item_YearsInService#</div>
							</div>
						</cfif>
						<cfif Len(Session.AuctionWon.getAuction.Item_InfoWebsite)>
							<div class="row">
								<div class="col-sm-3"><strong>Item Info Website</strong></div>
								<div class="col-sm-6">#Session.AuctionWon.getAuction.Item_InfoWebsite#</div>
							</div>
						</cfif>
						<cfif Len(Session.AuctionWon.getAuction.AssetTag_Number)>
							<div class="row">
								<div class="col-sm-3"><strong>Asset Tag Number</strong></div>
								<div class="col-sm-6">#Session.AuctionWon.getAuction.AssetTag_Number#</div>
							</div>
						</cfif>

						<div class="row">
							<div class="col-sm-3"><strong>
								<cfif DateDiff("d", Now(), Session.AuctionWon.getAuction.Auction_StartDate) GTE 1>
									Auction Starts
								<cfelse>
									Auction Started
								</cfif>
								</strong></div>
							<div class="col-sm-6">#DateFormat(Session.AuctionWon.getAuction.Auction_StartDate, "dddd, mmm dd, yyyy")#</div>
						</div>
						<div class="row">
							<div class="col-sm-3"><strong>Auction Ends</strong></div>
							<div class="col-sm-6">#DateFormat(Session.AuctionWon.getAuction.Auction_EndDate, "dddd, mmm dd, yyyy")#</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="panel-heading"><h1>Item Location Information</h1></div>
		<div class="panel-body">
			<div class="row">
				<div class="col-sm-3"><strong>Location</strong></div>
				<div class="col-sm-6">#Session.AuctionWon.getOrganization.BusinessName#<br>#Session.AuctionWon.getOrganization.PhysicalAddress#<br>#Session.AuctionWon.getOrganization.PhysicalCity#, #Session.AuctionWon.getOrganization.PhysicalState# #Session.AuctionWon.getOrganization.PhysicalZipCode#</div>
				<div class="col-sm-3">Map Goes Here</div>
			</div>
		</div>
		<div class="panel-heading"><h1>Payment Information</h1></div>
		<div class="panel-body">
			<cfif Session.SiteSettings.ProcessPayments_Stripe EQ 1>
				<div class="alert alert-warning">
					Payments are processed through a Third Party Payment Processing Company called Stripe. This website does not store any information regarding this transaction on our servers.
				</div>
				<cfif Session.SiteSettings.Stripe_TestMode EQ 1>
					<cfset Session.Stripe = createObject("component", "plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/stripe").init(stripeApiKey="#Session.SiteSettings.Stripe_TestAPIKey#")>
				<cfelseif Session.SiteSettings.Stripe_TestMode EQ 0>
					<cfset Session.Stripe = createObject("component", "plugins/#HTMLEditFormat(rc.pc.getPackage())#/library/components/stripe").init(stripeApiKey="#Session.SiteSettings.Stripe_LiveAPIKey#")>
				</cfif>
				<cfform action="" method="post" id="payment-form" class="form-horizontal">
					<cfinput type="hidden" name="SiteID" value="#rc.$.siteConfig('siteID')#">
					<cfinput type="hidden" name="AuctionID" value="#Session.AuctionWon.getAuction.TContent_ID#">
					<cfinput type="hidden" name="AuctionAmount" value="#Session.AuctionWon.getAuction.TContent_ID#">
					<cfinput type="hidden" name="formSubmit" value="true">
					<div class="form-group">
						<div class="col-sm-12"><label for="FormHeading" class="control-label">Credit Card Information</label></div>
					</div>
					<div class="form-group">
						<label for="CCNumber" class="control-label col-sm-3">Card Number:</label>
						<div class="col-sm-6"><cfinput type="text" name="number" /></div>
					</div>
					<div class="form-group">
						<label for="CVCNumber" class="control-label col-sm-3">Card CVC:</label>
						<div class="col-sm-6"><cfinput type="text" name="cvc" /></div>
					</div>
					<div class="form-group">
						<label for="ExpMonth" class="control-label col-sm-3">Expire Month:</label>
						<div class="col-sm-6"><cfinput type="text" name="expmonth" /></div>
					</div>
					<div class="form-group">
						<label for="ExpYear" class="control-label col-sm-3">Expire Year:</label>
						<div class="col-sm-6"><cfinput type="text" name="expyear" /></div>
					</div>
					<div class="form-group">
						<div class="col-sm-4">
							<button type="submit" class="btn btn-primary">Submit Payment</button>
						</div>
					</div>
				</cfform>
			<cfelse>
				<div class="alert alert-danger">
					This website has not been configured to accept any payments through the allowed third party payment processing companies. Please contact the administrator of this website so they can make the necessary changes to allow processing of payments.
				</div>
			</cfif>
		</div>
	</div>
</cfoutput>