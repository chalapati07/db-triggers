USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBU_SOMAST_CenveoOrderUpdate]    Script Date: 1/29/2021 1:02:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE Trigger [dbo].[TBU_SOMAST_CenveoOrderUpdate] ON [dbo].[SOMAST]
FOR UPDATE AS
BEGIN

	SET NOCOUNT ON
	
	if
		update (pmeth) or
		update (authcode) or
		update (rush) or
		update (sostat) or
		update (sotype) or
		update (ORDATE) or
		update (ponum) or
		update (pterms) or
		update (shipvia) or 
		update (arckey) --or
		--update (SIGNATURE)
	Begin
	
		--if object_id ('Tempdb..##Del1') is not null drop table ##Del1
		--if object_id ('Tempdb..##Ins1') is not null drop table ##Ins1
		--select * into ##Del1 from deleted
		--select * into ##Ins1 from deleted
	
		delete PS
		from Smartbatch2PreventSend PS 
		join inserted I
		on PS.somkey = I.somkey
		join deleted D
		on D.SOMKEY = I.SOMKEY
		where (
			 isnull(D.pmeth,'') <> isnull(I.pmeth,'') 
			or isnull(D.authcode,'') <> isnull(I.authcode,'')
			or isnull(D.rush,0) <> isnull(I.rush,0)
			or isnull(D.sostat,'') <> isnull(I.sostat,'')
			or isnull(D.ORDATE,'') <> isnull(I.ORDATE,'')
			or isnull(D.ponum,'') <> isnull(I.ponum,'')
			or isnull(D.pterms,'') <> isnull(I.pterms,'')
			or isnull(D.shipvia,'') <> isnull(I.shipvia,'')
			or isnull(D.arckey, '') <> isnull(I.arckey,'')
			--or (
			--		rtrim(isnull(D.SIGNATURE,''))<> '' 
			--		and  
			--		rtrim(isnull(I.SIGNATURE,'')) = ''
			--	)
		)

	END

	if update(soprtdte)
	begin
		delete PS
		from Smartbatch2PreventSend PS 
		join inserted I
		on PS.somkey = I.somkey
		join deleted D
		on D.SOMKEY = I.SOMKEY
		where
			I.SOPRTDTE is null
			and D.SOPRTDTE is not null
	end
	SET NOCOUNT OFF

END
GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBU_SOMAST_CenveoOrderUpdate]
GO


