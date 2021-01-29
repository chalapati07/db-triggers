USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBAI_Somast_NewSourceCode]    Script Date: 1/29/2021 12:58:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TBAI_Somast_NewSourceCode]
ON  [dbo].[SOMAST]
AFTER INSERT
AS 
BEGIN
      SET NOCOUNT ON;
      IF EXISTS (SELECT [SONO] FROM INSERTED WHERE [SONO] IS NOT NULL)
      BEGIN
            UPDATE [dbo].[SOMAST] SET [NewSourceCode] = 'WEBI' WHERE SOMKEY in (SELECT SOMKEY FROM INSERTED)
      END
      
      
      -- JDP 2018-03-21
      UPDATE  dbo.Somast SET 
		  CreatedDate = GetDate() 
		  --,ModifiedDate = GETDATE()
	  FROM dbo.Somast o
	  INNER JOIN Inserted i ON o.Somkey = i.Somkey

      SET NOCOUNT OFF;
END

GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBAI_Somast_NewSourceCode]
GO


