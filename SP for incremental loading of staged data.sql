﻿USE [HESTeamPi]
GO
/****** Object:  StoredProcedure [dbo].[SP_Insert_into_HESAPC]    Script Date: 9/8/2020 5:18:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   proc [dbo].[SP_Insert_into_HESAPC]
AS
begin

	insert into dbo.HESAPC with (tablock) -- 40 mins

	([SPELL], [EPISODE], [BEDYEAR], [EPIDUR], [EPIEND], [EPIORDER], [EPISTART], [EPISTAT], [EPITYPE], [PROCODE], [SPELBGIN], [ACTIVAGE], [ADMIAGE], [ADMINCAT], [ADMINCATST],
	[CATEGORY], [DOB], [ENDAGE], [ETHNOS], [HESID], [HOMEADD], [LEGLCAT], [LOPATID], [MYDOB], [NEWNHSNO], [NEWNHSNO_CHECK], [SEX], [STARTAGE], [GPPRAC], [ADMIDATE], [ADMIMETH],
	[ADMISORC], [ELECDATE], [ELECDUR], [ELECDUR_CALC], [DIAG_01], [CLASSPAT], [date_added])
 
	(	select * 
		from	
				(select
							[SPELL], [EPISODE], [BEDYEAR], [EPIDUR], [EPIEND], [EPIORDER], [EPISTART], [EPISTAT], [EPITYPE], [PROCODE], [SPELBGIN], [ACTIVAGE], [ADMIAGE], [ADMINCAT], [ADMINCATST],
						[CATEGORY], [DOB], [ENDAGE], [ETHNOS], [HESID], [HOMEADD], [LEGLCAT], [LOPATID], [MYDOB], [NEWNHSNO], [NEWNHSNO_CHECK], [SEX], [STARTAGE], [GPPRAC], [ADMIDATE], [ADMIMETH],
						[ADMISORC], [ELECDATE], [ELECDUR], [ELECDUR_CALC], [DIAG_01], [CLASSPAT], getdate() as [date_added] 

				from dirty.HESAPC ) as t

		where datediff(hh, date_added, getdate()) <= 24
	
	)
	drop table dirty.hesapc
end
