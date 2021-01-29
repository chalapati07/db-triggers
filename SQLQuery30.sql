USE [Phoenix]
GO

/****** Object:  Trigger [dbo].[TBIU_SOMAST_DATEFIX]    Script Date: 1/29/2021 1:00:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






CREATE  Trigger [dbo].[TBIU_SOMAST_DATEFIX] On [dbo].[SOMAST]

for Insert, Update

As 
begin

  Set NoCount On

 

  -- the "exists" is done to prevent the update from occuring if there isn't any reason to do it.

  -- the reason for not just letting the "where" clause handle it, is because there are multiple triggers

  -- on the table and weather or not a row is affected the other update trigger will fire - this prevents

  -- this. 

  -- check to see if the time needs to be stripped off the date

  if     Update(Ordate)

     And Exists (Select * 

                 From Inserted 

                  Where Ordate != Convert(VarChar, ORDATE,101)) 

  begin

    Update SOMAST Set ORDATE = Convert(VarChar, SOMAST.ORDATE,101)

    From SOMAST, 

         INSERTED 

    Where SOMAST.SOMKEY = INSERTED.SOMKEY

      And SOMAST.Ordate != Convert(VarChar, Inserted.ORDATE,101)

  end

 

  -- if a quote was converted and the qreason is not null or 0 then blank it out

  -- technically we don't need to do the "exists" at all, we could simply do the

  -- update and only the needed records would be affected. but because there are 

  -- multiple triggers on this table, checking before hand keeps the other triggers

  -- from having to fire when there is nothing updated (since triggers fire even 

  -- if no records are affected)

  if Exists (Select *

             From Inserted i,

                  Deleted d

             Where i.somkey = d.somkey

               and d.sotype = 'Q'

               and i.sotype = ''

               and IsNull(i.qreason, '') != ''

              and i.qreason not in ('A','M'))

  begin

    update a set qreason = null

    From Inserted i,

         Deleted d, 

         somast a

    Where i.somkey = d.somkey

      and d.sotype = 'Q'

      and i.sotype = ''

      and IsNull(i.qreason, '') != ''

      and i.qreason not in ('A','M')

      and a.somkey = i.somkey

  end

 
  Set NoCount OFF
END
 

GO

ALTER TABLE [dbo].[SOMAST] ENABLE TRIGGER [TBIU_SOMAST_DATEFIX]
GO


