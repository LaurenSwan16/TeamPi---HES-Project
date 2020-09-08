/* code for creating dimension tables */ 

-- creating postcode dimension LS

select DISTINCT HOMEADD as Postcode_sector, null as Region, null as Population
into test.dim_postcode
from dbo.HESAPC


-- creating GP practice dimension LS

select *
into test.dim_practice
from
(
	select distinct GPPRAC as practice_ID, [Name], [National_Grouping], [Satus_Code],
					[High_Level_Health_Geography], [Contact_Telephone_Number]
	from dbo.HESAPC
	join dbo.epraccur -- joining to dbo.epraccur to populate enrichment columns from other data source
	on dbo.HESAPC.GPPRAC = dbo.epraccur.Organisation_Code
) AS t 


-- creating hosprovider dimension MS

select distinct procode as provider_code, null as is_private
into test.dim_healthprovider
from dbo.HESAPC


-- dim_sex MS

select distinct SEX as sex_id, 

	case when sex = 1 then 'Male'

		when sex = 2 then 'Female'		 

		when sex = 9 then 'Not specified'

		when sex = 0 then 'Not known'

		when sex = 3 then 'Indeterminate, undergoing sex change operations' 

	end name

	into test.dim_sex

from HESAPC

					 

-- dim_age 

create table test.dim_age 

	(age int identity,

	age_group varchar(99))



insert into test.dim_age values ('100+')





-- dim_AdmiSorc ML

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

-- creating dim_ethnicity RB

select distinct
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
into test.dim_ethnicity
from dbo.HESAPC
order by Ethnicity
GO

-- creating diagnosis dimension 


drop table test.dim_diagnosis

select *
into test.dim_diagnosis
from 
(
		select distinct DIAG_01 as diagnosis_id,
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

-- checking to see which diag_01 rows are not joined properly RB

select diag_01 from HESAPC
except 
select To_ICD_10_5th_Edition_code
from dbo.ICD10


GO
-- epitype dimension ML

select distinct EPITYPE as epitype_id,
'' as episode_description, '' as subcategory
into test.dim_episodetype
from dbo.HESAPC
order by epitype_id
GO

-- creating date dimensions ZL 

if OBJECT_ID('dim_Date') is not null
begin
	drop table dimdate
end
;with dates
as
(
--Anchor row
select
	cast(min(case when dob > '1801-01-01' then dob else null end) as date) as 'Date',
	DATENAME(mm, cast(MIN(DOB) as date)) as dtmonth,
	DATENAME(DY, cast(MIN(DOB) as date)) as dyofyear,
	case	
		when month(cast(min(case when dob > '1801-01-01' then dob else null end) as date)) IN (12, 1, 2) then 'Winter'
		when month(cast(min(case when dob > '1801-01-01' then dob else null end) as date)) IN (3, 4, 5) then 'Spring'
		when month(cast(min(case when dob > '1801-01-01' then dob else null end) as date)) IN (6, 7, 8) then 'Summer'
		else 'Autumn'
	end as Season,
	case
		when DAY(cast(min(case when dob > '1801-01-01' then dob else null end) as date)) IN (6, 7) then 'Weekend'
	else 'Weekday'
	end as 'Week'
from HESAPC
union all
select
	dateadd(d,1,Date),
	DATENAME(mm, dateadd(d,1,Date)) as dtmonth,
	DATENAME(DY, dateadd(d,1,Date)) as dyofyear,
	case	
		when month(dateadd(d,1,Date)) IN (12, 1, 2) then 'Winter'
		when month(dateadd(d,1,Date)) IN (3, 4, 5) then 'Spring'
		when month(dateadd(d,1,Date)) IN (6, 7, 8) then 'Summer'
		else 'Autumn'
	end as Season,
	case
		when DAY(dateadd(d,1,Date)) IN (6, 7) then 'Weekend'
	else 'Weekday'
	end as 'Week'
from dates
where DATEADD(dd,1,Date) <= '2030-12-31'
)
select * 
into test.dim_Date
from dates
option (maxrecursion 0)