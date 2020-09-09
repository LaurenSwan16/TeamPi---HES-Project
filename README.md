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

### Cleaning the data 

We removed all null columns and altered data types. 
([see code here](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/Cleaning%20null%20columns%20and%20altering%20column%20types.txt)

Our fact table relvoves around the instance of a patient in hospital, and uses the dimensions to fully describe this instance. 

![alt text](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/FullERD.png "ERD") 

These attributes were determined to be facts:
- EPIDUR
- BEDYEAR
- NEWNHSNO
- ELECDUR
- ELECDURCALC
- NEWNHSNO_CHECK

Dimensions were created ([see code here](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/Dimension%20creation%20code%20-%20Hospital%20project%20-%20Team%20Pi.sql)) for all the other attributes and are described below:

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
					[SP_Insert_into_HESAPC](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/SP%20for%20incremental%20loading%20of%20staged%20data.sql) 

- This uploads all new data into the staging area. 

## Updating the dimensions and fact table 

Run the overall proc
						[SP_fact_insert](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/SP_fact_insert.sql)

This completes the following: 

1. Runs the following stored procs to update dimensions ([see code here](https://github.com/LaurenSwan16/TeamPi---HES-Project/blob/master/SP%20for%20updating%20ALL%20dimensions.sql)):  
These dimensions have been determined as SCD type 2, as opposed to others which are fixed.
- SP_dimsex_update
- SP_dimpractice_update
- SP_dimpostcode_update
- SP_dimethnicity_update
- SP_dimdiagnosis_update
- SP_dimAdmiSorc_update

2. Runs stored proc to update fact table from these dimensions
