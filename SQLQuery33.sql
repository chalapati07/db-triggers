USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBIU_SOMAST_Synchronize]    Script Date: 1/29/2021 1:01:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



/****** Object:  Trigger [dbo].[TBIU_SOMAST_Synchronize]    Script Date: 04/29/2010 11:19:24 ******/
CREATE Trigger [dbo].[TBIU_SOMAST_Synchronize] ON [dbo].[SOMAST]
FOR INSERT, UPDATE AS
BEGIN

	SET NOCOUNT ON
	  
	IF UPDATE(ponum) 
	BEGIN 
		insert into Synchronize (TableName, FieldName, PrimaryKey, OldValue, NewValue, ExternalSystem, InsertDate)
		select 'SalesOrder', 'PurchaseOrder', i.somkey, isnull(d.ponum, ''), isnull(i.ponum, ''), 'Accounting', getdate()
		from [inserted] i left join
			[deleted] d on d.somkey = i.somkey
		where isnull(d.ponum, '') <> isnull(i.ponum, '') and isnull(d.sostat, '') = 'C'
	END
	
	IF UPDATE(pmeth) 
	BEGIN 
		insert into Synchronize (TableName, FieldName, PrimaryKey, OldValue, NewValue, ExternalSystem, InsertDate)
		select 'SalesOrder', 'PaymentMethod', i.somkey, isnull(d.pmeth, ''), isnull(i.pmeth, ''), 'Accounting', getdate()
		from [inserted] i left join
			[deleted] d on d.somkey = i.somkey
		where isnull(d.pmeth, '') <> isnull(i.pmeth, '') and isnull(d.sostat, '') = 'C'
	END		
	
	IF UPDATE(pterms) 
	BEGIN 
		insert into Synchronize (TableName, FieldName, PrimaryKey, OldValue, NewValue, ExternalSystem, InsertDate)
		select 'SalesOrder', 'CreditCard', i.somkey, isnull(d.pterms, ''), isnull(i.pterms, ''), 'Accounting', getdate()
		from [inserted] i left join
			[deleted] d on d.somkey = i.somkey
		where isnull(d.pterms, '') <> isnull(i.pterms, '') and isnull(d.sostat, '') = 'C'
			and i.pmeth in ('V','M','X','D')
	END		
	
	IF UPDATE(expdate) 
	BEGIN 
		insert into Synchronize (TableName, FieldName, PrimaryKey, OldValue, NewValue, ExternalSystem, InsertDate)
		select 'SalesOrder', 'ExpirationDate', i.somkey, isnull(d.expdate, ''), isnull(i.expdate, ''), 'Accounting', getdate()
		from [inserted] i left join
			[deleted] d on d.somkey = i.somkey
		where isnull(d.expdate, '') <> isnull(i.expdate, '') and isnull(d.sostat, '') = 'C'
	END	
	
	IF UPDATE(CCLastFourDigits) 
	BEGIN 
		insert into Synchronize (TableName, FieldName, PrimaryKey, OldValue, NewValue, ExternalSystem, InsertDate)
		select 'SalesOrder', 'CCLastFour', i.somkey, isnull(d.CCLastFourDigits, ''), isnull(i.CCLastFourDigits, ''), 'Accounting', getdate()
		from [inserted] i left join
			[deleted] d on d.somkey = i.somkey
		where isnull(d.CCLastFourDigits, '') <> isnull(i.CCLastFourDigits, '') and isnull(d.sostat, '') = 'C'
	END	
	
	SET NOCOUNT OFF		
END

GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBIU_SOMAST_Synchronize]
GO


