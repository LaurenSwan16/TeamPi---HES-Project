CREATE OR ALTER PROC SP_fact_insert as
begin
	
	-- Step 1: Drop the table indexes
	drop index dbo.fact.ID_fact_ix

	-- Step 2: Check dim tables
	-- AdmiMeth
	--select ADMIMETH from dbo.HESAPC
	--except
	--select ADMIMETH from test.dim_AdmiMeth
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimAdmiMeth_update
	--	end

	-- AdminCat
	--select ADMINCAT from dbo.HESAPC
	--except
	--select admincat from test.dim_AdminCat
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimAdminCat_update
	--	end

	-- AdminSorc
	select ADMISORC from dbo.HESAPC
	except
	select Admisorc_id from test.dim_AdmiSorc
	if @@ROWCOUNT > 0
		begin
			exec SP_dimAdmiSorc_update
		end

	-- cat
	--select CATEGORY from dbo.HESAPC
	--except
	--select category_id from test.dim_cat
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimCat_update
	--	end

	-- class
	--select CLASSPAT from dbo.HESAPC
	--except
	--select class_id from test.dim_class
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimClass_update
	--	end

	-- diagnosis
	select DIAG_01 from dbo.HESAPC
	except
	select diagnosis_id from test.dim_diagnosis
	if @@ROWCOUNT > 0
		begin
			exec SP_dimDiagnosis_update
		end

	-- episode type
	--select EPITYPE from dbo.HESAPC
	--except
	--select epitype_id from test.dim_episodetype
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimEpisodeType_update
	--	end

	-- ethnicity
	select ETHNOS from dbo.HESAPC
	except
	select ethnicity from test.dim_ethnicity
	if @@ROWCOUNT > 0
		begin
			exec SP_dimEthnicity_update
		end

	-- health provider
	--select PROCODE from dbo.HESAPC
	--except
	--select PROCODE from test.dim_healthprovider
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimHealthProvider_update
	--	end

	-- legal
	--select LEGLCAT from dbo.HESAPC
	--except
	--select legal_id from test.dim_legal
	--if @@ROWCOUNT > 0
	--	begin
	--		exec SP_dimLegal_update
	--	end

	-- postcode
	select HOMEADD from dbo.HESAPC
	except
	select Postcode_sector from test.dim_postcode
	if @@ROWCOUNT > 0
		begin
			exec SP_dimPostcode_update
		end
	
	-- practice
	select GPPRAC from dbo.HESAPC
	except
	select practice_ID from test.dim_practice
	if @@ROWCOUNT > 0
		begin
			exec SP_dimPractice_update
		end

	-- sex
	select SEX from dbo.HESAPC
	except
	select sex_id from test.dim_sex
	if @@ROWCOUNT > 0
		begin
			exec SP_dimSex_update
		end
		
	-- Step 3: Update the fact table
	INSERT INTO dbo.fact 
		([Admisorc_id], [ActivAge], [AdmiAge], [EndAge], [class_id], [EpiEnd], [EpiStart], 
		[DOB], [AdmiDate], [ElecDate], [diagnosis_id], [epitype_id], [ethnicity], [PROCODE], 
		[ADMIMETH], [legal_id], [Postcode_sector], [practice_ID], [sex_id], [category_id], [EPIDUR], 
		[BEDYEAR], [HESID], [LOPATID], [NEWNHSNO], [NEWNHSNO_CHECK], [ELECDUR], [ELECDUR_CALC],date_added,[UPDATED_DATE])
		select 
			j1.Admisorc_id, 
			j2.age ActivAge, 
			j3.age AdmiAge, 
			j4.age EndAge, 
			j5.class_id,
			j6.Date EpiEnd, 
			j7.Date EpiStart, 
			j8.Date DOB,
			j9.Date AdmiDate,	
			j10.Date ElecDate, 
			j11.diagnosis_id, 
			j12.epitype_id,
			j13.ethnicity,
			j14.PROCODE,
			j15.ADMIMETH,
			j16.legal_id,
			j17.Postcode_sector,
			j18.practice_ID, 
			j19.sex_id, 
			j20.category_id, 
			EPIDUR, BEDYEAR, HESID, LOPATID, NEWNHSNO, NEWNHSNO_CHECK ,ELECDUR, ELECDUR_CALC, date_added, Getdate() UPDATED_DATE
		from HESAPC h
			left join test.dim_AdmiSorc j1
				on h.ADMISORC = j1.Admisorc_id
			left join test.dim_age j2
				on h.ACTIVAGE = j2.age
			left join test.dim_age j3
				on h.ADMIAGE = j3.age
			left join test.dim_age j4
				on h.ENDAGE = j4.age
			left join test.dim_class j5
				on h.CLASSPAT = j5.class_id
			left join test.dim_Date j6
				on h.EPIEND = j6.Date
			left join test.dim_Date j7
				on h.EPISTART = j7.Date
			left join test.dim_Date j8
				on h.DOB = j8.Date
			left join test.dim_Date j9
				on h.ADMIDATE = j9.Date
			left join test.dim_Date j10
				on h.ELECDATE = j10.Date
			left join test.dim_diagnosis j11
				on h.DIAG_01 = j11.diagnosis_id
			left join test.dim_episodetype j12
				on h.EPITYPE = j12.epitype_id
			left join test.dim_ethnicity j13
				on h.ETHNOS = j13.ethnicity
			left join test.dim_healthprovider j14
				on h.PROCODE = j14.PROCODE
			left join test.dim_AdmiMeth j15
				on h.ADMIMETH = j15.ADMIMETH
			left join test.dim_legal j16
				on h.LEGLCAT = j16.legal_id
			left join test.dim_postcode j17
				on h.HOMEADD = j17.Postcode_sector
			left join test.dim_practice j18
				on h.GPPRAC = j18.practice_ID
			left join test.dim_sex j19
				on h.SEX = j19.sex_id
			left join test.dim_cat j20
				on h.CATEGORY = j20.category_id
		WHERE DATEDIFF(HH,h.date_added,GETDATE()) < 24


	-- Step 4: Re-add the table indexes
	create clustered index ID_fact_ix on dbo.fact(ID)
end
go