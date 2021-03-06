library(gsheet)
library(lubridate)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

papers<-gsheet2tbl('https://docs.google.com/spreadsheets/d/1Z_4x3w2SgpOdHQ028IiPEgbB6CSFC0YT3oUymE5UoBE/edit?usp=sharing')


#add some sensible variable names
names(papers)<-c("DateTime", "Tweeter", "Content", "PaperURL", "TweetLink")
papers$DateTime<-mdy_hm(papers$DateTime) 

tidy_papers<-papers %>%
              mutate(Hour=hour(DateTime), 
              			 Year=factor(year(DateTime)),
              			 YearDay=yday(DateTime), 
                     DOW=wday(DateTime,label=TRUE, abbr=TRUE), 
              			 WorkingHours=ifelse(DOW!="Sat" & DOW!="Sun"& Hour>8 & Hour<18, TRUE, FALSE),
                     YearPub=as.numeric(str_extract(Content, "\\d{4}"))) %>%
	                   group_by(Year) %>%
	                   mutate(PaperNum=order(DateTime)) %>%
	                   ungroup()
	           #filter(Year==2016)

#Plot diurnal distribution of tweets
ggplot(tidy_papers, aes(x=Hour))+
  geom_histogram(binwidth = 1, fill="red", col="red", alpha=0.7) +
  theme_bw()+
  ggtitle("Daily")
ggsave(file="diurnal-hist.png", width=4, height=4)

#Plot distribution by day of week
ggplot(tidy_papers, aes(x=DOW))+
  geom_bar( fill="blue", col="blue", alpha=0.7) +
  xlab("")+
  theme_bw()+
  xlab("Day of week")+
  ggtitle("Weekly")
ggsave(file="weekly-hist.png", width=4, height=4)

#Plot distribution of publication years
ggplot(tidy_papers, aes(x=YearPub))+
  geom_histogram(binwidth = 1, fill="green", col="green", alpha=0.7) +
  theme_bw()+
  xlab("Year published")+
  ggtitle("Year of publication")
ggsave(file="yearpub-hist.png", width=4, height=4)

yday_now<-yday(today())
total_papers<-max(tidy_papers$PaperNum)
right_now<-data.frame("YearDay"=yday_now, "PaperNum"=total_papers)
prog_lab<-paste0(yday_now, " days,\n", total_papers, " papers")

#Plot cumulative sum vs time
ggplot(tidy_papers, aes(x=YearDay, y=PaperNum, col=Year))+
  geom_step()+
  xlim(c(1, 366))+
  ylim(c(1, 366))+
  xlab("Day of Year")+
  ylab("Cumulative papers")+
  geom_abline(slope=1, intercept=0, col="gray", lty=2)+
  theme_bw()+
  ggtitle("Progress towards target")
ggsave(file="cumulative.png", width=4, height=4)

ggplot(tidy_papers, aes(y=DOW, x=Hour))+ 
	geom_bin2d(binwidth=c(1, 1)) +
	#scale_fill_gradient(low = "lightgrey",high = "darkgreen")+
	scale_fill_distiller(type="seq", palette="Greens", direction=1)+
	scale_x_continuous(minor_breaks = seq(0, 23, 1), breaks=seq(0, 23, 3)) +
	ylab("Day of week")+
	geom_rect(xmin=9, xmax=18, ymin=1.5, ymax=6.5, fill=NA, colour="blue")+
	theme_bw()
ggsave(file="heatmap.png", width=8, height=2.4)
	
	