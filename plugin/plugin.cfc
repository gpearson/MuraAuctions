/*

This file is part of MuraFW1

Copyright 2010-2015 Stephen J. Withington, Jr.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
component persistent="false" accessors="true" output="false" extends="mura.plugin.plugincfc" {

	property name="config" type="any" default="";

	public any function init(any config='') {
		setConfig(arguments.config);
	}

	public void function install() {
		// triggered by the pluginManager when the plugin is INSTALLED.
		application.appInitialized = false;

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Bids'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Bids` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Auction_ID` int(11) NOT NULL, `User_ID` varchar(30) NOT NULL, `Bid_Amount` double(15,2) NOT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Bids");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Bids` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Auction_ID` int(11) NOT NULL, `User_ID` varchar(30) NOT NULL, `Bid_Amount` double(15,2) NOT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Items'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Items` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Item_Title` varchar(64) DEFAULT NULL, `Organization_ID` int(11) NOT NULL, `Location_ID` int(128) DEFAULT NULL, `Site_ID` tinytext NOT NULL, `Item_ModelNumber` tinytext NOT NULL, `Item_Description` tinytext NOT NULL, `Item_Condition` bit(1) NOT NULL, `Item_UPC` tinytext, `Item_WebDirectory` tinytext NOT NULL, `Item_PrimaryPhoto` tinytext NOT NULL, `Item_SecondaryPhoto` tinytext, `Item_TertiaryPhoto` tinytext, `Auction_StartDate` datetime NOT NULL, `Auction_EndDate` datetime NOT NULL, `Auction_Category` int(11) NOT NULL, `Auction_Type` varchar(7) NOT NULL, `Starting_Price` double(15,2) DEFAULT NULL, `Current_Bid` double(15,2) DEFAULT NULL, `HighestBid_UserID` tinytext, `dateCreated` datetime NOT NULL, `lastUpdated` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, `lastUpdateBy` tinytext NOT NULL, `lastUpdateByID` tinytext NOT NULL, `Active` bit(1) NOT NULL, `bid_increment` float DEFAULT NULL, `minimum_bid` float DEFAULT NULL, `default_closing_time` datetime DEFAULT NULL, `default_opening_time` datetime DEFAULT NULL, `timezone` varchar(64) DEFAULT NULL, `send_email_notifications` tinyint(1) DEFAULT NULL, `send_outbid_notifications_to_admin` tinyint(1) DEFAULT NULL, `winner_instructions` text, `reverse_auction` tinyint(1) unsigned NOT NULL DEFAULT '0', `custom_header` text, `custom_footer` text, `custom_css` text, PRIMARY KEY (`TContent_ID`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Items");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Items` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Item_Title` varchar(64) DEFAULT NULL, `Organization_ID` int(11) NOT NULL, `Location_ID` int(128) DEFAULT NULL, `Site_ID` tinytext NOT NULL, `Item_ModelNumber` tinytext NOT NULL, `Item_Description` tinytext NOT NULL, `Item_Condition` bit(1) NOT NULL, `Item_UPC` tinytext, `Item_WebDirectory` tinytext NOT NULL, `Item_PrimaryPhoto` tinytext NOT NULL, `Item_SecondaryPhoto` tinytext, `Item_TertiaryPhoto` tinytext, `Auction_StartDate` datetime NOT NULL, `Auction_EndDate` datetime NOT NULL, `Auction_Category` int(11) NOT NULL, `Auction_Type` varchar(7) NOT NULL, `Starting_Price` double(15,2) DEFAULT NULL, `Current_Bid` double(15,2) DEFAULT NULL, `HighestBid_UserID` tinytext, `dateCreated` datetime NOT NULL, `lastUpdated` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, `lastUpdateBy` tinytext NOT NULL, `lastUpdateByID` tinytext NOT NULL, `Active` bit(1) NOT NULL, `bid_increment` float DEFAULT NULL, `minimum_bid` float DEFAULT NULL, `default_closing_time` datetime DEFAULT NULL, `default_opening_time` datetime DEFAULT NULL, `timezone` varchar(64) DEFAULT NULL, `send_email_notifications` tinyint(1) DEFAULT NULL, `send_outbid_notifications_to_admin` tinyint(1) DEFAULT NULL, `winner_instructions` text, `reverse_auction` tinyint(1) unsigned NOT NULL DEFAULT '0', `custom_header` text, `custom_footer` text, `custom_css` text, PRIMARY KEY (`TContent_ID`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Organization_Locations'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Organization_Locations` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Organization_ID` int(11) NOT NULL, `Site_ID` varchar(20) NOT NULL DEFAULT '', `LocationName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `PrimaryVoiceNumber` varchar(14) DEFAULT '', `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` bit(1) NOT NULL DEFAULT b'1', `CountyName` tinytext, `CountyNumber` tinytext, PRIMARY KEY (`TContent_ID`,`Organization_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Organization_Locations");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Organization_Locations` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Organization_ID` int(11) NOT NULL, `Site_ID` varchar(20) NOT NULL DEFAULT '', `LocationName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `PrimaryVoiceNumber` varchar(14) DEFAULT '', `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` bit(1) NOT NULL DEFAULT b'1', `CountyName` tinytext, `CountyNumber` tinytext, PRIMARY KEY (`TContent_ID`,`Organization_ID`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Organizations'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Organizations` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `BusinessName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `MailingAddress` tinytext, `MailingCity` tinytext, `MailingState` tinytext, `MailingZipCode` tinytext, `MailingZip4` tinytext, `PrimaryVoiceNumber` varchar(14) DEFAULT '', `BusinessWebsite` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` bit(1) NOT NULL DEFAULT b'1', `CountyName` tinytext, `CountyNumber` tinytext, `BusinessFax` tinytext, `Federal_EIN` tinytext, PRIMARY KEY (`TContent_ID`,`Site_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Organizations");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Organizations` ( `TContent_ID` int(10) NOT NULL AUTO_INCREMENT, `Site_ID` varchar(20) NOT NULL DEFAULT '', `BusinessName` tinytext NOT NULL, `PhysicalAddress` tinytext NOT NULL, `PhysicalCity` tinytext NOT NULL, `PhysicalState` varchar(2) NOT NULL DEFAULT '', `PhysicalZipCode` varchar(5) NOT NULL DEFAULT '', `PhysicalZip4` varchar(4) DEFAULT '', `MailingAddress` tinytext, `MailingCity` tinytext, `MailingState` tinytext, `MailingZipCode` tinytext, `MailingZip4` tinytext, `PrimaryVoiceNumber` varchar(14) DEFAULT '', `BusinessWebsite` tinytext, `dateCreated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdated` datetime NOT NULL DEFAULT '1980-01-01 01:00:00', `lastUpdateBy` varchar(50) NOT NULL DEFAULT '', `isAddressVerified` char(1) NOT NULL DEFAULT '0', `FIPS_StateCode` char(2) DEFAULT NULL, `GeoCode_Latitude` varchar(20) DEFAULT NULL, `GeoCode_Longitude` varchar(20) DEFAULT NULL, `GeoCode_Township` varchar(40) DEFAULT NULL, `GeoCode_StateLongName` varchar(40) DEFAULT NULL, `GeoCode_CountryShortName` varchar(40) DEFAULT NULL, `GeoCode_CountyName` tinytext, `GeoCode_CountyNumber` char(5) DEFAULT NULL, `GeoCode_Neighborhood` varchar(40) DEFAULT NULL, `USPS_CarrierRoute` varchar(20) DEFAULT NULL, `USPS_CheckDigit` varchar(20) DEFAULT NULL, `USPS_DeliveryPoint` varchar(20) DEFAULT NULL, `PhysicalLocationCountry` varchar(20) DEFAULT NULL, `PhysicalCountry` varchar(20) DEFAULT NULL, `Active` bit(1) NOT NULL DEFAULT b'1', `CountyName` tinytext, `CountyNumber` tinytext, `BusinessFax` tinytext, `Federal_EIN` tinytext, PRIMARY KEY (`TContent_ID`,`Site_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_ProductCategories'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_ProductCategories` ( `Category_ID` int(11) NOT NULL AUTO_INCREMENT, `Category_Name` varchar(64) NOT NULL DEFAULT '', `DateCreated` datetime DEFAULT NULL, `lastUpdateBy` tinytext, `lastUpdate` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, `isActive` bit(1) DEFAULT NULL, `ParentCategory_ID` int(11) NOT NULL DEFAULT '0', `Site_ID` tinytext, PRIMARY KEY (`Category_ID`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_ProductCategories");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_ProductCategories` ( `Category_ID` int(11) NOT NULL AUTO_INCREMENT, `Category_Name` varchar(64) NOT NULL DEFAULT '', `DateCreated` datetime DEFAULT NULL, `lastUpdateBy` tinytext, `lastUpdate` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP, `isActive` bit(1) DEFAULT NULL, `ParentCategory_ID` int(11) NOT NULL DEFAULT '0', `Site_ID` tinytext, PRIMARY KEY (`Category_ID`) ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}



		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_SiteConfig'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_SiteConfig` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `DateCreated` datetime NOT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, `SellerPercentageFee` decimal(7,3) DEFAULT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_SiteConfig");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_SiteConfig` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `DateCreated` datetime NOT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, `SellerPercentageFee` decimal(7,3) DEFAULT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_UserMatrix'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_UserMatrix` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `User_ID` char(35) NOT NULL, `AccountType` int(11) DEFAULT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, `ZipCode` tinytext, `TelephoneNumber` tinytext, `Organization_ID` int(11) DEFAULT NULL, `ReceivedSellerContract` bit(1) NOT NULL DEFAULT b'0', `ReceivedSellerContractDate` datetime DEFAULT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_UserMatrix");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_UserMatrix` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `User_ID` char(35) NOT NULL, `AccountType` int(11) DEFAULT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, `ZipCode` tinytext, `TelephoneNumber` tinytext, `Organization_ID` int(11) DEFAULT NULL, `ReceivedSellerContract` bit(1) NOT NULL DEFAULT b'0', `ReceivedSellerContractDate` datetime DEFAULT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var NewGroupAuctionAdmin = #application.userManager.read("")#;
		NewGroupAuctionAdmin.setSiteID(Session.SiteID);
		NewGroupAuctionAdmin.setGroupName("Auction Site Admin");
		NewGroupAuctionAdmin.setType(1);
		NewGroupAuctionAdmin.setIsPublic(1);
		NewGroupAuctionAdminStatus = #Application.userManager.create(NewGroupAuctionAdmin)#;


		inserteSiteSettingRows = arrayNew(1);
		inserteSiteSettingRows[1] = "'#Session.SiteID#', #Now()#, '#Session.Mura.Fname# #Session.Mura.LName#', #NOW()#, '0.30'";

		var dbInsertSiteSettingsRecord = new query();
		dbInsertSiteSettingsRecord.setDatasource("#application.configBean.getDatasource()#");
		dbInsertSiteSettingsRecord.setSQL("Insert into p_Auction_SiteConfig (Site_ID, DateCreated, lastUpdateBy, lastUpdated, SellerPercentageFee) Values('#Session.SiteID#', #Now()#, '#Session.Mura.Fname# #Session.Mura.LName#', #NOW()#, '0.30')");
		var dbInsertSiteSettingsRecordResults = dbInsertSiteSettingsRecord.execute();

	}

	public void function update() {
		// triggered by the pluginManager when the plugin is UPDATED.
		application.appInitialized = false;
	}

	public void function delete() {
		// triggered by the pluginManager when the plugin is DELETED.
		application.appInitialized = false;

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_Bids");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_Items");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_Organization_Locations");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_Organizations");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_ProductCategories");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_SiteConfig");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_UserMatrix");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

	}

}