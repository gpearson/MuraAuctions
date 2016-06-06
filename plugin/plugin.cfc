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
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Bids` ( `bid_id` int(11) NOT NULL AUTO_INCREMENT, `product_id` int(11) NOT NULL DEFAULT '0', `username` varchar(32) NOT NULL DEFAULT '', `time_of_bid` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `bid_amount` float NOT NULL DEFAULT '0', `bid_status` enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING', PRIMARY KEY (`bid_id`), KEY `product_id` (`product_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
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
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Bids` ( `bid_id` int(11) NOT NULL AUTO_INCREMENT, `product_id` int(11) NOT NULL DEFAULT '0', `username` varchar(32) NOT NULL DEFAULT '', `time_of_bid` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `bid_amount` float NOT NULL DEFAULT '0', `bid_status` enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING', PRIMARY KEY (`bid_id`), KEY `product_id` (`product_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Closed'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Closed` ( `product_id` int(11) NOT NULL DEFAULT '0', `winner` varchar(32) NOT NULL DEFAULT '', `bid_amount` float NOT NULL DEFAULT '0', `email_sent` tinyint(1) NOT NULL DEFAULT '0', `admin_email_sent` tinyint(4) NOT NULL DEFAULT '0', `close_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`product_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Closed");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Closed` ( `product_id` int(11) NOT NULL DEFAULT '0', `winner` varchar(32) NOT NULL DEFAULT '', `bid_amount` float NOT NULL DEFAULT '0', `email_sent` tinyint(1) NOT NULL DEFAULT '0', `admin_email_sent` tinyint(4) NOT NULL DEFAULT '0', `close_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, PRIMARY KEY (`product_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Config'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Config` ( `auction_id` int(11) NOT NULL AUTO_INCREMENT, `title` varchar(64) DEFAULT NULL, `admin_email` varchar(128) DEFAULT NULL, `notification_from_address` varchar(128) DEFAULT NULL, `closing_time` datetime DEFAULT NULL, `bid_increment` float DEFAULT NULL, `minimum_bid` float DEFAULT NULL, `default_closing_time` datetime DEFAULT NULL, `default_opening_time` datetime DEFAULT NULL, `timezone` varchar(64) DEFAULT NULL, `send_email_notifications` tinyint(1) DEFAULT NULL, `send_outbid_notifications_to_admin` tinyint(1) DEFAULT NULL, `winner_instructions` text, `reverse_auction` tinyint(1) unsigned NOT NULL DEFAULT '0', `custom_header` text, `custom_footer` text, `custom_css` text, PRIMARY KEY (`auction_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Config");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Config` ( `auction_id` int(11) NOT NULL AUTO_INCREMENT, `title` varchar(64) DEFAULT NULL, `admin_email` varchar(128) DEFAULT NULL, `notification_from_address` varchar(128) DEFAULT NULL, `closing_time` datetime DEFAULT NULL, `bid_increment` float DEFAULT NULL, `minimum_bid` float DEFAULT NULL, `default_closing_time` datetime DEFAULT NULL, `default_opening_time` datetime DEFAULT NULL, `timezone` varchar(64) DEFAULT NULL, `send_email_notifications` tinyint(1) DEFAULT NULL, `send_outbid_notifications_to_admin` tinyint(1) DEFAULT NULL, `winner_instructions` text, `reverse_auction` tinyint(1) unsigned NOT NULL DEFAULT '0', `custom_header` text, `custom_footer` text, `custom_css` text, PRIMARY KEY (`auction_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
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
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_ProductCategories` ( `category_id` int(11) NOT NULL AUTO_INCREMENT, `category_name` varchar(64) NOT NULL DEFAULT '', PRIMARY KEY (`category_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
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
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_ProductCategories` ( `category_id` int(11) NOT NULL AUTO_INCREMENT, `category_name` varchar(64) NOT NULL DEFAULT '', PRIMARY KEY (`category_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
				var dbCreateTableResults = dbCreateTable.execute();
			} else {
				 writedump(dbDropTableResults.getResult());
				 abort;
			}
		}

		var dbCheckTables = new query();
		dbCheckTables.setDatasource("#application.configBean.getDatasource()#");
		dbCheckTables.setSQL("Show Tables LIKE 'p_Auction_Products'");
		var dbCheckTablesResults = dbCheckTables.execute();

		if (dbCheckTablesResults.getResult().recordcount eq 0) {
			// Since the Database Table does not exists, Lets Create it
			var dbCreateTable = new query();
			dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_Products` ( `product_id` int(11) NOT NULL AUTO_INCREMENT, `product_name` varchar(64) NOT NULL DEFAULT '', `product_description` text, `product_image` varchar(128) DEFAULT NULL, `product_image_mimetype` varchar(128) DEFAULT NULL, `product_categories` varchar(32) DEFAULT NULL, `seller_username` varchar(32) NOT NULL DEFAULT '', `minimum_bid` float DEFAULT NULL, `bid_increment` float NOT NULL DEFAULT '5', `opening_time` datetime DEFAULT NULL, `closing_time` datetime DEFAULT NULL, `created_date` datetime DEFAULT NULL, `modified_date` datetime DEFAULT NULL, `entered_by` varchar(32) DEFAULT NULL, PRIMARY KEY (`product_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
			var dbCreateTableResults = dbCreateTable.execute();
		} else {
			// Database Table Exists, We must Drop it to create it again
			var dbDropTable = new query();
			dbDropTable.setDatasource("#application.configBean.getDatasource()#");
			dbDropTable.setSQL("DROP TABLE p_Auction_Products");
			var dbDropTableResults = dbDropTable.execute();

			if (len(dbDropTableResults.getResult()) eq 0) {
				var dbCreateTable = new query();
				dbCreateTable.setDatasource("#application.configBean.getDatasource()#");
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_Products` ( `product_id` int(11) NOT NULL AUTO_INCREMENT, `product_name` varchar(64) NOT NULL DEFAULT '', `product_description` text, `product_image` varchar(128) DEFAULT NULL, `product_image_mimetype` varchar(128) DEFAULT NULL, `product_categories` varchar(32) DEFAULT NULL, `seller_username` varchar(32) NOT NULL DEFAULT '', `minimum_bid` float DEFAULT NULL, `bid_increment` float NOT NULL DEFAULT '5', `opening_time` datetime DEFAULT NULL, `closing_time` datetime DEFAULT NULL, `created_date` datetime DEFAULT NULL, `modified_date` datetime DEFAULT NULL, `entered_by` varchar(32) DEFAULT NULL, PRIMARY KEY (`product_id`) ) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
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
			dbCreateTable.setSQL("CREATE TABLE `p_Auction_UserMatrix` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `User_ID` char(35) NOT NULL, `AccountType` int(11) NOT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, `ZipCode` tinytext, `TelephoneNumber` tinytext, `Organization_ID` int(11) DEFAULT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;");
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
				dbCreateTable.setSQL("CREATE TABLE `p_Auction_UserMatrix` ( `TContent_ID` int(11) NOT NULL AUTO_INCREMENT, `Site_ID` tinytext NOT NULL, `User_ID` char(35) NOT NULL, `AccountType` int(11) NOT NULL, `lastUpdateBy` varchar(35) NOT NULL, `lastUpdated` datetime NOT NULL, `ZipCode` tinytext, `TelephoneNumber` tinytext, `Organization_ID` int(11) DEFAULT NULL, PRIMARY KEY (`TContent_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;");
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
		dbDropTable.setSQL("DROP TABLE p_Auction_Closed");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}

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
		dbDropTable.setSQL("DROP TABLE p_Auction_Config");
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
		dbDropTable.setSQL("DROP TABLE p_Auction_Products");
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

		var dbDropTable = new query();
		dbDropTable.setDatasource("#application.configBean.getDatasource()#");
		dbDropTable.setSQL("DROP TABLE p_Auction_Organizations");
		var dbDropTableResults = dbDropTable.execute();

		if (len(dbDropTableResults.getResult()) neq 0) {
			writedump(dbDropTableResults.getResult());
			abort;
		}
	}

}