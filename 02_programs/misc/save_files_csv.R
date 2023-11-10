

library(tidyverse)
library(jsonlite)
library(here)

dir <- here()

seedling <- 7215887
set.seed(seedling)

excluded_fields <- c('Biology','Chemistry', 'Engineering', 'Physics','Materials Science', 'Geology', 'Art')

#save the json files to csv and exclude relevant fields
csv_saver <- function(file) {
  gc()
  
  #Read in the json files and then sample a set of articles.
  
  #load a json file.
  
  sample_frame <- stream_in(file(paste0(dir, "/01_raw_data/metadata/included/metadata_",file,".jsonl")))
  
  
  
  
  sample_restricted <- sample_frame %>%
    filter(!is.na(abstract)) %>%  
    filter(year>2000) %>% #keep just recent articles
    mutate(
      group_name=case_when( #specify  for each field type. 
        grepl('Economics', mag_field_of_study)  ~ 'Economics',
        grepl('Political Science', mag_field_of_study)  ~ 'Political Science',
        grepl('Business', mag_field_of_study)  ~ 'Business',
        grepl('Sociology'	, mag_field_of_study)  ~ 'Sociology',
        grepl('Medicine', mag_field_of_study) ~ 'Medicine',
        grepl('Computer Science', mag_field_of_study)  ~ 'Computer Science',
        grepl('Math'	, mag_field_of_study)  ~ 'Math',
        grepl('Psychology', mag_field_of_study)	 ~ 'Psychology',
        grepl('Geography'	, mag_field_of_study)  ~ 'Geography',
        grepl('History'	, mag_field_of_study)  ~ 'History',
        grepl('Philosophy'	, mag_field_of_study)  ~ 'Philosophy',
        grepl('Biology', mag_field_of_study) ~ 'Biology', #excluded
        grepl('Chemistry', mag_field_of_study)  ~ 'Chemistry', #excluded
        grepl('Engineering', mag_field_of_study)  ~ 'Engineering', #excluded	
        grepl('Physics', mag_field_of_study)	 ~ 'Physics', #excluded
        grepl('Material Science', mag_field_of_study)  ~ 'Material Science', #excluded
        grepl('Geology'	, mag_field_of_study)  ~ 'Geology', #excluded
        grepl('Environmental Science'	, mag_field_of_study) ~ 'Environmental Science', #excluded
        grepl('Art'	, mag_field_of_study)  ~ 'Art', #excluded
        TRUE ~ 'Other'),
      
      sample_share=case_when( #specify the fraction of the sample for each field type.  Oversample development fields
        group_name=='Medicine' ~ .15,
        group_name=='Biology' ~ 0, #excluded
        group_name=='Chemistry'  ~ 0, #excluded
        group_name=='Engineering'  ~ 0, #excluded	
        group_name=='Computer Science'  ~ 0, #excluded
        group_name=='Physics'	 ~ 0, #excluded
        group_name=='Material Science'  ~ 0, #excluded
        group_name=='Math'	  ~ 0, #excluded
        group_name=='Psychology'	 ~ .15,
        group_name=='Economics'  ~ .25,
        group_name=='Political Science'  ~ .25,
        group_name=='Business'  ~ .10,
        group_name=='Geology'	  ~ 0, #excluded
        group_name=='Sociology'	  ~ .10,
        group_name=='Geography'	  ~ 0, #excluded
        group_name=='Environmental Science'	 ~ 0, #excluded
        group_name=='Art'	  ~ 0, #excluded
        group_name=='History'	  ~ 0, #excluded
        group_name=='Philosophy'	  ~ .0, #excluded
        TRUE ~ 0)
    )  %>%
    filter(sample_share>0)  #remove excluded fields

  
  
  write_excel_csv(sample_restricted, file=paste0(dir, "/03_output/csv/metadata_",file,".csv"))
}

csv_saver(0)
csv_saver(1)
csv_saver(2)
csv_saver(3)
csv_saver(4)
csv_saver(5)
csv_saver(6)
csv_saver(7)
csv_saver(8)
csv_saver(9)
csv_saver(10)
