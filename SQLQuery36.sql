USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBU_SOMAST_SHIPMENTLOG]    Script Date: 1/29/2021 1:02:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Object:  Trigger [dbo].[TBU_SOMAST_SHIPMENTLOG]   ******/
CREATE TRIGGER [dbo].[TBU_SOMAST_SHIPMENTLOG] ON [dbo].[SOMAST]
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON

	IF UPDATE ([ARCKEY])
	BEGIN		
		update ShipmentLog
		set CustomerId = I.arckey
		from Inserted I, Deleted D
		where I.somkey = ShipmentLog.OrderId
		and I.arckey <> ShipmentLog.CustomerId
	END
	
	IF UPDATE ([CTCKEY])
	BEGIN
		
		update ShipmentLog
		set OrderByContactId = I.CTCKEY
		from Inserted I, Deleted D
		where I.somkey = ShipmentLog.OrderId
		and I.CTCKEY <> ShipmentLog.OrderByContactId
	END	
	SET NOCOUNT OFF
END
GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBU_SOMAST_SHIPMENTLOG]
GO


