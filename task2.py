#根据性别与年龄段分组，聚类
#1.性别都一样，聚类，看聚出来的东西是不是按照年龄
#2.年龄都一样，聚类，看聚出来的东西是不是两类按照性别
import sklearn
import numpy as np
import matplotlib.pyplot as plt
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.cluster import KMeans
from sklearn.datasets.samples_generator import make_blobs
from sklearn import metrics
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.manifold import TSNE
from mpl_toolkits.mplot3d import Axes3D
# plt.rcParams["font.family"]="SimHei"
#
# # 设置正常显示字符
# plt.rcParams["axes.unicode_minus"]=False
# plt.rcParams["font.size"]=12
#
# x,y = make_blobs(n_samples=1000,n_features=4,centers=[[-1,-1],[0,0],[1,1],[2,2]],cluster_std=[0.4,0.2,0.2,0.4],random_state=10)
#
# k_means = KMeans(n_clusters=3, random_state=10)
#
# k_means.fit(x)
#
# y_predict = k_means.predict(x)
# plt.scatter(x[:,0],x[:,1],c=y_predict)
# plt.show()
# print(k_means.predict((x[:30,:])))
# print(metrics.calinski_harabaz_score(x,y_predict))
# print(k_means.cluster_centers_)
# print(k_means.inertia_)
# print(metrics.silhouette_score(x,y_predict))


CR_norm = pd.read_csv('D:\\A\\work\\2021.2Kmeans\\wholedata.csv',header=0,index_col=0)  # 读入数据
def age():
    Age=np.unique(CR_norm["Age"])
    #for i in Age:
    data_set1 = CR_norm[CR_norm['Age'].isin([18])]
    data_set=data_set1.iloc[:, 2:]
    estimator = KMeans(n_clusters=2)
    estimator.fit(data_set)
    centroid = estimator.cluster_centers_
    inertia = estimator.inertia_
    r = pd.concat([data_set, pd.Series(estimator.labels_, index=data_set.index)], axis=1)
    r.columns = list(data_set.columns) + [u'聚类类别']
    print(r)
    r.to_csv('output_file.csv')

    t_sne = TSNE(n_components=3)
    t_sne.fit(data_set)
    t_sne = pd.DataFrame(t_sne.embedding_, index=data_set.index)
    # plt.rcParams['font.sans-serif'] = ['SimHei']
    # plt.rcParams['axes.unicode_minus'] = False
    # dd = t_sne[r[u'聚类类别'] == 0]
    # plt.plot(dd[0], dd[1], 'r.')
    # dd = t_sne[r[u'聚类类别'] == 1]
    # plt.plot(dd[0], dd[1], 'go')
    #
    # plt.savefig('png_file.png')
    # plt.clf()

    fig = plt.figure()
    #ax = Axes3D(fig)
    ax = fig.add_subplot(1, 1, 1, projection='3d')
    # 将数据对应坐标输入到figure中，不同标签取不同的颜色，MINIST共0-9十个手写数字


    ax.scatter(t_sne.iloc[:, 0], t_sne.iloc[:, 1], t_sne.iloc[:, 2]
               ,c=plt.cm.Set1(r[u'聚类类别']))

    # 关闭了plot的坐标显示

    plt.show()


#'利用SSE选择k'
male_data_set = CR_norm[CR_norm['Gender'].isin(["M"])]
SSE = []  # 存放每次结果的误差平方和
for k in range(2, 13):
     estimator = KMeans(n_clusters=k,init="k-means++")  # 构造聚类器
     estimator.fit(male_data_set.iloc[:, 2:])
     SSE.append(estimator.inertia_)  # estimator.inertia_获取聚类准则的总和
X = range(2, 13)
plt.xlabel('k')
plt.ylabel('SSE')
plt.plot(X, SSE, 'o-')
plt.show()

data_set=male_data_set.iloc[:,2:]
estimator = KMeans(n_clusters=9)
estimator.fit(data_set)
centroid = estimator.cluster_centers_
inertia = estimator.inertia_
r = pd.concat([data_set, pd.Series(estimator.labels_, index=data_set.index)], axis=1)
r.columns = list(data_set.columns) + [u'聚类类别']
print(r)
r.to_csv('output_file.csv')

t_sne = TSNE(n_components=3)
t_sne.fit(data_set)
t_sne = pd.DataFrame(t_sne.embedding_, index=data_set.index)

fig = plt.figure()

ax = fig.add_subplot(1, 1, 1, projection='3d')
# 将数据对应坐标输入到figure中，不同标签取不同的颜色，MINIST共0-9十个手写数字

ax.scatter(t_sne.iloc[:, 0], t_sne.iloc[:, 1], t_sne.iloc[:, 2]
               ,c=plt.cm.Set1(r[u'聚类类别']))

plt.show()

