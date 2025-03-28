// Load the AER dataset
use "/Users/ketrin/Downloads/Reply-to-Albouy-dataset-for-AER-replication-filing-May-2-2012-3.dta", clear

// Merge AER with Deaths & Pop dataset
merge 1:1 shortnam using "/Users/ketrin/Downloads/Deaths & Pop-3.dta"
drop _merge
// Merge AER with Rainfall dataset
merge 1:1 shortnam using "/Users/ketrin/Downloads/Rainfall.dta"
drop _merge


// Merge AER with ZKA dataset
merge 1:1 shortnam using "/Users/ketrin/Downloads/ZKA.dta"
drop _merge


// Merge AER with Assenova, Regele 2017 dataset
merge 1:1 shortnam using "/Users/ketrin/Desktop/CI Project/complete_data_iv.dta"
drop _merge


// Keep only observations from Africa and Asia
drop if missing(decol_deaths)


// Generate binary variable plantation_dummy
generate plantation_dummy=0
replace plantation_dummy=1 if (level_of_plantation==1 | level_of_plantation==2)


//Descriptive statistics
summarize logpgp12
histogram logpgp12 , bin(10) normal

twoway (scatter plantationsduringcolonialperi plantation_dummy, ///
    xlabel(0 "No importance" 1 "Some/significant imp") ///
    mlabel(shortnam)) ///
    (lfit plantationsduringcolonialperi plantation_dummy), ///
    ytitle("Plantation Extent") ///
    xtitle("Plantation Economy Importance")

	
summarize plantationsduringcolonialperi COLYEARS political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd logpgp12 if shortnam != "IRQ"

//Drop unused variables
drop longname risk campaign source0 slave latitude neoeuro other campaignsj campaignsj2 mortnaval1 mortnaval1250 mortnaval2 mortnaval2250 logmortcap250 logmortjam logmortnaval1 logmortnaval1250 logmortnaval2 logmortnaval2250 malfal94 wacacontested census_discrepancy  CountryName Maincolonialmotherlandsour name yrcol colonizer continent instage1817 instage1900 currentinst samerica  logem4 meantemp temp1 temp2 temp3 temp4 temp5 steplow deslow stepmid desmid drystep drywint yellow idep baseco humid1 humid2 humid3 humid4 goldm silv zinc oilres 
	
	
//Main Model
regress plantation_dummy plantationsduringcolonialperi  COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)

ivregress 2sls logpgp12 COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded (plantation_dummy =plantationsduringcolonialperi) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
estat firststage

outreg2 using "/Users/ketrin/Desktop/CI Project/main_model.doc", replace word


//linear regression model without instrumental variables (IV)
regress logpgp12 plantation_dummy COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd  i.colonyof_encoded if shortnam !="IRQ",first vce(cluster colonyof_encoded)



// Regression without Fixed Effects
regress plantation_dummy plantationsduringcolonialperi COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ")

ivregress 2sls logpgp12 COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd (plantation_dummy =plantationsduringcolonialperi) if shortnam !="IRQ",first r 
estat firststage



// Alternative IV model using rainfall as instrument
regress plantation_dummy rainfall COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)

ivregress 2sls logpgp12 COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded (plantation_dummy =rainfall) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
estat firststage


//Using labor productivity in 1988 (Hall & Jones) as dependent variable
regress plantation_dummy plantationsduringcolonialperi  COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)

ivregress 2sls loghjypl COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded (plantation_dummy =plantationsduringcolonialperi) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
estat firststage


//tables
// FIRST STAGE RESULTS
// Main Model
regress plantation_dummy plantationsduringcolonialperi COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg.tex", replace ctitle("Main Model") label dec(3) title("Table 1: FIRST STAGE RESULTS")

// Linear regression model without instrumental variables (IV)

outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg.tex", append ctitle("M2: Without IV") label dec(3)

// Regression without Fixed Effects
regress plantation_dummy plantationsduringcolonialperi COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ")
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg.tex", append ctitle("M3: Without Fixed Eff") label dec(3)

// Alternative IV model using rainfall as instrument
regress plantation_dummy rainfall COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg.tex", append ctitle("M4: Alt IV Rainfall") label dec(3)

// Using labor productivity in 1988 (Hall & Jones) as dependent variable
regress plantation_dummy plantationsduringcolonialperi COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded if (shortnam !="IRQ"), vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg.tex", append ctitle("M5: Workers 1988 Dep") label dec(3)

// 2SLS RESULTS

//Main Model
ivregress 2sls logpgp12 COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded (plantation_dummy =plantationsduringcolonialperi) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg2.tex", replace ctitle("Main Model") label dec(3) title("Table : 2SLS RESULTS")

// Linear regression model without instrumental variables (IV)
regress logpgp12 plantation_dummy COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd  i.colonyof_encoded if shortnam !="IRQ",first vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg2.tex", append ctitle("M2: Without IV") label dec(3)

// Regression without Fixed Effects
ivregress 2sls logpgp12 COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd (plantation_dummy =plantationsduringcolonialperi) if shortnam !="IRQ",first r 
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg2.tex", append ctitle("M3: Without Fixed Eff") label dec(3)

// Alternative IV model using rainfall as instrument
ivregress 2sls logpgp12 COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded (plantation_dummy =rainfall) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg2.tex", append ctitle("M4: Alt IV Rainfall") label dec(3)

// Using labor productivity in 1988 (Hall & Jones) as dependent variable
ivregress 2sls loghjypl COLYEARS iron landlock asia f_french political_violence latabs deaths_per_pop powertransferduringdecoloniza immigrationofforeignworkersd i.colonyof_encoded (plantation_dummy =plantationsduringcolonialperi) if shortnam !="IRQ",first vce(cluster colonyof_encoded)
outreg2 using "/Users/ketrin/Desktop/CI Project/tables/myreg2.tex", append ctitle("M5: Workers 1988 Dep") label dec(3)

