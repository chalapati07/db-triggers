USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBIU_Somast_QuoteFix]    Script Date: 1/29/2021 1:00:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [dbo].[TBIU_Somast_QuoteFix]
	ON [dbo].[SOMAST]
	After INSERT, UPDATE
AS
BEGIN		
	set nocount on
	-- This trigger was introduced because there were records in somast
	-- where the sotype is not Q but the pmeth is a Q.
	-- Because of this data error, it is causing the PrintMate application to error.
	-- This code will identify and fix orders with this problem.

	insert into Errors 
	(Error, Message, Line, Method, PrgChain, Mem_Stat, TimeStamp, Login) 
	select 
		100, 
		'Sostat not set to Quote', 
		1, 
		'Somast Trigger', 
		'Trigger detected an error in somkey ' + convert(varchar, somkey) + ' that the Somast.sotype was not set to Q when the pmeth was set to Q.', 
		'', 
		getdate(), 
		'Unknown'
	from inserted
	where pmeth = 'Q' and isnull(sotype, '') <> 'Q'

	if exists(select 1 from inserted
		where isnull(pmeth, '') = 'Q'
			and isnull(sotype, '') <> 'Q')
	begin
		update somast
		set sotype = 'Q'
		where somkey in (select somkey 
			from inserted
			where isnull(pmeth, '') = 'Q'
				and isnull(sotype, '') <> 'Q')
	end
	
	
	if update(sotype)
	begin 
		update sotran set sotype = '' from sotran,deleted where sotran.somkey = deleted.somkey
		and deleted.sotype = 'Q' and sotran.sotype = 'Q'
	end

	set nocount off

END

GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBIU_Somast_QuoteFix]
GO


