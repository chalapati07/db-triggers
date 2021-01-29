USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[tbd_somast]    Script Date: 1/29/2021 12:59:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--The only time a delete should be allowed is if the record being deleted is: SOTYPE = 'R' AND SOSTAT = 'V'

CREATE    TRIGGER [dbo].[tbd_somast] ON [dbo].[SOMAST]
FOR DELETE AS 
Begin
	SET NOCOUNT ON

	DECLARE @somkey INT
	DECLARE @sotype CHAR (1)
	DECLARE @sostat CHAR(1)

	SET @somkey = (SELECT DISTINCT somkey FROM [DELETED])
	SET @sostat = (SELECT DISTINCT sostat FROM [DELETED] where somkey = @somkey)
	SET @sotype = (SELECT DISTINCT sotype FROM [DELETED] where somkey = @somkey)

	BEGIN
		IF @sostat <> 'V' or @sotype not in ('R','A')
			BEGIN
			 RAISERROR ('You cannot delete this order.',16, 1)
			ROLLBACK TRANSACTION
			END
		ELSE
			BEGIN
				RETURN
			END
	END
	
	
	-- JDP 2018-03-21: insert into the DeleteLog
	INSERT INTO [dbo].[DeleteLog]
		   ([TableName]
		   ,[TableId]
		   ,[DeletedDate])
	SELECT 
		  'Somast',
		  d.Somkey,
		  GETDATE()
	FROM deleted d

	SET NOCOUNT OFF
END

GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [tbd_somast]
GO


