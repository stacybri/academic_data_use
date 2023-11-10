#This file pulls a variety of indicators from the World Development Indicators for use in analyzing relationship between data use in academia and other development outcomes


# Note: If you rerun this file, the correlates data will be over-written and the results may no longer exactly replicate.

library(tidyverse)
library(here)
library(wbstats)

raw_data <- here("01_raw_data")

#get a list of the correlates from the WDI.
correlate <- c("SP.POP.TOTL","NY.GDP.MKTP.PP.KD",'IQ.SPI.OVRL','NY.GDP.PCAP.PP.KD',
               'IQ.SPI.PIL1','IQ.SPI.PIL2','IQ.SPI.PIL3',
               'IQ.SPI.PIL4','IQ.SPI.PIL5',
               'IQ.SCI.OVRL','NV.IND.MANF.ZS', 'NV.AGR.TOTL.ZS','NE.TRD.GNFS.ZS', 'HD.HCI.OVRL', 'HD.HCI.LAYS',
               'SE.PRM.ENRR','BN.CAB.XOKA.GD.ZS', 'CC.EST', "GE.EST", 'PV.EST', "RQ.EST", "RL.EST", 
               "VA.EST", "BX.KLT.DINV.WD.GD.ZS", "SI.POV.DDAY", "SI.POV.GINI",'SE.TER.CUAT.MS.ZS','SE.TER.ENRR')


correlates_df <- wbstats::wb_data(
   indicator=correlate,
   country = 'countries_only',
   start_date=2000,
   end_date=2020
   ) %>%
   group_by(iso3c) %>%
   mutate(across(correlate,
                 ~if_else(is.na(.),1,0),
                 .names="{.col}_imp_tag")) %>% #add tag for data that is imputed
   fill(correlate, .direction="downup") %>%
   #manual fix for vietnam, Turkey, Czechia which changed their names
   filter(!(country %in% c("Vietnam", "Turkey", "Czech Republic"))) %>%
   mutate(WGI.OVL=(CC.EST + GE.EST + PV.EST + RQ.EST + RL.EST + VA.EST)/6
          )  %>%
   ungroup()  %>%
   left_join(read_csv(paste0(raw_data, "/SPI_index.csv")) %>% select(iso3c, date, starts_with("SPI.")))

#write to excel
 write_excel_csv(correlates_df,
                 paste0(raw_data, "/correlates_df.csv"))
 
 

 