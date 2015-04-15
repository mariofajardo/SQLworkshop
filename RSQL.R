###R and SQL section####
#Workshop FAPA April 2015#

#Install and load required packages#

pack<-c('RMySQL','SwissAir','gamclass')
# install.packages(pkgs = pack,dependencies = T)

library(RMySQL)

## Open a connection
drv <- MySQL()
con <- dbConnect(drv,user='root',host='localhost',password='SYDNEY5OIL')

## Submit some statements
dbGetQuery(con, "SHOW DATABASES")
dbSendQuery(con, "USE mario_sandbox")

q1<-dbSendQuery(con, "SELECT * 
           FROM topopoint 
           WHERE topoId=2")
## fetch all elements from the result set
a<-dbFetch(q1)
View(a)
dbDisconnect(con) # Close the connection

####Use another DATABASE####
drv <- MySQL()
con <- dbConnect(drv,user='root',host='localhost',password='SYDNEY5OIL') # Open a connection
dbSendQuery(con, "USE sakila;")
dbGetQuery(con, "SHOW TABLES")
q2<-dbSendQuery(con, "SELECT * 
           FROM language")
b<-dbFetch(q2)
View(b)

dbDisconnect(con) # Close the connection

####Write and Delete dbTables to the server from R ####
# install.packages('SwissAir')
library(SwissAir)
data(AirQual)
?AirQual
View(AirQual)


drv <- MySQL()
con <- dbConnect(drv,user='root',host='localhost',password='SYDNEY5OIL')
dbSendQuery(con, "USE mario_sandbox")
dbWriteTable(con,name = 'Airquality',AirQual,overwrite=T)

dbGetQuery(con, 'SHOW TABLES')
dbRemoveTable(con, "airquality")
dbGetQuery(con, 'SHOW TABLES')

dbDisconnect(con) # Close the connection


####Compare some subsetting operations####
library(gamclass)

data(FARS)
str(FARS)

t1<-proc.time()
subset_R<-FARS[FARS$airbag>29 & FARS$D_injury<3 & FARS$sex==2,]
print(proc.time()-t1)

drv <- MySQL()
con <- dbConnect(drv,user='root',host='localhost',password='SYDNEY5OIL')
dbSendQuery(con, "USE mario_sandbox")
dbWriteTable(con,name = 'FARS',FARS,overwrite=T)

names(FARS)[names(FARS)=='Restraint']<-'Rstrnt'
dbWriteTable(con,name = 'FARS',FARS,overwrite=T)


t1<-proc.time()
subset_RMySQL<-dbGetQuery(con, "SELECT * FROM FARS WHERE airbag>29 AND D_injury<3 AND sex=2 ")
print(proc.time()-t1)
dbDisconnect(con) # Close the connection


####Memory usage####
rm(list = ls())
gc()
memory.size()

data(FARS)
FARS<-rbind(FARS,FARS,FARS,FARS,FARS)
t1<-proc.time()
subset_R<-FARS[FARS$airbag>29 & FARS$D_injury<3 & FARS$sex==2,]
print(proc.time()-t1)

R_MEM<-memory.size()

rm(list = ls()[!ls()=='R_MEM'])
gc()

memory.size()
drv <- MySQL()
con <- dbConnect(drv,user='root',host='localhost',password='SYDNEY5OIL')
dbSendQuery(con, "USE mario_sandbox")

t1<-proc.time()
subset_RMySQL<-dbGetQuery(con, "SELECT * FROM FARS WHERE airbag>29 AND D_injury<3 AND sex=2 ")
print(proc.time()-t1)

R_MySQL<-memory.size()

barplot(c(R_MEM,R_MySQL),names.arg = c('R','RMySQL'),main='Memory usage')

dbRemoveTable(con, "fars")
dbDisconnect(con) # Close the connection

#end#
