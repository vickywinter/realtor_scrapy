
library(magrittr)
library(dplyr)
realtor=read.csv('~/Documents/NYC/Scrapy/Realtor/Realtor/Realtor_listing_new.csv',stringsAsFactors = FALSE)

realtor$lot_ft<-as.numeric(gsub(",","",realtor$lot_ft))
realtor$lot_ft<-ifelse(as.numeric(realtor$lot_ft)<10,as.numeric(realtor$lot_ft)*42560,as.numeric(realtor$lot_ft))
realtor$area_ft<-as.numeric(gsub(",","",realtor$lot_ft))

realtor$bath_half[is.na(realtor$bath_half)] <- 0
realtor$bath=as.numeric(realtor$bath_full)+realtor$bath_half*0.5
realtor$beds<-as.integer(realtor$beds)
realtor$days_on_market<-as.integer(realtor$days_on_market)
realtor$lot_ft<-ifelse(as.numeric(realtor$lot_ft)<10,as.numeric(realtor$lot_ft)*42560,as.numeric(realtor$lot_ft))

#realtor$sold_date=as.Date(realtor$sold_date,'%B %d,%Y')
realtor$sold_date=as.Date(realtor$sold_date,'%d-%b-%y')
realtor<-mutate(realtor,structure=paste(beds,'B',bath,'B'))

realtor$school1=as.numeric(realtor$school1)
realtor$school2=as.numeric(realtor$school2)
realtor$school3=as.numeric(realtor$school3)
realtor$school_rate=round(rowMeans(realtor[,12:14],na.rm=TRUE))

realtor$school_max <- apply(realtor[,12:14], 1, max,na.rm=TRUE)
realtor$school_min <- apply(realtor[,12:14], 1, min,na.rm=TRUE)
realtor$beds=as.integer(realtor$beds)
realtor<-filter(realtor,!is.na(realtor$beds))
realtor$days_on_market=as.integer(realtor$days_on_market)

realtor$price_ft<-as.numeric(gsub(",","",realtor$price_ft))
realtor$price_ft<-as.numeric(realtor$price_ft)
realtor$zip_code<-as.factor(realtor$zip_code)
#install.packages('corrplot')
library(corrplot)
realtor2<-filter(realtor,school_max==7)
realtor1<-as.data.frame(realtor2[,c('sold_price','bath','beds','days_on_market','built_year','area_ft','lot_ft','school_rate','school_max','school_min')])
realtor1<-realtor1[complete.cases(realtor1), ]


#test<-model.matrix(sold_price ~ ., realtor)
cor <- cor(realtor1)
corrplot(cor,method="number")


ggplot()+
  geom_boxplot(realtor,mapping=aes(x=school_rate,y=price_ft,group=school_rate))

realtor$price_ft=as.numeric(realtor$price_ft)
realtor$zip_code=as.factor(realtor$zip_code)
price_zip<-realtor %>% group_by(zip_code) %>%
  summarize(avg_price_ft=median(price_ft,na.rm=TRUE),number=n(),avg_school_rate=median(school_rate,na.rm=TRUE)) %>%
  filter(!is.na(zip_code))
library(ggplot2)


ggplot()+
  geom_bar(price_zip,mapping=aes(x=zip_code,y=number,fill="red"),stat='identity')+
  geom_line(price_zip,mapping=aes(x=zip_code,y=avg_price_ft/50,group = 1))+
  geom_point(price_zip,mapping=aes(x=zip_code,y=avg_price_ft/50,group = 1))+
  geom_line(price_zip,mapping=aes(x=zip_code,y=avg_school_rate,group = 1),colour='#000099')+
  geom_point(price_zip,mapping=aes(x=zip_code,y=avg_school_rate,group = 1),colour='#000099')+
  scale_y_continuous(sec.axis= sec_axis(~.*50, name="average price/ft"))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  geom_hline(yintercept = 14,colour="#990000", linetype="dashed")


price_inc_zip1<-realtor %>% 
  filter(!is.na(zip_code) & property_type=='Single Family Home')%>%
  group_by(zip_code) %>%
  summarize(sold_date_min=min(sold_date),sold_date_max=max(sold_date)) 
  

price_inc_zip2<-realtor %>% 
  filter(!is.na(zip_code) & property_type=='Single Family Home')%>%
  group_by(zip_code,sold_date) %>%
  summarize(avg_price_ft=median(price_ft,na.rm=TRUE)) 

Prince_inc_zip<-merge(price_inc_zip1,price_inc_zip2,by.x=c('zip_code','sold_date_min'),by.y=c('zip_code','sold_date'),all.x=TRUE)
Prince_inc_zip<-merge(Prince_inc_zip,price_inc_zip2,by.x=c('zip_code','sold_date_max'),by.y=c('zip_code','sold_date'),all.x=TRUE)
Prince_inc_zip<-Prince_inc_zip %>% mutate(rate_incr=(avg_price_ft.y-avg_price_ft.x)/avg_price_ft.x)


ggplot(Prince_inc_zip,aes(x=zip_code,y=rate_incr))+
  geom_bar(stat='identity')


price_room<-realtor %>% group_by(beds,bath) %>%
  summarize(avg_price_ft=mean(price_ft,na.rm=TRUE),number=n())%>%
  filter(beds!=0) %>%
  mutate(structure=paste(beds,'B',bath,'B'))

ggplot()+
  geom_bar(price_room,mapping=aes(x=structure,y=number,fill="green"),stat='identity')+
  geom_line(price_room,mapping=aes(x=structure,y=avg_price_ft/10,group = 1))+
  geom_point(price_room,mapping=aes(x=structure,y=avg_price_ft/10,group = 1))+
  scale_y_continuous(sec.axis= sec_axis(~.*10, name="average price/ft"))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



price_inc_str1<-realtor %>% 
  filter(!is.na(structure) & property_type=='Condo/Townhome/Row Home/Co-Op')%>%
  group_by(structure) %>%
  summarize(sold_date_min=min(sold_date),sold_date_max=max(sold_date)) 


price_inc_str2<-realtor %>% 
  filter(!is.na(structure)& property_type=='Condo/Townhome/Row Home/Co-Op')%>%
  group_by(structure,sold_date) %>%
  summarize(avg_price_ft=median(sold_price,na.rm=TRUE)) 

Prince_inc_str<-merge(price_inc_str1,price_inc_str2,by.x=c('structure','sold_date_min'),by.y=c('structure','sold_date'),all.x=TRUE)
Prince_inc_str<-merge(Prince_inc_str,price_inc_str2,by.x=c('structure','sold_date_max'),by.y=c('structure','sold_date'),all.x=TRUE)
Prince_inc_str<-Prince_inc_str %>% mutate(rate_incr=(avg_price_ft.y-avg_price_ft.x)/avg_price_ft.x)


ggplot(Prince_inc_str,aes(x=structure,y=rate_incr))+
  geom_bar(stat='identity')+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




time_zip<-realtor[,c("zip_code","price_ft","sold_date",'structure')]

time_zip<- realtor %>% group_by(zip_code,sold_date,structure) %>% 
  summarize(med_price_ft=median(sold_price, na.rm=TRUE))%>%
  filter(!is.na(zip_code) & structure=='3 B 2 B' & zip_code %in% c(95127,95123,95136))


library(ggplot2)

ggplot(time_zip,aes(x=sold_date,y=med_price_ft,group=zip_code,color=zip_code))+
  #geom_line()+geom_point()+
  geom_smooth(method = 'loess')



time_zip2<- realtor %>% group_by(zip_code,sold_date,structure) %>% 
  summarize(med_price_ft=median(price_ft, na.rm=TRUE))%>%
  filter(!is.na(zip_code) & structure=='3 B 2 B' & zip_code %in% c(95127,95123,95136))

ggplot(time_zip2,aes(x=sold_date,y=med_price_ft,group=zip_code,color=zip_code))+
  #geom_line()+geom_point()+
  geom_smooth(method = 'loess')

time_price <- realtor %>%
  #filter(structure=='3 B 2 B')%>% 
  group_by(sold_date, property_type) %>%
  summarize(median_price=median(sold_price,na.rm=TRUE)) %>%
  filter(property_type!='Not Available')
  

ggplot(time_price,aes(x=sold_date,y=median_price,group=property_type,color=property_type))+
  geom_line()


test<- filter(realtor,property_type=='Multi-Family Home')
