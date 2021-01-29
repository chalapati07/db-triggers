USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBIU_SOMAST_SalesForce]    Script Date: 1/29/2021 1:01:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE Trigger [dbo].[TBIU_SOMAST_SalesForce] ON [dbo].[SOMAST]
FOR INSERT
	,UPDATE
AS
BEGIN
	SET NOCOUNT ON
if
	update(authcode) or
	update(ccApprovalCode) or
	update(sodate) or
	update(arckey) or
	update(userin) or
	update(expdate) or
	update(glarec) or
	update(hreason) or
	update(cclastfourdigits) or
	update(ordamt) or
	update(somkey) or
	update(ctckey) or
	update(ordate) or
	update(retsomkey) or
	update(pmeth) or
	update(paymentplan) or
	update(ponum) or
	update(qreason) or
	update(rush) or
	update(salesmn) or
	update(shipvia) or
	update(shpamt) or
	update(sostat) or
	update(sotype) or
	update(source) or
	update(pterms) or
	update(voidreason) or
	update(web_reference) or
	update(NewSourceCode) or
	update(ListCode)

BEGIN
		DECLARE @SalesOrderId INT
		DECLARE @Id INT
		DECLARE @Temp TABLE (
			id INT identity
			,[key] INT
			)

		INSERT INTO @Temp
		SELECT i.somkey
		FROM inserted i
		LEFT JOIN ARCUST a (nolock)
		ON i.ARCKEY = a.ARCKEY
		WHERE a.Code NOT IN (
				'I'
				,'DEL'
				,'MGD'
				)
			and
			(
				exists (select 1 from sf.OrderHeaderMapping where PhoenixId = i.somkey)
				or year(i.ORDATE) >= year(getdate()) - 5
			)			
			--AND i.ORDATE >= '1/1/2008' --SR11002002

		WHILE EXISTS (
				SELECT 1
				FROM @Temp
				)
		BEGIN
			SET @Id = (
					SELECT TOP 1 ID
					FROM @Temp
					)

			SELECT @SalesOrderId = [Key]
			FROM @Temp
			WHERE ID = @ID

			INSERT INTO SF.Integration
			SELECT 'OrderHeader'
				,@SalesOrderId
				,GETDATE()

			DELETE
			FROM @Temp
			WHERE ID = @ID
		END
	END
	SET NOCOUNT OFF
END
GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBIU_SOMAST_SalesForce]
GO


