# 请链接输入数据
# 链接完成后，系统会自动生成映射代码，将输入数据映射成变量参数，用户可直接使用
# 切记不可修改系统生成代码，否则运行将报错
# 端口2的表数据映射成dataset2
dataset2 <- pai.inputPort(2) # class: data.frame
# 端口1的表数据映射成dataset1
dataset1 <- pai.inputPort(1) # class: data.frame

library("forecast")
dataset1$report_date=as.Date(dataset1$report_date,format="%Y%m%d")

#############假期特征
jiaqitemp=c("2013-09-19","2013-09-20","2013-09-21","2013-10-01","2013-10-02","2013-10-03","2013-10-04","2013-10-05",
            "2013-10-06","2013-10-07","2014-01-01","2014-01-31","2014-02-01","2014-02-02","2014-02-03","2014-02-04",
            "2014-02-05","2014-02-06","2014-04-05","2014-04-06","2014-04-07","2014-05-01","2014-05-02","2014-05-03",
            "2014-05-31","2014-06-01","2014-06-02","2014-09-06","2014-09-07","2014-09-08")
jiaqitemp=as.Date(jiaqitemp)

jiaqi=dataset1$report_date %in% jiaqitemp+0
temp=as.Date("20140901",format="%Y%m%d")
sep=temp+0:29
yuceJiaqi=sep %in% jiaqitemp+0

buxiutemp=c("2013-09-22","2013-09-29","2013-10-12","2014-01-26","2014-02-08","2014-05-04","2014-09-28")
buxiutemp=as.Date(buxiutemp)
buxiu=dataset1$report_date %in% buxiutemp+0
#########################
temp=weekdays(dataset1$report_date)%in%c("星期六","星期日")+0

sx=ts(dataset1$total_purchase_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)

##非周末假期的偏移
jiaqiBias=sum(forecast(autoFit,h=30)$residual*jiaqi*(1-temp))/sum(jiaqi*(1-temp))
##补休的偏移
buxiuBias=sum(forecast(autoFit,h=30)$residual*buxiu)/sum(buxiu)
##############
purchase=as.numeric(forecast(autoFit,h=30)$mean)
purchase[8]=purchase[8]+jiaqiBias
purchase[28]=purchase[28]+buxiuBias



#######redeem
sx=ts(dataset1$total_redeem_amt,frequency=7,start=c(1,1))
autoFit=auto.arima(sx,d=0,D=1,trace=TRUE)

##非周末假期的偏
jiaqiBias=sum(forecast(autoFit,h=30)$residual*jiaqi*(1-temp))/sum(jiaqi*(1-temp))
##补休的偏移
buxiuBias=sum(forecast(autoFit,h=30)$residual*buxiu)/sum(buxiu)
###################
redeem=as.numeric(forecast(autoFit,h=30)$mean)
redeem[8]=redeem[8]+jiaqiBias
redeem[28]=redeem[28]+buxiuBias




dataname=data.frame(purchase)
dataname$report_date=dataset2$report_date



dataname$redeem=redeem

# 用户指定数据变量dataname(class:data.frame)到输出端口
# 平台会将该数据生成ODPS表
# dataname务必修改成自己的变量名称
pai.outputPort(1, dataname)