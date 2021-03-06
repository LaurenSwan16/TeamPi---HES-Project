USE [HESTeamPi]
GO
/****** Object:  StoredProcedure [dbo].[SP_dimsex_update]    Script Date: 9/9/2020 5:23:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   proc [dbo].[SP_dimsex_update]
as
begin
	if object_id('dim_sex') is not null
	begin
		truncate table dim.sex
	end

	insert into test.dim_sex
	select * from 
	(
		select distinct SEX as sex_id,
			case 
				when sex = 1 then 'Male'
				when sex = 2 then 'Female'	
				when sex = 9 then 'Not specified'
				when sex = 0 then 'Not known'
				when sex = 3 then 'Indeterminate, 
				undergoing sex change operations' 
			end name
		from dbo.HESAPC
	) as t
end


/****** Object:  StoredProcedure [dbo].[SP_dimpractice_update]    Script Date: 9/9/2020 5:23:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   proc [dbo].[SP_dimpractice_update]

AS 
Begin 

	truncate table test.dim_practice

	insert into test.dim_practice
	select *
	from
	(
		select distinct GPPRAC as practice_ID, [Name], [National_Grouping], [Satus_Code],
						[High_Level_Health_Geography], [Contact_Telephone_Number]
		from dbo.HESAPC
		join dbo.epraccur -- joining to dbo.epraccur to populate enrichment columns from other data source
		on dbo.HESAPC.GPPRAC = dbo.epraccur.Organisation_Code
	) AS t 

end

/****** Object:  StoredProcedure [dbo].[SP_dimpostcode_update]    Script Date: 9/9/2020 5:23:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_dimpostcode_update]

AS 
BEGIN 
	truncate table test.dim_postcode
	
	insert into test.dim_postcode
	select DISTINCT HOMEADD as Postcode_sector, null as Region, null as Population
	from dbo.HESAPC

END 

/****** Object:  StoredProcedure [dbo].[SP_dimethnicity_update]    Script Date: 9/9/2020 5:23:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   proc [dbo].[SP_dimethnicity_update]
as
BEGIN

if object_id('dim_ethnicity') is not null
truncate table test.dim_ethnicity

insert into test.dim_ethnicity
	select *
	from
	(		select distinct
case	when ETHNOS = 'G' then 'Other Mixed'
		when ETHNOS = 'R' then 'Chinese'
		when ETHNOS = 'A' then 'White British'
		when ETHNOS = 'L' then 'Other Asian'
		when ETHNOS = 'F' then 'White and Asian'
		when ETHNOS = 'J' then 'Pakistani'
		when ETHNOS = 'M' then 'Caribbean'
		when ETHNOS = 'P' then 'Black (Other)'
		when ETHNOS = 'K' then 'Bangladeshi'
		when ETHNOS = 'B' then 'White Irish'
		when ETHNOS = 'N' then 'African'
		when ETHNOS = 'C' then 'Any other white background'
		when ETHNOS = 'D' then 'White and black Carribean (Mixed)'
		when ETHNOS = 'E' then 'White and black African (Mixed)'
		when ETHNOS = 'H' then 'Indian (Asian or Asian British)'
		when ETHNOS = 'S' then 'Any other ethnic group'
		else 'UNKNOWN'
end as ethnicity, '' as ethnic_group, '' as country_of_birth
from dbo.HESAPC
	) as t

END

/****** Object:  StoredProcedure [dbo].[SP_dimdiagnosis_update]    Script Date: 9/9/2020 5:23:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   procedure [dbo].[SP_dimdiagnosis_update]

AS
Begin

	truncate table test.dim_diagnosis

	insert into test.dim_diagnosis
	select * 
	from 
		(
				select DISTINCT DIAG_01 as diagnosis_id,
				Code_Description,
				'' as type,
				'' as infection_rate,
				'' as incidence_rate,
				'' as mortality_rate,
				'' as is_terminal
				from dbo.HESAPC
				left join dbo.ICD10
				on dbo.HESAPC.DIAG_01 = dbo.ICD10.To_ICD_10_5th_Edition_code
		) as t

End

/****** Object:  StoredProcedure [dbo].[SP_dimAdmiSorc_update]    Script Date: 9/9/2020 5:23:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   proc [dbo].[SP_dimAdmiSorc_update]

as
begin
	if OBJECT_ID('test.dim_AdmiSorc') is not null
		drop table test.dim_AdmiSorc

	select distinct ADMISORC Admisorc_id, 
	
		CASE
	
			WHEN Admisorc = 19 THEN 'The usual place of residence, unless listed below, for example, a private dwelling whether owner occupied or owned by Local Authority, housing association or other landlord. This includes wardened accommodation but not residential accommodation where health care is provided. It also includes PATIENTS with no fixed abode.'
	
			WHEN Admisorc = 29 THEN 'Temporary place of residence when usually resident elsewhere, for example, hotels and residential educational establishments'
	
			WHEN Admisorc = 30 THEN 'Repatriation from high security psychiatric hospital (1999-00 to 2006-07)'
	
			WHEN Admisorc = 37 THEN 'Penal establishment: court (1999-00 to 2006-07)'
	
			WHEN Admisorc = 38 THEN 'Penal establishment: police station (1999-00 to 2006-07)'
	
			WHEN Admisorc = 39 THEN 'Penal establishment, Court or Police Station / Police Custody Suite'
	
			WHEN Admisorc = 48 THEN 'High security psychiatric hospital, Scotland (1999-00 to 2006-07)'
	
			WHEN Admisorc = 49 THEN 'NHS other hospital provider: high security psychiatric accommodation in an NHS hospital provider (NHS trust or NHS Foundation Trust)'
	
			WHEN Admisorc = 50 THEN 'NHS other hospital provider: medium secure unit (1999-00 to 2006-07)'
	
			WHEN Admisorc = 51 THEN 'NHS other hospital provider: ward for general patients or the younger physically disabled or A&E department'
	
			WHEN Admisorc = 52 THEN 'NHS other hospital provider: ward for maternity patients or neonates'
	
			WHEN Admisorc = 53 THEN 'NHS other hospital provider: ward for patients who are mentally ill or have learning disabilities'
	
			WHEN Admisorc = 54 THEN 'NHS run Care Home'
	
			WHEN Admisorc = 65 THEN 'Local authority residential accommodation i.e. where care is provided'
	
			WHEN Admisorc = 66 THEN 'Local authority foster care, but not in residential accommodation i.e. where care is provided'
	
			WHEN Admisorc = 69 THEN 'Local authority home or care (1989-90 to 1995-96)'
	
			WHEN Admisorc = 79 THEN 'Babies born in or on the way to hospital'
	
			WHEN Admisorc = 85 THEN 'Non-NHS (other than Local Authority) run care home'
	
			WHEN Admisorc = 86 THEN 'Non-NHS (other than Local Authority) run nursing home'
	
			WHEN Admisorc = 87 THEN 'Non-NHS run hospital'
	
			WHEN Admisorc = 88 THEN 'non-NHS (other than Local Authority) run hospice'
	
			WHEN Admisorc = 89 THEN 'Non-NHS institution (1989-90 to 1995-96)'
	
			WHEN Admisorc = 98 THEN 'Not applicable'
	
			WHEN Admisorc = 99 THEN 'Not known'
	
		END [Description]
	
		into test.dim_AdmiSorc
	
	from HESAPC
end

