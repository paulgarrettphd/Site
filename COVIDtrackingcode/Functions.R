library(tidyverse)
library(expss)
library(rio)
library(parsedate)

# Reverse scores a scale for items of reversed polarity. Code from Stephan Lewandowsky.
revscore = function (x,mm) {  
  return ((mm+1)-x)            
}
# Give rounded percentage
Per = function( d, i, r){
  if (missing(r) == TRUE){
    r = 0
  }
  round( (sum(d == i, na.rm=T) / length(d) * 100), r )
}
# Calculate the mode
mode <- function(x) {
  uniqv <- unique(x)
  uniqv[which.max(tabulate(match(x, uniqv)))]
}
# Calculate rounded mean & sd - for mkdown report writing.
m = function(x, dp) {
  if (missing(dp)){dp=0}
  k = round(mean(x, na.rm = T),dp)
  return(k)
}
s = function(x, dp) {
  if (missing(dp)){dp=0}
  k = round(sd(x, na.rm=T),dp)
  return(k)
}

# Function to clean the raw data from Waves 1 and 2 of the Government Tracking Study.
# Takes a file path argument & an optional argument for Country ID (e.g., 9 was Australia in Qualtrics).
CleanTrackingData = function (CSVfile, CountryID ) {
  if( missing(CountryID) ){ CountryID = 0 } # Default 0: Skips Country ID Check. (Australia = 9).
  
  # Load in Raw CSV File
  Data = read.csv(CSVfile) 
  RawData = Data
  RawN = nrow(Data)
  
  if ('ï..StartDate' %in% colnames(Data)){ colnames(Data)[colnames(Data)=='ï..StartDate'] = 'StartDate' }
  
  # Fix 'fatalaties' to 'fatalities' in the column names
  colnames(Data) = gsub('COVID_fatalaties', 'COVID_fatalities', colnames(Data))
  
  if ('COVID_fatalities_1' %in% colnames(Data) ){
    Data$COVID_fatalities_6 = Data$COVID_fatalities_7
    Data$COVID_fatalities_7 = Data$COVID_fatalities_8
    Data$COVID_fatalities_8 = Data$COVID_fatalities_9
    Data$COVID_fatalities_9 = Data$COVID_fatalities_10
    Data %<>% select(-COVID_fatalities_10)
  }
  
  # Find the Start and End of collection
  StartDate = format( min( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  EndDate   = format( max( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  
  if (is.na(StartDate)){
    StartDate = format( min( as.Date(Data$StartDate, '%d/%m/%y'), na.rm = T ), '%d-%m-%Y')
    EndDate   = format( max( as.Date(Data$StartDate, '%d/%m/%y'), na.rm = T ), '%d-%m-%Y')
  }
    
  ## Check if the task includes Bluetooth Tracking Condition ##
  if ( 'bluetooth' %in% Data$scenario_type ){ Btooth = TRUE }else{ Btooth = FALSE }
  
  # Fix age column name if it hasn't been already.
  if ('age_4' %in% colnames(Data) ){ Data %<>% rename(Age = age_4) }
  # Use 'Age' over 'age' due to grep search later. The capital removes any
  # confusion with the age in languAGE.
  if ('age' %in% colnames(Data) ){ Data %<>% rename(Age = age) }
  
  ## Filter Data by Country of Residence ##
  if ( CountryID != 0 & 'country' %in% colnames(Data) ){
    Data %<>% filter( country == CountryID  )
  }
  Del.Country = RawN - nrow(Data)
  
  
  ## Filter Data by Age ##
  Data %<>% filter( Age >= 18 )
  Del.Age = RawN - (nrow(Data) + Del.Country)
  
  
  ## Filter by Incomplete & Attention Check ##
  # Incomplete: defined as an NA value in both attention check columns
  # Attenion Fail: defined as any value not equal to 1 in either attention check columns
  if ( Btooth ){
    Del.Incomplete = Data %>% select( att_check, att_check_bt) %>% is.na %>% rowSums == 2 
    Del.Incomplete = sum(Del.Incomplete)
    Del.Attention  = Data %>% select( att_check, att_check_bt) %>% rowSums(na.rm = TRUE) != 1 %>% sum
    Del.Attention  = sum(Del.Attention) - Del.Incomplete
    Data %<>% filter( att_check == 1 | att_check_bt == 1 )
  } else {
    Del.Incomplete = Data %>% filter( is.na(att_check)) %>% nrow
    Del.Attention  = Data %>% filter( att_check != 1 )  %>% nrow
    Data %<>% filter( att_check == 1 )
  }
  
  ## Delete Duplicate Prolific IDs, if prolific was used ## 
  if ('psid' %in% colnames(Data)){ 
  Del.Duplicates = sum( duplicated(Data$psid) == TRUE )
  Data %>% filter( duplicated(psid) == FALSE )
  } else {Del.Duplicates = 0}
  
  # Create a dataframe describing the cleaning steps
  RemovedParticipants = data.frame( 'InitialPs'         = RawN,
                                    'RemovedCountry'    = Del.Country, 
                                    'RemovedAge'        = Del.Age, 
                                    'RemovedAttention'  = Del.Attention,
                                    'RemovedIncomplete' = Del.Incomplete,
                                    'RemovedDuplicate'  = Del.Duplicates,
                                    'RemainingPs'       = nrow(Data) )
  
  # Shorten the dataframe into a usable format + Add Worldview Scores
  Data = Data[, grep("Age", colnames(Data)) : length( colnames(Data) ) ]
  
  # Delete extra columns
  Del.ColNames = c( 'free_text', 'SC0', 'psid', 'PID' )
  Data = Data[,!colnames(Data) %in% Del.ColNames]
  
  # Reverse Score Freemarket Variable
  Data %<>%  mutate(wv_.freemarket_lim = revscore(wv_.freemarket_lim,7))
  
  
  # Apply Labels & Factor Values to common items
  Data %<>% apply_labels(gender = "Gender",
                         gender = c("Men" = 1, "Women" = 2, "Other" = 3, "Prefer not to say" = 4),
                         COVID_pos_others = "Tested pos someone I know",
                         COVID_pos_others = c("Yes" = 1, "No" = 0),
                         scenario_type = "Type of policy scenario",
                         COVID_lost_job = "I lost my job",
                         COVID_lost_job = c("Yes" = 1, "No" = 0),
                         COVID_info_source= "Information source",
                         COVID_info_source = c("Newspaper (printed or online)" = 1, "Social media" = 2, 
                                              "Friends/family" = 3, "Radio" = 4, "Television" = 5, 
                                              'Other' = 6, 'Do not follow' = 7))
  
  # Rename scenarios to be more informative, but keep old names for reference.
  Data %<>% mutate(Scenario = str_replace_all(scenario_type, 
                                              c('mild'      = 'Government App',
                                                'severe'    = 'Telecommunication',
                                                'bluetooth' = 'Bluetooth') ) )
  
  # Add Bluetooth Scenario Variables
  if ( Btooth ){
    Data %<>% apply_labels(mobileuse_sev = "Use mobile",
                           mobileuse_sev = c("Yes" = 1, "No" = 0),
                           smartphoneuse_mildbt = "Use smartphone",
                           smartphoneuse_mildbt = c("Yes" = 1, "No" = 0))
  }
  
  
  # Add code for Austrlian Specific Variables - can be modified by country
  if ( CountryID == 9 ) {
    Data %<>% apply_labels(education = "Education",
                           education = c("Did Not Graduate High School" = 1, "Graduated High School" = 2, "Graduated University" = 3),
                           state = 'State',
                           state = c("NSW"=1, "VIC"=2, "QLD"=3, "SA"=4, 
                                     "WA"=5, "NT"=6, "TAS"=7, "ACT"=8, "Other"=9))
  }
  
  # Add Age Bins
  # This acts to help preserve privacy and allows easy plotting:
  #    e.g., ggplot(Data, aes(x = Agebins) ) + geom_bar()
  Agebin = c('< 20', '20-29', '30-39','40-49','50-59','60-69','70-79','80+')
  Data %<>% mutate(Agebins = case_when(
    Age  < 20 ~ Agebin[1],
    Age >= 20 & Age < 30 ~ Agebin[2],
    Age >= 30 & Age < 40 ~ Agebin[3],
    Age >= 40 & Age < 50 ~ Agebin[4],
    Age >= 50 & Age < 60 ~ Agebin[5],
    Age >= 60 & Age < 70 ~ Agebin[6],
    Age >= 70 & Age < 80 ~ Agebin[7],
    Age >= 80  ~ Agebin[8] ) ) %>% 
    apply_labels(Agebins = 
                   c('< 20' = 1, '20-29' = 2, '30-39' = 3,
                     '40-49' = 4,'50-59' = 5,'60-69' = 6,
                     '70-79' = 7,'80+' = 8))
  
  # Create WorldView Variable
  Data$WorldView = Data %>% dplyr::select(c(wv_freemarket_best, wv_.freemarket_lim, wv_lim_gov)) %>% apply(.,1, mean, na.rm=TRUE)
  
  # Composite score for COVID risk
  Data$COVIDrisk <- Data %>% select(c(COVID_gen_harm,COVID_pers_harm,COVID_pers_concern,COVID_concern_oth)) %>% apply(.,1, mean, na.rm=TRUE)
  
  # Composite score for government trust
  Data$govtrust <- Data %>% select(starts_with("trus")) %>% apply(.,1, mean, na.rm=TRUE)
    
  return( list(Data = Data, 
               CleaningProcedure = RemovedParticipants, 
               StartDate = StartDate,
               EndDate   = EndDate,
               RawData   = RawData) )
}


# Function for loading in world COVID stats using a specified list of countries within a given date range.
# If no countries are specified, Australia is returned by default between Jan 1st 2020 - May 1st 2020.
WorldCOVIDdata = function(Countries, StartDate, EndDate){
  #Countries = c('Australia', 'United_Kingdom', 'United_States_of_America', 'Taiwan', 'Germany', 'China')
  if( missing(Countries) ){ Countries = c('Australia') }
  if( missing(StartDate) ){ StartDate = '2020-01-01' }
  if( missing(EndDate) ){ EndDate = '2020-05-01' }
  
  WorldCOVID = rio::import('https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx') %>% 
    arrange( countriesAndTerritories, year, month, day ) %>% 
    group_by(countriesAndTerritories) %>% 
    mutate(cases.cum = cumsum(cases), deaths.cum = cumsum(deaths), dateRep = as.Date(dateRep, format = '%d/%m/%Y')) %>% 
    select( -c( day, month, year, geoId ) ) %>% 
    rename(date = dateRep, country = countriesAndTerritories, code = countryterritoryCode)  

  WorldCOVID = complete(WorldCOVID, date = seq.Date(min(WorldCOVID$date), max(WorldCOVID$date), by='day') ) %>% 
    group_by(country) %>% fill(cases, deaths, code, cases.cum, deaths.cum) 

  WorldSubset = subset(WorldCOVID, country %in% Countries) %>% filter(date >= StartDate & date <= EndDate)
  return(WorldSubset)
  #WorldSubset = subset(WorldCOVID, country %in% Countries) %>% filter(date >= '2020-03-10')
}

# Returns a select sample of data for a single country on a single date. Dates are formatted for easy plotting.
# If not country is specified, all countries will be returned for the given date.
COVIDbyCountry = function(SelectedDate, Country){
  # Date format: '%Y-%m-%d'
  if( missing(Country) ){ Country = FALSE }
  
  WorldCOVID = rio::import('https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx') %>% 
    arrange( countriesAndTerritories, year, month, day ) %>% 
    group_by(countriesAndTerritories) %>% 
    mutate(cases.cum = cumsum(cases), deaths.cum = cumsum(deaths), dateRep = as.Date(dateRep, format = '%d/%m/%Y')) %>% 
    select( -c( day, month, year, geoId ) ) %>% 
    rename(date = dateRep, country = countriesAndTerritories, code = countryterritoryCode)  
  
  WorldCOVID = complete(WorldCOVID, date = seq.Date(min(WorldCOVID$date), max(WorldCOVID$date), by='day') ) %>% 
    group_by(country) %>% fill(cases, deaths, code, cases.cum, deaths.cum) 
  
  if (Country == FALSE){ WorldCOVID %<>% filter( date == SelectedDate )
  } else { WorldCOVID %<>% filter( date == SelectedDate & country == Country) }
  
  WorldCOVID %<>% select( country, date, deaths.cum, cases.cum, cases, deaths ) %>%  
    rename( Deaths = deaths.cum, Cases = cases.cum, DailyDeaths = deaths, DailyCases = cases, Date = date, Country = country )
  
}
  
# Clean the COVIDSafe data collected during Wave 3 of the study.
CleanCOVIDsafe = function ( CSVfile, Wave4 ) {
  if (missing(Wave4) == TRUE){
    Wave4 = FALSE
  }
  Data = read.csv(CSVfile) 
  if ( 'version' %in% colnames(Data) ){ Data %<>% filter(version == 2) }
  if ('ï..StartDate' %in% colnames(Data)){ colnames(Data)[colnames(Data)=='ï..StartDate'] = 'StartDate' }
  
  RawData = Data
  RawN = nrow(Data)
  
  # Find the Start and End of collection
  StartDate = format( min( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  EndDate   = format( max( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  
  if (is.na(StartDate)){
    StartDate = format( min( as.Date(Data$StartDate, '%m/%d/%y'), na.rm = T ), '%d-%m-%Y')
    EndDate   = format( max( as.Date(Data$StartDate, '%m/%d/%y'), na.rm = T ), '%d-%m-%Y')
  }
  
  
  
  # Fix age column name if it hasn't been already.
  if ('age_4' %in% colnames(Data) ){ Data %<>% rename(Age = age_4) }
  
  if (Wave4 == FALSE){
    if ('COVID_fatalities_1' %in% colnames(Data) ){
      Data$COVID_fatalities_6 = Data$COVID_fatalities_7
      Data$COVID_fatalities_7 = Data$COVID_fatalities_8
      Data$COVID_fatalities_8 = Data$COVID_fatalities_9
      Data$COVID_fatalities_9 = Data$COVID_fatalities_10
      Data %<>% select(-COVID_fatalities_10)
    }
  }
  
  # if (Wave4 == TRUE){
  #   if ('COVID_fatalities_1' %in% colnames(Data) ){
  #     Data$COVID_fatalities_9 = Data$COVID_fatalities_10
  #     Data$COVID_fatalities_10 = Data$COVID_fatalities_11
  #     Data %<>% select(-COVID_fatalities_11)
  #   }
  # }
  # 
  ## Filter Data by Country of Residence ##
  Data %<>% filter( country == 9  ) # 9 = Australia
  Del.Country = RawN - nrow(Data)
  
  ## Filter Data by Age ##
  Data %<>% filter( Age >= 18 )
  Del.Age = RawN - (nrow(Data) + Del.Country)
  
  colnames(Data) 
  
  
  ## Filter by Incomplete & Attention Check ##
  Del.Incomplete = Data %>% filter( is.na(att_check)) %>% nrow
  Del.Attention  = Data %>% filter( att_check != 1 )  %>% nrow
  Data %<>% filter( att_check == 1 )
  
  ## Delete Duplicate Prolific IDs, if prolific was used ## 
  if ('psid' %in% colnames(Data)){ 
    Del.Duplicates = sum( duplicated(Data$psid) == TRUE )
    Data %>% filter( duplicated(psid) == FALSE )
  } else {Del.Duplicates = 0}
  
  # Create a dataframe describing the cleaning steps
  RemovedParticipants = data.frame( 'InitialPs'         = RawN,
                                    'RemovedCountry'    = Del.Country, 
                                    'RemovedAge'        = Del.Age, 
                                    'RemovedAttention'  = Del.Attention,
                                    'RemovedIncomplete' = Del.Incomplete,
                                    'RemovedDuplicate'  = Del.Duplicates,
                                    'RemainingPs'       = nrow(Data) )
  
  # Shorten the dataframe into a usable format + Add Worldview Scores
  Data = Data[, grep("Age", colnames(Data)) : length( colnames(Data) ) ]
  
  # Delete extra columns
  Del.ColNames = c( 'free_text', 'SC0', 'psid', 'PID', 'scenario_timer_First.Click',
                    'scenario_timer_Last.Click', "scenario_timer_Click.Count")
  Data %<>% select( -Del.ColNames )
  
  # Reverse Score Freemarket Variable. Add Scenario col for compatability to other waves.
  Data %<>%  mutate(wv_.freemarket_lim = revscore(wv_.freemarket_lim,7),
                    Scenario = scenario_type)
  
  # Apply Labels & Factor Values to common items
  Data %<>% apply_labels(gender = "Gender",
                         gender = c("Men" = 1, "Women" = 2, "Other" = 3, "Prefer not to say" = 4),
                         COVID_pos_others = "Tested pos someone I know",
                         COVID_pos_others = c("Yes" = 1, "No" = 0),
                         scenario_type = "Type of policy scenario",
                         COVID_lost_job = "I lost my job",
                         COVID_lost_job = c("Yes" = 1, "No" = 0),
                         COVID_info_source= "Information source",
                         COVID_info_source = c("Newspaper (printed or online)" = 1, "Social media" = 2, 
                                               "Friends/family" = 3, "Radio" = 4, "Television" = 5, 
                                               'Other' = 6, 'Do not follow' = 7),
                         smartphoneuse = "Use smartphone",
                         smartphoneuse = c("Yes" = 1, "No" = 0),
                         education = "Education",
                         education = c("Did Not Graduate High School" = 1, "Graduated High School" = 2, "Graduated University" = 3),
                         state = 'State',
                         state = c("NSW"=1, "VIC"=2, "QLD"=3, "SA"=4, 
                                   "WA"=5, "NT"=6, "TAS"=7, "ACT"=8, "Other"=9),
                         COVID_comply_pers = c('Not at all'=1, 'Mostly no'=2, 'Somewhat'=3,
                                               'Mostly yes'=4, 'Completely'=5, 'Slightly beyond'=6,
                                               'Somewhat beyond'=7, 'Significantly beyond'=8,
                                               'Complete quanantine'=9),
                         CS_knowledge_tech = 'App Technology',
                         CS_knowledge_tech = c('Bluetooth'=1,'Location data'=2,
                                               'Mobile phone tower'=3,'Do not know'=4),
                         CS_knowledge_data = 'App Access',
                         CS_downloaded     = 'Download COVIDSafe',
                         CS_downloaded     = c('Yes' = 1, 'No' = 0)
                         #CS_knowledge_data = c('Me'=1,'Aus Gov'=2,'Contact Tracers'=3,
                         #                      'Public'=4,'Scientists'=5,'Do not know'=6)
                         
                         )
  

  # Add Age Bins
  # This acts to help preserve privacy and allows easy plotting:
  #    e.g., ggplot(Data, aes(x = Agebins) ) + geom_bar()
  Agebin = c('< 20', '20-29', '30-39','40-49','50-59','60-69','70-79','80+')
  Data %<>% mutate(Agebins = case_when(
    Age  < 20 ~ Agebin[1],
    Age >= 20 & Age < 30 ~ Agebin[2],
    Age >= 30 & Age < 40 ~ Agebin[3],
    Age >= 40 & Age < 50 ~ Agebin[4],
    Age >= 50 & Age < 60 ~ Agebin[5],
    Age >= 60 & Age < 70 ~ Agebin[6],
    Age >= 70 & Age < 80 ~ Agebin[7],
    Age >= 80  ~ Agebin[8] ) ) %>% 
    apply_labels(Agebins = 
                   c('< 20' = 1, '20-29' = 2, '30-39' = 3,
                     '40-49' = 4,'50-59' = 5,'60-69' = 6,
                     '70-79' = 7,'80+' = 8))
  
  # Create WorldView Variable
  Data$WorldView = Data %>% select(c(wv_freemarket_best, wv_.freemarket_lim, wv_lim_gov)) %>% apply(.,1, mean, na.rm=TRUE)
  
  # Composite score for COVID risk
  Data$COVIDrisk <- Data %>% select(c(COVID_gen_harm,COVID_pers_harm,COVID_pers_concern,COVID_concern_oth)) %>% apply(.,1, mean, na.rm=TRUE)
  
  # Composite score for government trust
  Data$govtrust <- Data %>% select(starts_with("trus")) %>% apply(.,1, mean, na.rm=TRUE)
  
  return( list(Data = Data, 
               CleaningProcedure = RemovedParticipants, 
               StartDate = StartDate,
               EndDate   = EndDate,
               RawData   = RawData) )
  
  
}

# Merge Waves 1 and 2 Datasets
# MergeWaves = function(W1, W2, addID){
#   if (missing(addID)){addID = TRUE}
#   Missing = setdiff(names(W2), names(W1))
#   W1[Missing] = NA
#   W1 = W1[colnames(W2)]
#   if (addID){
#     W1 %<>% mutate(Wave = 1, WaveN = as.factor('Wave 1'))
#     W2 %<>% mutate(Wave = 2, WaveN = as.factor('Wave 2'))
#   }
#   MergedDF = rbind(W1, W2)
#   return(MergedDF)
# }

# MergeWaves = function(W1, W2, addID){
#   if (missing(addID)){addID = TRUE}
#   Missing1 = setdiff(names(W2), names(W1))
#   Missing2 = setdiff(names(W1), names(W2))
#   W1[Missing1] = NA
#   W2[Missing2] = NA
#   if (addID){
#     W1 %<>% mutate(Wave = 1, WaveN = as.factor('Wave 1'))
#     W2 %<>% mutate(Wave = 2, WaveN = as.factor('Wave 2'))
#   }
#   W2 = W2 %>% select(colnames(W1))
#   MergedDF = rbind(W1, W2)
#   return(MergedDF)
# }

MergeWaves = function(W1, W2, addID1, addID2){
  if (missing(addID1)){addID1 = FALSE}
  Missing1 = setdiff(names(W2), names(W1))
  Missing2 = setdiff(names(W1), names(W2))
  W1[Missing1] = NA
  W2[Missing2] = NA
  if (addID1 != FALSE){
    W1 %<>% mutate(Wave = addID1, WaveN = as.factor(paste0('Wave ',addID1)))
    W2 %<>% mutate(Wave = addID2, WaveN = as.factor(paste0('Wave ',addID2)))
  }
  W2 = W2 %>% select(colnames(W1))
  MergedDF = rbind(W1, W2)
  return(MergedDF)
}

RankFigure = function(Data, ColStartsWith, Qids, OrderBy, Title ){
  W = Data %>% select(starts_with(ColStartsWith))
  K = ncol(W)
  W = W[rowSums(!is.na(W)) == K,]
  M = matrix(, nrow = K, ncol = K)
  
  m = M
  for (i in 1:K ){
    for (k in 1:K ){
      M[i,k] = sum(W[,k] == i)
    }
  }
  
  M = M / nrow(W) * 100
  
  for (i in 1:K ){
    for (k in 2:K ){
      M[i,k] =  sum(M[i,k-1], M[i,k]) 
    }
  } 
  M = as.data.frame(round(M,2))
  M$Names = Qids
  
  Cnames = c()
  for (i in 1:K){
    Cnames = c(Cnames, as.character(i))
  }
  Cnames = c(Cnames, 'Names')
  colnames(M) = Cnames
  M = melt(M, id='Names')
  
  colnames(M)[3] = 'Percentage'
  
  m = M %>% filter(variable == OrderBy)
  Qids = m$Names[order(m$Percentage)]
  M$Names = factor(M$Names, levels= Qids )
  
  p = ggplot(data =  M, mapping = aes(x = variable, y = Names)) +
    geom_tile(aes(fill = Percentage), colour = "gray") +
    geom_text(aes(label = paste0(sprintf("%1.0f",Percentage),'%') ), vjust = 1) +
    scale_fill_gradient(low = "white", high = "steelblue3") + 
    labs(title = Title, x = paste0('Cumulative Rank Ordered Responses \n 1 = First Choice. ',K,' = Last Choice'), y = '') +
    scale_y_discrete(expand = c(0,0) ) + scale_x_discrete(expand = c(0,0) ) + 
    guides(fill = guide_colourbar(ticks = FALSE)) + 
    theme(legend.position = 'none')
  
  return(p)
}

RankOrder = function(Data, ColStartsWith, Qids, OrderBy, Title, TxtSize, TitleSize, LabSize ){
  if (missing(TxtSize)){TxtSize = 4}
  if (missing(TitleSize)){TitleSize = 13}
  if (missing(LabSize)){LabSize = 11}
  W = Data %>% select(starts_with(ColStartsWith))
  K = ncol(W)
  W = W[rowSums(!is.na(W)) == K,]
  M = matrix(, nrow = K, ncol = K)
  
  #m = M
  for (i in 1:K ){
    for (k in 1:K ){
      M[i,k] = sum(W[,k] == i)
    }
  }
  
  M = M / nrow(W) * 100
  pdf = M
  for (i in 1:K ){
    for (k in 2:K ){
      M[i,k] =  sum(M[i,k-1], M[i,k])
    }
  }
  pdf = as.data.frame(round(pdf,2))
  M = as.data.frame(round(M,2))
  M$Names = Qids
  pdf$Names = Qids
  
  Cnames = c()
  for (i in 1:K){
    Cnames = c(Cnames, as.character(i))
  }
  Cnames = c(Cnames, 'Names')
  colnames(M) = Cnames
  colnames(pdf) = Cnames
  M = melt(M, id='Names')
  pdf = melt(pdf, id='Names')
  
  colnames(M)[3] = 'Percentage'
  colnames(pdf)[3] = 'Percentage'
  
  m = M %>% filter(variable == OrderBy)
  Qids = m$Names[order(m$Percentage)]
  M$Names = factor(M$Names, levels= Qids )
  
  m = pdf %>% filter(variable == OrderBy)
  Qids = m$Names[order(m$Percentage)]
  pdf$Names = factor(pdf$Names, levels= Qids )
  
  Xlabels = c('Most\nImportant', rep('',K-2), 'Least\nImportant')
  
  p = ggplot(data = M, mapping = aes(x = variable, y = Names)) +
    geom_tile(aes(fill = Percentage),  width = 1, height = 1) +
    geom_text(aes(label = paste0(sprintf("%1.0f",Percentage),'%') ), vjust = 1, size = TxtSize) +
    scale_fill_gradient(low = "gray99", high = "steelblue3") + 
    #labs(title = Title, x = paste0('Cumulative Rank Ordered Responses \n 1 = First Choice. ',K,' = Last Choice'), y = '') +
    labs(title = Title, x = paste0('Cumulative Rank Ordered Responses'), y = '') +
    scale_y_discrete(expand = c(0,0) ) + #scale_x_discrete(expand = c(0,0) ) + 
    guides(fill = guide_colourbar(ticks = FALSE)) + 
    theme(axis.text.y = element_text(size = 12, colour = 'black'),
          axis.text.x = element_text(size = 12, colour = 'black'), 
          legend.position = 'none',
          axis.title=element_text(size=14,face="bold"),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_blank()) + 
    scale_x_discrete(labels= Xlabels, expand = c(0,0))
  
  p2 = ggplot(data = M, mapping = aes(x = variable, y = Names)) +
    geom_tile(aes(fill = Percentage),  width = 1, height = 1) +
    geom_text(aes(label = paste0(sprintf("%1.0f",pdf$Percentage),'%') ), vjust = 1, size = TxtSize) +
    scale_fill_gradient(low = "gray99", high = "steelblue3") + 
    #labs(title = Title, x = paste0('Cumulative Rank Ordered Responses \n 1 = First Choice. ',K,' = Last Choice'), y = '') +
    labs(title = Title, x = paste0('Rank Ordered Responses'), y = '', size = 1) +
    scale_y_discrete(expand = c(0,0) ) + #scale_x_discrete(expand = c(0,0) ) + 
    guides(fill = guide_colourbar(ticks = FALSE)) + 
    theme(axis.text.y = element_text(size = LabSize, colour = 'black'),
          axis.text.x = element_text(size = LabSize, colour = 'black'), 
          plot.title = element_text(size=TitleSize),
          legend.position = 'none',
          axis.title=element_text(size=LabSize,face="bold"),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_blank()) + 
    scale_x_discrete(labels= Xlabels, expand = c(0,0))
  
  return(list(CDF = p, PDF = p2, cdf = M, pdf = pdf))
}

# Function to clean the raw data from Waves 1 and 2 of the Government Tracking Study.
# Takes a file path argument & an optional argument for Country ID (e.g., 9 was Australia in Qualtrics).
CleanSpainData = function (CSVfile, CountryID ) {
  if( missing(CountryID) ){ CountryID = 0 } # Default 0: Skips Country ID Check. (Australia = 9).
  
  # Load in Raw CSV File
  Data = read.csv(CSVfile) 
  RawData = Data
  RawN = nrow(Data)
  
  if ('ï..StartDate' %in% colnames(Data)){ colnames(Data)[colnames(Data)=='ï..StartDate'] = 'StartDate' }
  
  # Fix 'fatalaties' to 'fatalities' in the column names
  colnames(Data) = gsub('COVID_fatalaties', 'COVID_fatalities', colnames(Data))
  
  if ('COVID_fatalities_1' %in% colnames(Data) ){
    Data$COVID_fatalities_6 = Data$COVID_fatalities_7
    Data$COVID_fatalities_7 = Data$COVID_fatalities_8
    Data$COVID_fatalities_8 = Data$COVID_fatalities_9
    Data$COVID_fatalities_9 = Data$COVID_fatalities_10
    Data %<>% select(-'COVID_fatalities_10')
  }
  
  # Find the Start and End of collection
  StartDate = format( min( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  EndDate   = format( max( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  
  if (is.na(StartDate)){
    StartDate = format( min( as.Date(Data$StartDate, '%d/%m/%y'), na.rm = T ), '%d-%m-%Y')
    EndDate   = format( max( as.Date(Data$StartDate, '%d/%m/%y'), na.rm = T ), '%d-%m-%Y')
  }
  
  ## Check if the task includes Bluetooth Tracking Condition ##
  if ( 'bluetooth' %in% Data$scenario_type | 'att_check_bt' %in% colnames(Data)  ){ Btooth = TRUE }else{ Btooth = FALSE }
  
  # Fix age column name if it hasn't been already.
  if ('age_4' %in% colnames(Data) ){ Data %<>% rename(Age = age_4) }
  # Use 'Age' over 'age' due to grep search later. The capital removes any
  # confusion with the age in languAGE.
  if ('age' %in% colnames(Data) ){ Data %<>% rename(Age = age) }
  
  ## Filter Data by Country of Residence ##
  if ( CountryID != 0 & 'country' %in% colnames(Data) ){
    Data %<>% filter( country == CountryID  )
  }
  Del.Country = RawN - nrow(Data)
  
  
  ## Filter Data by Age ##
  Data %<>% filter( Age >= 18 )
  Del.Age = RawN - (nrow(Data) + Del.Country)
  
  
  ## Filter by Incomplete & Attention Check ##
  # Incomplete: defined as an NA value in both attention check columns
  # Attenion Fail: defined as any value not equal to 1 in either attention check columns
  if ( Btooth ){
    Del.Incomplete = Data %>% select( att_check_bt) %>% is.na %>% rowSums == 2 
    Del.Incomplete = sum(Del.Incomplete)
    Del.Attention  = Data %>% select( att_check_bt) %>% rowSums(na.rm = TRUE) != 1 %>% sum
    Del.Attention  = sum(Del.Attention) - Del.Incomplete
    Data %<>% filter( att_check_bt == 1 )
  } else {
    Del.Incomplete = Data %>% filter( is.na(att_check)) %>% nrow
    Del.Attention  = Data %>% filter( att_check != 1 )  %>% nrow
    Data %<>% filter( att_check == 1 )
  }
  
  ## Delete Duplicate Prolific IDs, if prolific was used ## 
  if ('psid' %in% colnames(Data)){ 
    Del.Duplicates = sum( duplicated(Data$psid) == TRUE )
    Data %>% filter( duplicated(psid) == FALSE )
  } else {Del.Duplicates = 0}
  
  # Create a dataframe describing the cleaning steps
  RemovedParticipants = data.frame( 'InitialPs'         = RawN,
                                    'RemovedCountry'    = Del.Country, 
                                    'RemovedAge'        = Del.Age, 
                                    'RemovedAttention'  = Del.Attention,
                                    'RemovedIncomplete' = Del.Incomplete,
                                    'RemovedDuplicate'  = Del.Duplicates,
                                    'RemainingPs'       = nrow(Data) )
  
  # Shorten the dataframe into a usable format + Add Worldview Scores
  Data = Data[, grep("Age", colnames(Data)) : length( colnames(Data) ) ]
  
  # Delete extra columns
  Del.ColNames = c( 'free_text', 'SC0', 'psid', 'PID' )
  Data = Data[,!colnames(Data) %in% Del.ColNames]
  
  # Reverse Score Freemarket Variable
  Data %<>%  mutate(wv_.freemarket_lim = revscore(wv_.freemarket_lim,7))
  
  
  # Apply Labels & Factor Values to common items
  Data %<>% apply_labels(gender = "Gender",
                         gender = c("Men" = 1, "Women" = 2, "Other" = 3, "Prefer not to say" = 4),
                         COVID_pos_others = "Tested pos someone I know",
                         COVID_pos_others = c("Yes" = 1, "No" = 0),
                         COVID_lost_job = "I lost my job",
                         COVID_lost_job = c("Yes" = 1, "No" = 0)
                         #COVID_info_source= "Information source",
                         #COVID_info_source = c("Newspaper (printed or online)" = 1, "Social media" = 2, 
                        #                       "Friends/family" = 3, "Radio" = 4, "Television" = 5, 
                        #                       'Other' = 6, 'Do not follow' = 7)
                         )
  
  # Rename scenarios to be more informative, but keep old names for reference.
  #Data %<>% mutate(Scenario = str_replace_all(scenario_type, 
  #                                            c('mild'      = 'Government App',
  #                                              'severe'    = 'Telecommunication',
  #                                              'bluetooth' = 'Bluetooth') ) )
  
  # Add Bluetooth Scenario Variables
  if ( Btooth ){
    Data %<>% apply_labels(mobileuse_sev = "Use mobile",
                           mobileuse_sev = c("Yes" = 1, "No" = 0),
                           smartphoneuse_mildbt = "Use smartphone",
                           smartphoneuse_mildbt = c("Yes" = 1, "No" = 0))
  }
  
  
  # Add code for Austrlian Specific Variables - can be modified by country
  Data %<>% apply_labels(education = "Education",
                           education = c("Basic studies" = 1, 
                                         "Bachelor/COU" = 2, 
                                         "FP" = 3,
                                         'University degree' = 11),
                           region = 'Region')
                           #region = c("NSW"=1, "VIC"=2, "QLD"=3, "SA"=4, 
                          #           "WA"=5, "NT"=6, "TAS"=7, "ACT"=8, "Other"=9))
  
  
  # Add Age Bins
  # This acts to help preserve privacy and allows easy plotting:
  #    e.g., ggplot(Data, aes(x = Agebins) ) + geom_bar()
  Agebin = c('< 20', '20-29', '30-39','40-49','50-59','60-69','70-79','80+')
  Data %<>% mutate(Agebins = case_when(
    Age  < 20 ~ Agebin[1],
    Age >= 20 & Age < 30 ~ Agebin[2],
    Age >= 30 & Age < 40 ~ Agebin[3],
    Age >= 40 & Age < 50 ~ Agebin[4],
    Age >= 50 & Age < 60 ~ Agebin[5],
    Age >= 60 & Age < 70 ~ Agebin[6],
    Age >= 70 & Age < 80 ~ Agebin[7],
    Age >= 80  ~ Agebin[8] ) ) %>% 
    apply_labels(Agebins = 
                   c('< 20' = 1, '20-29' = 2, '30-39' = 3,
                     '40-49' = 4,'50-59' = 5,'60-69' = 6,
                     '70-79' = 7,'80+' = 8))
  
  # Create WorldView Variable
  Data$WorldView = Data %>% dplyr::select(c(wv_freemarket_best, wv_.freemarket_lim, wv_lim_gov)) %>% apply(.,1, mean, na.rm=TRUE)
  
  # Composite score for COVID risk
  Data$COVIDrisk <- Data %>% select(c(COVID_gen_harm,COVID_pers_harm,COVID_pers_concern,COVID_concern_oth)) %>% apply(.,1, mean, na.rm=TRUE)
  
  return( list(Data = Data, 
               CleaningProcedure = RemovedParticipants, 
               StartDate = StartDate,
               EndDate   = EndDate,
               RawData   = RawData) )
}


# Function to clean the raw data from Waves 1 and 2 of the Government Tracking Study.
# Takes a file path argument & an optional argument for Country ID (e.g., 9 was Australia in Qualtrics).
CleanUKData = function (CSVfile, CountryID ) {
  if( missing(CountryID) ){ CountryID = 0 } # Default 0: Skips Country ID Check. (Australia = 9).
  
  # Load in Raw CSV File
  Data = read.csv(CSVfile) 
  RawData = Data
  RawN = nrow(Data)
  
  if ('ï..StartDate' %in% colnames(Data)){ colnames(Data)[colnames(Data)=='ï..StartDate'] = 'StartDate' }
  
  # Fix 'fatalaties' to 'fatalities' in the column names
  colnames(Data) = gsub('COVID_fatalaties', 'COVID_fatalities', colnames(Data))
  
  if ('COVID_fatalities_1' %in% colnames(Data) ){
    Data$COVID_fatalities_6 = Data$COVID_fatalities_7
    Data$COVID_fatalities_7 = Data$COVID_fatalities_8
    Data$COVID_fatalities_8 = Data$COVID_fatalities_9
    Data$COVID_fatalities_9 = Data$COVID_fatalities_10
    Data %<>% select(-'COVID_fatalities_10')
  }
  
  # Find the Start and End of collection
  StartDate = format( min( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  EndDate   = format( max( as.Date(Data$StartDate, '%Y-%m-%d'), na.rm = T ), '%d-%m-%Y')
  
  if (is.na(StartDate)){
    StartDate = format( min( as.Date(Data$StartDate, '%d/%m/%y'), na.rm = T ), '%d-%m-%Y')
    EndDate   = format( max( as.Date(Data$StartDate, '%d/%m/%y'), na.rm = T ), '%d-%m-%Y')
  }
  
  ## Check if the task includes Bluetooth Tracking Condition ##
  if ( 'bluetooth' %in% Data$scenario_type | 'att_check_bt' %in% colnames(Data)  ){ Btooth = TRUE }else{ Btooth = FALSE }
  
  # Fix age column name if it hasn't been already.
  if ('age_4' %in% colnames(Data) ){ Data %<>% rename(Age = age_4) }
  # Use 'Age' over 'age' due to grep search later. The capital removes any
  # confusion with the age in languAGE.
  if ('age' %in% colnames(Data) ){ Data %<>% rename(Age = age) }
  
  ## Filter Data by Country of Residence ##
  if ( CountryID != 0 & 'country' %in% colnames(Data) ){
    Data %<>% filter( country == CountryID  )
  }
  Del.Country = RawN - nrow(Data)
  
  
  ## Filter Data by Age ##
  Data %<>% filter( Age >= 18 )
  Del.Age = RawN - (nrow(Data) + Del.Country)
  
  
  ## Filter by Incomplete & Attention Check ##
  # Incomplete: defined as an NA value in both attention check columns
  # Attenion Fail: defined as any value not equal to 1 in either attention check columns
  if ( Btooth ){
    Del.Incomplete = Data %>% select( att_check_bt) %>% is.na %>% rowSums == 2 
    Del.Incomplete = sum(Del.Incomplete)
    Del.Attention  = Data %>% select( att_check_bt) %>% rowSums(na.rm = TRUE) != 1 %>% sum
    Del.Attention  = sum(Del.Attention) - Del.Incomplete
    Data %<>% filter( att_check_bt == 1 )
  } else {
    Del.Incomplete = Data %>% filter( is.na(att_check)) %>% nrow
    Del.Attention  = Data %>% filter( att_check != 1 )  %>% nrow
    Data %<>% filter( att_check == 1 )
  }
  
  ## Delete Duplicate Prolific IDs, if prolific was used ## 
  if ('psid' %in% colnames(Data)){ 
    Del.Duplicates = sum( duplicated(Data$psid) == TRUE )
    Data %>% filter( duplicated(psid) == FALSE )
  } else {Del.Duplicates = 0}
  
  # Create a dataframe describing the cleaning steps
  RemovedParticipants = data.frame( 'InitialPs'         = RawN,
                                    'RemovedCountry'    = Del.Country, 
                                    'RemovedAge'        = Del.Age, 
                                    'RemovedAttention'  = Del.Attention,
                                    'RemovedIncomplete' = Del.Incomplete,
                                    'RemovedDuplicate'  = Del.Duplicates,
                                    'RemainingPs'       = nrow(Data) )
  
  # Shorten the dataframe into a usable format + Add Worldview Scores
  Data = Data[, grep("Age", colnames(Data)) : length( colnames(Data) ) ]
  
  # Delete extra columns
  Del.ColNames = c( 'free_text', 'SC0', 'psid', 'PID' )
  Data = Data[,!colnames(Data) %in% Del.ColNames]
  
  # Reverse Score Freemarket Variable
  Data %<>%  mutate(wv_.freemarket_lim = revscore(wv_.freemarket_lim,7))
  
  
  # Apply Labels & Factor Values to common items
  Data %<>% apply_labels(gender = "Gender",
                         gender = c("Men" = 1, "Women" = 2, "Other" = 3, "Prefer not to say" = 4),
                         COVID_pos_others = "Tested pos someone I know",
                         COVID_pos_others = c("Yes" = 1, "No" = 0),
                         COVID_lost_job = "I lost my job",
                         COVID_lost_job = c("Yes" = 1, "No" = 0)
                         #COVID_info_source= "Information source",
                         #COVID_info_source = c("Newspaper (printed or online)" = 1, "Social media" = 2, 
                         #                       "Friends/family" = 3, "Radio" = 4, "Television" = 5, 
                         #                       'Other' = 6, 'Do not follow' = 7)
  )
  
  # Rename scenarios to be more informative, but keep old names for reference.
  #Data %<>% mutate(Scenario = str_replace_all(scenario_type, 
  #                                            c('mild'      = 'Government App',
  #                                              'severe'    = 'Telecommunication',
  #                                              'bluetooth' = 'Bluetooth') ) )
  
  # Add Bluetooth Scenario Variables
  if ( Btooth ){
    Data %<>% apply_labels(mobileuse_sev = "Use mobile",
                           mobileuse_sev = c("Yes" = 1, "No" = 0),
                           smartphoneuse_mildbt = "Use smartphone",
                           smartphoneuse_mildbt = c("Yes" = 1, "No" = 0))
  }
  
  
  # Add code for Austrlian Specific Variables - can be modified by country
  Data %<>% apply_labels(education = "Education",
                         education = c("GCSE" = 1, 
                                       "A levels/VCE" = 2, 
                                       "Apprent/Vocatnl" = 3,
                                       'University' = 4))
  #region = c("NSW"=1, "VIC"=2, "QLD"=3, "SA"=4, 
  #           "WA"=5, "NT"=6, "TAS"=7, "ACT"=8, "Other"=9))
  
  
  # Add Age Bins
  # This acts to help preserve privacy and allows easy plotting:
  #    e.g., ggplot(Data, aes(x = Agebins) ) + geom_bar()
  Agebin = c('< 20', '20-29', '30-39','40-49','50-59','60-69','70-79','80+')
  Data %<>% mutate(Agebins = case_when(
    Age  < 20 ~ Agebin[1],
    Age >= 20 & Age < 30 ~ Agebin[2],
    Age >= 30 & Age < 40 ~ Agebin[3],
    Age >= 40 & Age < 50 ~ Agebin[4],
    Age >= 50 & Age < 60 ~ Agebin[5],
    Age >= 60 & Age < 70 ~ Agebin[6],
    Age >= 70 & Age < 80 ~ Agebin[7],
    Age >= 80  ~ Agebin[8] ) ) %>% 
    apply_labels(Agebins = 
                   c('< 20' = 1, '20-29' = 2, '30-39' = 3,
                     '40-49' = 4,'50-59' = 5,'60-69' = 6,
                     '70-79' = 7,'80+' = 8))
  
  # Create WorldView Variable
  Data$WorldView = Data %>% dplyr::select(c(wv_freemarket_best, wv_.freemarket_lim, wv_lim_gov)) %>% apply(.,1, mean, na.rm=TRUE)
  
  # Composite score for COVID risk
  Data$COVIDrisk <- Data %>% select(c(COVID_gen_harm,COVID_pers_harm,COVID_concern_oth)) %>% apply(.,1, mean, na.rm=TRUE)
  
  return( list(Data = Data, 
               CleaningProcedure = RemovedParticipants, 
               StartDate = StartDate,
               EndDate   = EndDate,
               RawData   = RawData) )
}

# # Function to match two dataframes along a variable (g1, g2) without data loss
# MatchSet = function(D1, D2, g1, g2){
#   data = cbind(D1, D2[match(D1[[g1]], D2[[g2]]),])
#   Uid = unique(D2[[g2]])[!unique(D2[[g2]]) %in% unique(D1[[g1]])]
#   missing = D2[match(Uid, D2[[g2]]),]
#   if (nrow(missing) > 0){
#     data[(nrow(data)+1):(nrow(data)+nrow(missing)),(ncol(D1)+1):(ncol(data))] = missing
#     # Replace NA IDs in g1 column with g2 ids, if any are missing.
#     idx = seq(length(colnames(data)))[colnames(data) %in% c(g1, g2)]
#     if (sum(is.na(data[,idx[1]])) > 0){
#       data[is.na(data[,idx[1]]), idx[1]] = data[is.na(data[,idx[1]]), idx[2]]
#     }
#   }
#   return(data)
# }

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Additional Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERAL PLOTTING THEME - function for simple calling.
windowsFonts("Helvetica" = windowsFont("Helvetica"))
PltTheme = theme(  text=element_text(family="Helvetica"),
                    plot.title = element_text(face = "bold", hjust = 0.5, size = 18, family="Helvetica"), 
                    axis.title = element_text(face = 'bold', size = 16, color='black'),
                    axis.text  = element_text(size=14, color='black'), 
                    axis.line = element_line(colour = 'black', size = .5), 
                    legend.title = element_blank(), legend.position = c(.3, .8),
                    legend.background = element_rect(fill=alpha('white', 0.)),
                    legend.text = element_text(size=14),
                    panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.background = element_blank(),
                    strip.background = element_blank(),
                    strip.text.x = element_text(size = 14)) 

# Colorblind Palette.
#Cblind <- c('#000000',"#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
Cblind = c('black','gray','royalblue4','red3','steelblue1','gold1', 'green3','red','turquoise2')