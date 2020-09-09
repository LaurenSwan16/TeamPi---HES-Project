![alt text](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/teampi.png "Logo") 

# TeamPi - HES Project

Repository for all material produced by Team Pi during Kubrick Group Data Engineering training as part of the HES Project. 

## Project Aims: 
- To develop a dimensional model, following the Kimball Group Star methodology, including the use of dimension tables and a central fact    table.
- To allow for incremental loading of the model via a staging area. 
- Addition of enrichment within dimension tables taken from: 
   + TRUD NHS Digital ICD10 codes 
   + TRUD NHS Digital GPPrac Epraccur

## Modelling approach 

Our fact table relvoves around the instance of a patient in hospital, and uses the dimensions to fully describe this instance. 

![alt text](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/Screen%20Shot%202020-09-04%20at%2015.04.17.png "ERD") 

These attributes were determined to be facts:
- EPIDUR
- BEDYEAR
- NEWNHSNO
- ELECDUR
- ELECDURCALC
- NEWNHSNO_CHECK

Dimensions were created for all the other attributes and are described below:

- Dim_diagnosis 
  + This dimension provides a description of the diagnosis based on diagnosis code
  + Obtained using ICD10 codes.
- Dim_date
- Dim_practice
  + This dimension was enriched using the TRUD Epraccur data.
- Dim_Admimeth 
- Dim_Admicat 
- Dim_Admisorc
- Dim_age
- Dim_cat
- Dim_class
- Dim_Episodetype
- Dim_ethnicity
- Dim_Postcode
- Dim_healthprovider
- Dim_legal 
- Dim_sex

## Daily incremental load (adding new data) 

This is completed using stored procedures. 

When adding new data to this database first upload data to dirty.HESAPC

Run Stored proc:
					SP_Insert_into_HESAPC 

	- This uploads all new data into the staging area. 

Then run the overall proc:
						SP_fact_insert

	This completes the following: 

       Runs the following stored procs to update dimensions:  
       -- These dimensions have been determined as SCD type 2, as opposed to others which are fixed.
							SP_dimsex_update
							SP_dimpractice_update
							SP_dimpostcode_update
							SP_dimethnicity_update
							SP_dimdiagnosis_update
							SP_dimAdmiSorc_update

			Runs stored proc to update fact table from these dimensions
