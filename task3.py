#在不同性别中，哪些列与年龄相关
#分男女两个数据集，算各列和年龄列相关性，排序，画个条形图
import pandas as pd
import matplotlib.pyplot as plt

data=pd.read_csv("wholedata.csv",index_col=0)
print(data)

maledata=data[data['Gender'].isin(["M"])]
del maledata["Gender"]
femaledata=data[data['Gender'].isin(["F"])]
del femaledata["Gender"]
corrcoef=maledata.corr()
print(corrcoef)
corrcoef.to_csv("Agecorrcoef.csv")

