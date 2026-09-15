-- ============================================================
-- BASELINE: dbo.tb_spe_stg_lost
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_stg_lost]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_stg_lost](
	[OrderID] [varchar](50) NULL,
	[SLS_Tracking_Number] [varchar](255) NULL,
	[Shopee_Order_SN] [varchar](255) NULL,
	[Longitude] [varchar](255) NULL,
	[Latitude] [varchar](255) NULL,
	[Sort_Code_Name] [varchar](255) NULL,
	[Zipcode_Name] [varchar](20) NULL,
	[Buyer_Name] [varchar](255) NULL,
	[Buyer_Phone] [varchar](20) NULL,
	[Buyer_Address] [varchar](255) NULL,
	[Location_Type] [varchar](255) NULL,
	[Postal_Code] [varchar](255) NULL,
	[Driver_ID] [varchar](50) NOT NULL,
	[Driver_Name] [varchar](255) NULL,
	[Driver_Phone] [varchar](20) NULL,
	[Received_Time] [varchar](20) NULL,
	[Current_Station_Received_Time] [varchar](20) NULL,
	[Delivering_Time] [varchar](20) NULL,
	[Delivered_Time] [varchar](20) NULL,
	[OnHold_Time] [varchar](20) NULL,
	[OnHoldReason] [varchar](255) NULL,
	[Reschedule_Date] [varchar](20) NULL,
	[Status] [varchar](255) NULL,
	[Reject_remark] [varchar](255) NULL,
	[COD_Amount] [varchar](255) NULL,
	[Manifest_Number] [varchar](255) NULL,
	[Order_Account] [varchar](255) NULL,
	[Original_ASF] [varchar](255) NULL,
	[Rounding_ASF] [varchar](255) NULL,
	[Total_of_On_Hold_Times] [varchar](20) NULL,
	[Reschedule_Time] [varchar](20) NULL,
	[Delivery_Attempts] [varchar](255) NULL,
	[Bulky_Type] [varchar](255) NULL,
	[SLA_Target_Date] [varchar](20) NULL,
	[Time_to_SLA] [varchar](20) NULL,
	[Payment_Method] [varchar](255) NULL,
	[Current_Station] [varchar](255) NULL,
	[Return_Destination] [varchar](255) NULL,
	[Shop_ID] [varchar](50) NOT NULL,
	[Shop_Category] [varchar](255) NULL,
	[Inbound_3PL] [varchar](255) NULL,
	[Outbound_3PL] [varchar](255) NULL,
	[Channel] [varchar](255) NULL,
	[3PL_TN] [varchar](255) NULL,
	[Calculation_Status] [varchar](255) NULL,
	[Zone_ID] [varchar](50) NOT NULL,
	[Zone] [varchar](255) NULL,
	[Destination_Station] [varchar](255) NULL,
	[Next_Station] [varchar](255) NULL,
	[Pickup_Station] [varchar](255) NULL,
	[Driver_Contract_Type] [varchar](255) NULL,
	[Pick_Up_Time] [varchar](20) NULL,
	[Collected_Time] [varchar](20) NULL,
	[Transported_to_sp_time] [varchar](20) NULL,
	[SLA_Tag] [varchar](255) NULL,
	[High_Value] [varchar](255) NULL
) ON [PRIMARY]
GO
