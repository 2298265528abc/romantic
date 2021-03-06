library(caret)
library(plyr)
library(forecast)
library(TSA)
#用户信息表
user_profile=read.csv("data/user_profile_table.csv",fileEncoding="UTF-8")
#用户申购赎回数据表 
user_balance=read.csv("data/user_balance_table.csv")
user_balance$report_date=as.Date(as.character(user_balance$report_date),format="%Y%m%d")
for(i in 15:18){
        user_balance[is.na(user_balance[,i]),i]=0
}
for(i in 3:18){
        user_balance[,i]=as.numeric(user_balance[,i])
}
#按日期排序
temp=order(user_balance$report_date)
user_balance=user_balance[temp,]

#收益率表
interest=read.csv("data/mfd_day_share_interest.csv")
#拆借率
shibor=read.csv("data/mfd_bank_shibor.csv")

####### tempData ################
#myBigTable=read.csv("tempData/myBigTable.csv")
#mySmallTable=ddply(myBigTable[,-1],.(sex,city,constellation),colwise(mean))
######################  LET THE HACKING BEGIN #############

###################第八次提交，LET'S HARDCODING!!!!!!!!
Tot=ddply(user_balance,.(report_date),function(D){
       colwise(sum)(D[,c(-1,-2)])

})
Tot=Tot[225:427,]
for(i in 2:17){
        plot(Tot[,i],type="l",ylab=i)
}

total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(Tot[,i],frequency=7,start=c(1,7))
        myStl=stl(sx,s.window="periodic",robust=TRUE)
        myPred=forecast(myStl,h=30)
        total_Pred[,i]=myPred$mean
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot)

temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

total_Pred$report_date=sep2

P=total_Pred$purchase_bal_amt+total_Pred$purchase_bank_amt+total_Pred$share_amt
R=total_Pred$tftobal_amt+total_Pred$tftocard_amt+total_Pred$category1+total_Pred$category2+total_Pred$category3+total_Pred$category4

out=data.frame(sep2,P,R)
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])
write.table(out,"result/eighth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)





###################第九次提交，是第八次的分了男女
nv=user_profile$user_id[user_profile$sex==0]
nan=user_profile$user_id[user_profile$sex==1]
user_balance_nv=user_balance[user_balance$user_id%in% nv,]
user_balance_nan=user_balance[user_balance$user_id%in% nan,]



Tot=ddply(user_balance_nan,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
        
})
Tot=Tot[225:427,]
for(i in 2:17){
        plot(Tot[,i],type="l",ylab=i)
}

total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(Tot[,i],frequency=7,start=c(1,7))
        myStl=stl(sx,s.window="periodic",robust=TRUE)
        myPred=forecast(myStl,h=30)
        total_Pred[,i]=myPred$mean
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot)
Pnan=total_Pred$purchase_bal_amt+total_Pred$purchase_bank_amt+total_Pred$share_amt
Rnan=total_Pred$tftobal_amt+total_Pred$tftocard_amt+total_Pred$category1+total_Pred$category2+total_Pred$category3+total_Pred$category4

Tot=ddply(user_balance_nv,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
        
})
Tot=Tot[225:427,]
for(i in 2:17){
        plot(Tot[,i],type="l",ylab=i)
}

total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(Tot[,i],frequency=7,start=c(1,7))
        myStl=stl(sx,s.window="periodic",robust=TRUE)
        myPred=forecast(myStl,h=30)
        total_Pred[,i]=myPred$mean
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot)
Pnv=total_Pred$purchase_bal_amt+total_Pred$purchase_bank_amt+total_Pred$share_amt
Rnv=total_Pred$tftobal_amt+total_Pred$tftocard_amt+total_Pred$category1+total_Pred$category2+total_Pred$category3+total_Pred$category4



temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")
out=data.frame(sep2,Pnan+Pnv,Rnan+Rnv)
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])
write.table(out,"result/nineth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)



#############第11次提交，把第8次log变换试一下
Tot=ddply(user_balance,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
        
})
Tot=Tot[225:427,]
total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(log(Tot[,i]+1),frequency=7,start=c(1,7))
        myStl=stl(sx,s.window="periodic",robust=TRUE)
        myPred=forecast(myStl,h=30)
        total_Pred[,i]=myPred$mean
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot)

temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

total_Pred$report_date=sep2

P=exp(total_Pred$purchase_bal_amt)+exp(total_Pred$purchase_bank_amt)+exp(total_Pred$share_amt)
R=exp(total_Pred$tftobal_amt)+exp(total_Pred$tftocard_amt)+exp(total_Pred$category1)+exp(total_Pred$category2)+exp(total_Pred$category3)+exp(total_Pred$category4)

out=data.frame(sep2,P,R)
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])
write.table(out,"result/eleventh.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)


######复出，第12次提交，好好做！
Tot=ddply(user_balance,.(report_date),function(D){
        temp1=colwise(sum)(D[,c(-1,-2)])
        temp2=nrow(D)
        data.frame(temp1,num=temp2)
})
Tot=Tot[225:427,]

numSeries=ts(Tot$num,frequency=7,start=c(1,7))
numStl=stl(numSeries,s.window="periodic",robust=TRUE)
predNum=forecast(numStl,h=30)$mean

total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(Tot[,i]/numSeries,frequency=7,start=c(1,7))
        myStl=stl(sx,s.window="periodic",robust=TRUE)
        myPred=forecast(myStl,h=30)
        total_Pred[,i]=myPred$mean
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot[1:17])

temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

total_Pred$report_date=sep2

P=(total_Pred$purchase_bal_amt+total_Pred$purchase_bank_amt+total_Pred$share_amt)*predNum
R=(total_Pred$tftobal_amt+total_Pred$tftocard_amt+total_Pred$category1+total_Pred$category2+total_Pred$category3+total_Pred$category4)*predNum

out=data.frame(sep2,P,R)
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])
write.table(out,"result/twelfth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)

######第13次提交
Tot=ddply(user_balance,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
        
})
Tot=Tot[225:427,]
total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(log(Tot[,i]+1),frequency=7,start=c(1,1))
        diffsx=diff(sx)
        myStl=stl(diffsx,s.window="periodic",robust=TRUE)
        myPred=forecast(myStl,h=30)
        temp=diffinv(myPred$mean,xi=tail(sx,1))
        total_Pred[,i]=exp(temp[-1])
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot)

temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

total_Pred$report_date=sep2

P=total_Pred$purchase_bal_amt+total_Pred$purchase_bank_amt+total_Pred$share_amt
R=total_Pred$tftobal_amt+total_Pred$tftocard_amt+total_Pred$category1+total_Pred$category2+total_Pred$category3+total_Pred$category4

out=data.frame(sep2,P,R)
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])
write.table(out,"result/thirteenth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)



######第14次提交
Tot=ddply(user_balance,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
        
})
Tot=Tot[225:427,]

#
plot(Tot$purchase_bal_amt,type="l")
plot(log(Tot$purchase_bal_amt),type="l")
sx=ts(Tot$purchase_bal_amt+1,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=0)
purchase_bal_amt=forecast.stlm(myStl,h=30)
#
plot(Tot$purchase_bank_amt,type="l")
plot(log(Tot$purchase_bank_amt),type="l")
sx=ts(Tot$purchase_bank_amt,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=0)
purchase_bank_amt=forecast.stlm(myStl,h=30)
##这个不要做log变换
plot(Tot$share_amt,type="l")
plot(log(Tot$share_amt),type="l")
acf(Tot$share_amt)
pacf(Tot$share_amt)
ArimaFit=Arima(Tot$share_amt,order=c(1,0,0),seasonal=c(1,0,0),method="ML")
share_amt=forecast.Arima(ArimaFit,h=30)
#
plot(Tot$tftobal_amt,type="l")
plot(log(Tot$tftobal_amt),type="l")
sx=ts(Tot$tftobal_amt,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=0)
tftobal_amt=forecast.stlm(myStl,h=30)
#
plot(Tot$tftocard_amt,type="l")
plot(log(Tot$tftocard_amt),type="l")
sx=ts(Tot$tftocard_amt,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=0)
tftocard_amt=forecast.stlm(myStl,h=30)
#
plot(Tot$category1,type="l")
plot(log(Tot$category1),type="l")
sx=ts(Tot$category1,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=0)
category1=forecast.stlm(myStl,h=30)
#
plot(Tot$category2,type="l")
plot(log(Tot$category2),type="l")
sx=ts(Tot$category2,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=1)
category2=forecast.stlm(myStl,h=30)
#
plot(Tot$category3,type="l")
plot(log(Tot$category3),type="l")
sx=ts(Tot$category3,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=1)
category3=forecast.stlm(myStl,h=30)
#
plot(Tot$category4,type="l")
plot(log(Tot$category4),type="l")
sx=ts(Tot$category4,frequency=7,start=c(1,1))
myStl=stlm(sx,s.window="periodic",robust=TRUE,method="arima",lambda=0)
category4=forecast.stlm(myStl,h=30)


temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

P=as.numeric(purchase_bal_amt$mean)+as.numeric(purchase_bank_amt$mean)+as.numeric(share_amt$mean)
R=tftobal_amt$mean+tftocard_amt$mean+category1$mean+category2$mean+category3$mean+category4$mean

out=data.frame(sep2,P,R)
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])
write.table(out,"result/fourteenth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)


######第15次提交，试着考虑假期特征
Tot=ddply(user_balance,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
        
})

###假期特征
jiaqitemp=c("2013-09-19","2013-09-20","2013-09-21","2013-10-01","2013-10-02","2013-10-03","2013-10-04","2013-10-05",
        "2013-10-06","2013-10-07","2014-01-01","2014-01-31","2014-02-01","2014-02-02","2014-02-03","2014-02-04",
        "2014-02-05","2014-02-06","2014-04-05","2014-04-06","2014-04-07","2014-05-01","2014-05-02","2014-05-03",
        "2014-05-31","2014-06-01","2014-06-02","2014-09-06","2014-09-07","2014-09-08")
jiaqitemp=as.Date(jiaqitemp)

jiaqi=Tot$report_date %in% jiaqitemp+0




Tot=Tot[225:427,]
jiaqi=jiaqi[225:427]
#jiaqi=as.factor(jiaqi)

total_Pred=rep(0,17*30)
dim(total_Pred)=c(30,17)
for(i in 2:17){
        sx=ts(Tot[,i],frequency=7,start=c(1,1))
        myStlm=stlm(sx,s.window="periodic",robust=TRUE)
        myPred=forecast.stlm(myStlm,h=30)
        total_Pred[,i]=myPred$mean
}
total_Pred=as.data.frame(total_Pred)
names(total_Pred)=names(Tot)

temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

P=total_Pred$purchase_bal_amt+total_Pred$purchase_bank_amt+total_Pred$share_amt
R=total_Pred$tftobal_amt+total_Pred$tftocard_amt+total_Pred$category1+total_Pred$category2+total_Pred$category3+total_Pred$category4

out=data.frame(sep2,P,R)
out[6,-1]=out[6,-1]*0.9
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])


write.table(out,"result/fifteenth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)



##############第16次，状态依然不是很好。。。玩了一天了-----结果昨天没有提交，今天继续，fighting！！
Tot=ddply(user_balance,.(report_date),function(D){
        colwise(sum)(D[,c(-1,-2)])
})
###假期特征
jiaqitemp=c("2013-09-19","2013-09-20","2013-09-21","2013-10-01","2013-10-02","2013-10-03","2013-10-04","2013-10-05",
            "2013-10-06","2013-10-07","2014-01-01","2014-01-31","2014-02-01","2014-02-02","2014-02-03","2014-02-04",
            "2014-02-05","2014-02-06","2014-04-05","2014-04-06","2014-04-07","2014-05-01","2014-05-02","2014-05-03",
            "2014-05-31","2014-06-01","2014-06-02","2014-09-06","2014-09-07","2014-09-08")
jiaqitemp=as.Date(jiaqitemp)

jiaqi=Tot$report_date %in% jiaqitemp+0
temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
yuceJiaqi=sep %in% jiaqitemp+0

buxiutemp=c("2013-09-22","2013-09-29","2013-10-12","2014-01-26","2014-02-08","2014-05-04","2014-09-28")
buxiutemp=as.Date(buxiutemp)
buxiu=Tot$report_date %in% buxiutemp+0

###用户都是在哪天加入的
totalDate=unique(user_balance$report_date)
jiaru=data.frame(totalDate,num=0)

temp=ddply(user_balance,.(user_id),function(D){
        D$report_date[1]
        
})
#############################

temp=weekdays(Tot$report_date)%in%c("星期六","星期日")+0

#redeem的方式：tftobal_amt、tftocard_amt、category1、category2、category3、category4
plot((Tot$total_redeem_amt)[200:427],type="l")
points((Tot$total_redeem_amt*temp)[200:427],type="p")
points((Tot$total_redeem_amt*jiaqi)[200:427],type="p",col="red")
points((Tot$total_redeem_amt*buxiu)[200:427],type="p",col="green")

#这个对节假日更敏感一些
plot((Tot$tftobal_amt)[200:427],type="l")
points((Tot$tftobal_amt*temp)[200:427],type="p")
points((Tot$tftobal_amt*jiaqi)[200:427],type="p",col="red")
points((Tot$tftobal_amt*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$tftobal_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=1,D=1,trace=TRUE)
#ARIMA(2,1,2)(0,1,1)
plot(forecast(autoFit,h=30))
tftobal_amt=as.numeric(forecast(autoFit,h=30)$mean)
detectAO(autoFit)
detectIO(autoFit)



plot((Tot$tftocard_amt)[200:427],type="l")
points((Tot$tftocard_amt*temp)[200:427],type="p")
points((Tot$tftocard_amt*jiaqi)[200:427],type="p",col="red")
points((Tot$tftocard_amt*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$tftocard_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=1,D=1,trace=TRUE)
#ARIMA(1,0,2)(0,1,1)
plot(forecast(autoFit,h=30)$residuals)
tftocard_amt=as.numeric(forecast(autoFit,h=30)$mean)




plot((Tot$category1)[200:427],type="l")
points((Tot$category1*temp)[200:427],type="p")
points((Tot$category1*jiaqi)[200:427],type="p",col="red")
points((Tot$category1*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$category1,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)
#ARIMA(1,0,1)(0,1,2)
plot(forecast(autoFit,h=30)$residuals)
category1=as.numeric(forecast(autoFit,h=30)$mean)




plot((Tot$category2)[200:427],type="l")
points((Tot$category2*temp)[200:427],type="p")
points((Tot$category2*jiaqi)[200:427],type="p",col="red")
points((Tot$category2*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$category2,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=1,D=1,trace=TRUE)
#ARIMA(2,1,1)(2,1,2)
plot(forecast(autoFit,h=30)$residuals)
category2=as.numeric(forecast(autoFit,h=30)$mean)



plot((Tot$category3)[200:427],type="l")
points((Tot$category3*temp)[200:427],type="p")
points((Tot$category3*jiaqi)[200:427],type="p",col="red")
points((Tot$category3*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$category3,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=1,D=1,trace=TRUE)
#ARIMA(5,1,0)(2,1,1)
plot(forecast(autoFit,h=30)$residuals)
category3=as.numeric(forecast(autoFit,h=30)$mean)


plot((Tot$category4)[200:427],type="l")
points((Tot$category4*temp)[200:427],type="p")
points((Tot$category4*jiaqi)[200:427],type="p",col="red")
points((Tot$category4*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$category4,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=1,D=1,trace=TRUE)
#ARIMA(0,1,1)(2,1,0)
plot(forecast(autoFit,h=30)$residuals)
category4=as.numeric(forecast(autoFit,h=30)$mean)



############################
##purchase_bal_amt、purchase_bank_amt、share_amt


plot((Tot$purchase_bal_amt)[200:427],type="l")
points((Tot$purchase_bal_amt*temp)[200:427],type="p")
points((Tot$purchase_bal_amt*jiaqi)[200:427],type="p",col="red")
points((Tot$purchase_bal_amt*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$purchase_bal_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)
#ARIMA(2,0,2)(0,1,2)
plot(forecast(autoFit,h=30))
purchase_bal_amt=as.numeric(forecast(autoFit,h=30)$mean)


plot((Tot$purchase_bank_amt)[200:427],type="l")
points((Tot$purchase_bank_amt*temp)[200:427],type="p")
points((Tot$purchase_bank_amt*jiaqi)[200:427],type="p",col="red")
points((Tot$purchase_bank_amt*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$purchase_bank_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)
#ARIMA(2,0,1)(0,1,1)
plot(forecast(autoFit,h=30))
purchase_bank_amt=as.numeric(forecast(autoFit,h=30)$mean)



plot((Tot$share_amt)[200:427],type="l")
points((Tot$share_amt*temp)[200:427],type="p")
points((Tot$share_amt*jiaqi)[200:427],type="p",col="red")
points((Tot$share_amt*buxiu)[200:427],type="p",col="green")
sx=ts(Tot$share_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)
#ARIMA(2,0,1)(2,1,0)
plot(forecast(autoFit,h=30))
share_amt=as.numeric(forecast(autoFit,h=30)$mean)

P=purchase_bal_amt+purchase_bank_amt+share_amt
R=tftobal_amt+tftocard_amt+category1+category2+category3+category4


temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
sep2=format(sep,format="%Y%m%d")

out=data.frame(sep2,P,R)
out[6,-1]=out[6,-1]*0.9
out[,2]=as.integer(out[,2])
out[,3]=as.integer(out[,3])


write.table(out,"result/sixteenth.csv",row.names=FALSE,sep=",",dec=".",col.names=FALSE,quote=FALSE)

############################


ArimaFit=arima(Tot$total_purchase_amt,order=c(1,1,1),seasonal=list(order=c(1,1,0),period=7),method="ML")
plot(ArimaFit)
plot(predict(ArimaFit,n.ahead=30)$pred)


ArimaFit=arima(Tot$total_redeem_amt,order=c(1,0,1),seasonal=list(order=c(0,1,1),period=7),method="ML")
ArimaFit
plot(ArimaFit)
plot(predict(ArimaFit,n.ahead=30)$pred)

sx=ts(Tot$total_redeem_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)
plot(forecast(autoFit,h=30))

sx=ts(Tot$total_purchase_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)
plot(forecast(autoFit,h=30))


head(Tot)
plot(diff(log(Tot$total_purchase_amt),lag=7),type="l")
acf(Tot$total_purchase_amt)
acf(diff(Tot$total_purchase_amt,lag=7))

tempModel=arima(ts(Tot$total_purchase_amt,frequency=7,start=c(1,1)),order=c(1,0,0),seasonal=list(order=c(2,1,0),period=7))
tempModel
plot(rstandard(tempModel))
plot(tempModel,type="l")
acf(rstandard(tempModel))
tsdiag(tempModel)
hist(rstandard(tempModel),50)
qqnorm(rstandard(tempModel))
qqline(rstandard(tempModel))


plot(forecast(tempModel,h=30))

##自动拟合试试看
tempModel=auto.arima(ts(Tot$total_purchase_amt,frequency=7,start=c(1,1)),seasonal=TRUE)




