#-*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import os
##################这个是生成网络的，没有经过数据有无的筛选

data = pd.read_csv("geneCandidates.txt",sep="\t",index_col=False)
tf=data.iloc[:,0]
print(list(tf))

#DATABASE
human = pd.read_csv("D:\\A\\work\\RegDatabase\\human.source",header=None,sep = '\s',engine='python')
kegg = pd.read_csv("D:\\A\\work\\RegDatabase\\new_kegg.human.reg.direction.txt",header=None,sep = '\s',engine='python')
trust=pd.read_csv("D:\\A\\work\\RegDatabase\\trrust_rawdata.human.tsv",header=None,index_col=None,sep="\t")
print (human.iloc[0,0])
def findTF():
    databaseTF1=set(human.iloc[:,0])
    databaseTF1=pd.DataFrame(databaseTF1)
    print(len(databaseTF1))
    #databaseTF1.to_csv("TFRegnetwork.csv")
    databaseTF2=pd.concat([kegg.iloc[:,0],trust.iloc[:,0]],ignore_index=True)
    databaseTF=pd.concat([databaseTF2,databaseTF1],ignore_index=True)
    databaseTF=set(databaseTF.iloc[:,0])
    print(databaseTF)
    databaseTF=pd.DataFrame(databaseTF)
    #databaseTF.to_csv("TF.csv")
    return databaseTF


rel=[['tf','target']]

num=0
for j in range(0,len(human[0])):
        if human.iloc[j,0].upper() in list(tf):
            num=num+1
            print(num)
            if human.iloc[j,2].upper() in list(tf):
                one=[human.iloc[j,0],human.iloc[j,2]]
                print ('1')
                rel.append(one)
        if human.iloc[j, 2].upper() in list(tf):
            one = [human.iloc[j, 0], human.iloc[j, 2]]
            print('1')
            rel.append(one)


p1=0
for j in range(0,len(kegg[0])):
        if kegg.iloc[j,0].upper() in list(tf):
            if kegg.iloc[j,2].upper() in list(tf):
                one=[kegg.iloc[j,0],kegg.iloc[j,2]]
                p1=p1+1
                print (p1)
                if one not in rel:
                    rel.append(one)
        if kegg.iloc[j, 2].upper() in list(tf):
            one = [kegg.iloc[j, 0], kegg.iloc[j, 2]]
            if one not in rel:
                rel.append(one)

print(len(rel))


for j in range(0,len(trust[0])):
        if trust.iloc[j,0].upper() in list(tf):
            if trust.iloc[j,1].upper() in list(tf):
                one=[trust.iloc[j,0],trust.iloc[j,1]]
                print(1)
                if one not in rel:
                    rel.append(one)
        if trust.iloc[j, 1].upper() in list(tf):
            one = [trust.iloc[j, 0], trust.iloc[j, 1]]
            print(1)
            if one not in rel:
                rel.append(one)

#Edge
rel_f=pd.DataFrame(rel)
rel_f.to_csv('rel_fNew_addTF.csv')


#Node
tfuse=[]
for i in range(1,len(rel_f)):
    for j in range(0,len(rel_f.loc[0])):
        tfuse.append(rel_f.iloc[i,j])

tfuse=pd.DataFrame(list(set(tfuse)))
print(len(tfuse))
tfuse.to_csv("tfuseNew_addTF.csv")


# Mrel=pd.read_csv("highPCC0.4.csv",index_col=0)
# print("Mrelhead",Mrel.head())
# tf=findTF()
# print(tf)
# Mrel_select=[]
# for j in range(0,len(Mrel.iloc[:,0])):
#
#     if Mrel.iloc[j,0] in list(tf[0]):
#         print("enter1")
#         one = [Mrel.iloc[j, 0], Mrel.iloc[j, 1]]
#         print(j)
#         Mrel_select.append(one)
#     elif Mrel.iloc[j,1] in list(tf[0]):
#         print("enter2")
#         one=[Mrel.iloc[j,1],Mrel.iloc[j,0]]
#         print(j)
#         Mrel_select.append(one)
# Mrel_select=pd.DataFrame(Mrel_select)
# Mrel_select.to_csv('Mrel_selectPCC.csv')
# selectgene=pd.concat([Mrel_select.iloc[:,0],Mrel_select.iloc[:,1]],ignore_index=True)
# selectgene=set(selectgene)
# print(len(Mrel_select),len(selectgene))



