#六个表格数据整合，整理，归一化六个表格数据整合，整理，归一化
import pandas as pd
import numpy as np
import sklearn
from sklearn.preprocessing import scale
def singlefileprocess(filename,outputfilename):
    CR=pd.read_excel(filename,header= 1,index_col=0)
    #行名是患者编号，列名是特征，大类没有读进来，后续记得处理
    #print(CR.iloc[1,:])
    #print(CR.columns)
    #print(CR.loc['BC01000495008']) #-0读入后是0，没问题

    #对单个数据集进行分析

    #补缺失值和归一化
    #缺失值读入后可以识别为na
    num = CR.isna().sum()
    print(num) #每个特征一二十个吧
    #简单点，线性插值吧
    CR=CR.interpolate()
    num = CR.isna().sum()
    print(num)
    #归一化
    # del CR['D1'] #针对GE D1 D8列 空值过半
    # del CR['D8']
    CR_norm=scale(CR.iloc[:,2:]) #zscore
    #CR_norm=pd.DataFrame(CR_norm)
    CR.iloc[:,2:]=CR_norm
    CR.to_csv(outputfilename)

#合并数据框
CR=pd.read_csv("CR_norm.csv",index_col=0,header=0)
CT=pd.read_csv("CT_norm.csv",index_col=0,header=0)
CTi=pd.read_csv("CTi_norm.csv",index_col=0,header=0)
GE=pd.read_csv("GE_norm.csv",index_col=0,header=0)
CW=pd.read_csv("CW_norm.csv",index_col=0,header=0)
XR=pd.read_csv("XR_norm.csv",index_col=0,header=0)
connect=pd.concat([CR, CT.iloc[:,2:],CTi.iloc[:,2:],GE.iloc[:,2:],CW.iloc[:,2:]], axis = 1)
print(connect)
connect.to_csv("wholedata.csv")
