USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBU_SOMAST]    Script Date: 1/29/2021 1:01:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



/****** Object:  Trigger [dbo].[TBU_SOMAST]    Script Date: 05/10/2011 14:40:09 ******/
CREATE Trigger [dbo].[TBU_SOMAST] on [dbo].[SOMAST] FOR UPDATE AS
begin

SET NOCOUNT ON
 
if RTRIM(SUSER_SNAME()) not in ('SfIntegration', 'PhnxSfIntegration') begin
	IF UPDATE(SOTYPE) OR UPDATE(SOSTAT)	BEGIN
					--- IBIS 19604 ADD CHANGES TO TCVTRACKING ------
			----------- Edited On: Apr 3, 2009 ; SOSTAT, SOTYPE & PRICE Fields from SOTRAN table is added -----------
			INSERT INTO [dbo].[TCVTracking]([USER_NAME], [CHANGE_DATE], [DATAFLAG], [SOTKEY], [SOMKEY], [QTYORD], [QTYSHP], [DISC], [PRICE], [SOSTAT], [SOTYPE], [SOTRAN_SOSTAT], [SOTRAN_SOTYPE])
			SELECT Replace(System_User, 'MS\', ''), GETDATE(), 'U', SOT.SOTKEY, SOT.SOMKEY, SOT.QTYORD, SOT.QTYSHP, SOT.DISC, SOT.PRICE, I.SOSTAT, I.SOTYPE, SOT.SOSTAT, SOT.SOTYPE
			FROM [INSERTED] I
					INNER JOIN SOTRAN SOT ON I.SOMKEY = SOT.SOMKEY
	END
end

IF UPDATE(sostat)
	BEGIN
		INSERT INTO bb_log ([user_name], [change_date], [table_name], [column_name], [old_value], [key_value])
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'SOSTAT', d.sostat, d.somkey FROM [DELETED] d inner join inserted i on d.somkey = i.somkey
		WHERE isnull(i.sostat,'') <> isnull(d.sostat,'')
	END		
 
IF UPDATE(edited_by)
	BEGIN
		INSERT INTO bb_log ([user_name], [change_date], [table_name], [column_name], [old_value], [key_value])
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'EDITED_BY', edited_by, somkey FROM [INSERTED]
	END		
 
IF UPDATE(SALESMN)
	BEGIN
		INSERT INTO BB_LOG ([USER_NAME], [CHANGE_DATE], [TABLE_NAME], [COLUMN_NAME], [OLD_VALUE], [KEY_VALUE]) 
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'SALESMN', d.salesmn, d.SOMKEY  FROM [DELETED] d inner join inserted i on d.somkey = i.somkey
		WHERE isnull(i.salesmn,'') <> isnull(d.salesmn,'')
	END
 
IF UPDATE(SOTYPE)
	BEGIN
		INSERT INTO bb_log ([user_name], [change_date], [table_name], [column_name], [old_value], [key_value], [str_key_value])
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'SOTYPE', D.SOTYPE, D.SOMKEY, NULL  FROM DELETED d inner join inserted i on d.somkey = i.somkey
		WHERE isnull(i.sotype,'') <> isnull(d.sotype,'')
END
 
IF UPDATE(PMETH)
	BEGIN
		INSERT INTO bb_log ([user_name], [change_date], [table_name], [column_name], [old_value], [key_value], [str_key_value])
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'PMETH', D.PMETH, D.SOMKEY, NULL  FROM DELETED d inner join inserted i on d.somkey = i.somkey
		WHERE isnull(i.pmeth,'') <> isnull(d.pmeth,'')
	END

IF UPDATE(AUTHCODE)
	BEGIN
		INSERT INTO bb_log ([user_name], [change_date], [table_name], [column_name], [old_value], [key_value], [str_key_value])
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'AUTHCODE', D.AUTHCODE, D.SOMKEY, NULL  FROM DELETED d inner join inserted i on d.somkey = i.somkey
		WHERE isnull(i.authcode,'') <> isnull(d.authcode,'')
	END

IF UPDATE(ShipVia)
	BEGIN
		INSERT INTO bb_log ([user_name], [change_date], [table_name], [column_name], [old_value], [key_value], [str_key_value])
		SELECT Replace(System_User, 'ms\', ''), GETDATE(), 'SOMAST', 'ShipVia', D.ShipVia, D.SOMKEY, NULL  FROM DELETED d inner join inserted i on d.somkey = i.somkey
		WHERE isnull(i.ShipVia,'') <> isnull(d.ShipVia,'')
	END

-- JDP 2018-04-20: Added Modified Date
IF NOT UPDATE(ModifiedDate)
	Begin
		UPDATE dbo.Somast SET ModifiedDate = GetDate()
		FROM dbo.Somast o
		INNER JOIN Inserted i ON o.Somkey = i.Somkey
	End


SET NOCOUNT OFF
END




GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBU_SOMAST]
GO


