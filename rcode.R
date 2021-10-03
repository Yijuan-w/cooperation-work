setwd("d:\\A\\work\\extra work")

#读入表达数据
expdata<-as.matrix(read.table("geneCandidates.txt",header=T))
G_rowname<-rownames(expdata)
expdata<-apply(expdata,2,as.numeric)
dim(expdata)

#读入背景网络
backgroundnetwork <- as.matrix(read.csv("rel_f.csv",header=T,row.names = 1))
backgroundnetwork <- backgroundnetwork[-1,]
dim(backgroundnetwork)
backgroundnetwork=unique(backgroundnetwork)
dim(backgroundnetwork)#116946 2
node1=unique(backgroundnetwork[,1]) #1843
node2=unique(backgroundnetwork[,2]) #19648
node=unique(c(node1,node2)) #19865 就是说就217只是tf而不是target

#筛选背景网络中有数据的边
nodewithdata=G_rowname
nodeinnetwork=list()
for(i in nodewithdata) {
  print(i)
  if(i %in% node){
    #print(i)
    nodeinnetwork=append(nodeinnetwork,i)
  }
}

nodeinnetwork=unique(nodeinnetwork)
print(length(nodeinnetwork))

#calculate PCC
expdata<-t(expdata)
colnames(expdata)<-G_rowname
matPCC=rbind()
for(i in 1:dim(backgroundnetwork)[1]){
  
  PCC=cor(expdata[,backgroundnetwork[i,1]],expdata[,backgroundnetwork[i,2]],method = "pearson")
  if(is.na(PCC)=="FALSE"){
    if(abs(PCC)>0.3){#这里设定的值
      one=c(backgroundnetwork[i,],PCC)
      matPCC=rbind(matPCC,one)
    }
    one=c(backgroundnetwork[i,],PCC)
    matPCC=rbind(matPCC,one)
  }
}

highPCC=rbind()
allPCCmat=cor(expdata,method = "pearson")
allPCCmat[lower.tri(allPCCmat,diag=T)] <- 0 

for (i in 1:dim(allPCCmat)) {
  for (j in 1:dim(allPCCmat)) {
    if(allPCCmat[i,j]>0.4){
      edge=c(G_rowname[i],G_rowname[j],allPCCmat[i,j])
      highPCC=rbind(highPCC,edge)
    }
  }
}
library(infotheo)#他的包实现了基于几个熵估计的信息理论的各种度量
#ed=matPCC[,1:2]
ed_2=highPCC[,1:2]

#write.csv(matPCC,"normalmatPCC.csv")
#write.csv(matPCC,"cancermatPCC.csv")


nbins <- sqrt(NROW(expdata))#大概是存储方格个数
dis_data <- discretize(expdata,disc="equalfreq",nbins) 
colnames(dis_data) <- colnames(expdata)

MI_0 <- rbind()
for(i in 1:dim(ed_2)[1])
{
  #i <- 1
  loc1 <- ed_2[i,1]
  loc2 <- ed_2[i,2]
  MI <- mutinformation(dis_data[,loc1],dis_data[,loc2],method="emp")
  MI_0 <- rbind(MI_0,MI)
}
median(MI_0)
mean(MI_0)

hist(MI_0,main='MI_0_distribution',breaks =20)

MI_0_thre <- 0.4
MI_0_left <- rbind()
for(i in 1:length(MI_0))
{
  if(MI_0[i] > MI_0_thre)
  {
    MI_0_left <- rbind(MI_0_left,c(ed_2[i,],MI_0[i]))
  }
}
dim(MI_0_left)
write.csv(MI_0_left,"MI_0_left_thre0.4.csv") #1546

library(igraph)
MI_0_net <- graph.data.frame(MI_0_left[,c(1,2)],directed = F)
pdf('./MI_0_net.pdf')
plot(MI_0_net, vertex.color="purple",vertex.size=8,
     label.font=2,label.cex=2,label.color='black',main='MI_0_net')
dev.off()

##### Calculate 1-MI if exists
library(pracma)
MI_1 <- rbind()
MI_2 <- rbind()
MI_3 <- rbind()
MI_re <- rbind()
Node_0 <- unlist(vertex_attr(MI_0_net))
for(i in 1:dim(MI_0_left)[1])
{
  #i <-1
  loc1 <- MI_0_left[i,1]
  loc2 <- MI_0_left[i,2]
  ### if they have shared one-order neighbor
  ne1 <- setdiff(Node_0[unlist(ego(MI_0_net, order = 1, MI_0_left[i,1]))],MI_0_left[i,1])
  ne2 <- setdiff(Node_0[unlist(ego(MI_0_net, order = 1, MI_0_left[i,2]))],MI_0_left[i,1])
  nn <- unique(setdiff(intersect(ne1,ne2),c(MI_0_left[i,1],MI_0_left[i,2])))
  if(isempty(nn)==F)
  {
    # 1-order
    for(j in 1:length(nn))
    {
      loc3 <- nn[j]
      con <- dis_data[,loc3]
      mi <- condinformation(dis_data[,loc1],dis_data[,loc2],con,method="emp")
      MI_1 <- rbind(MI_1,c(MI_0_left[i,c(1,2)],nn[j],1,mi))
    }
    
    
  }
  else{
    #MI_1 <- rbind(MI_1,c(MI_0_left[i,c(1,2)],0,0)) 
    MI_re <-rbind( MI_re,c(MI_0_left[i,c(1,2)],0,'left'))
  }
}
colnames(MI_re) <- c('node1','node2','MI_order','states')
colnames(MI_1) <- c('node1','node2','neighbor1','MI_order','states')



#### select the maximum MI and CMI
thre <- 0.6
#### 1-order CMI
u1 <- unique(MI_1[,1])
MI_1_left_max <- rbind()
dim(MI_1)
for(i in 1:length(u1))
{
  loc <- which(MI_1[,1] %in% u1[i])
  k1 <- unique(MI_1[loc,2])
  can <- MI_1[loc,2]
  for(j in 1:length(k1))
  {
    z1 <- apply(as.matrix(MI_1[loc[which(can %in% k1[j])],dim(MI_1)[2]]),
                2,function(x) as.numeric(x))
    if(max(z1)> thre)
    {
      MI_1_left_max <- rbind(MI_1_left_max,c(u1[i],k1[j],max(z1)))
    }
  }
}
dim(MI_1_left_max)
write.csv(MI_1_left_max,"MI_1_left_thre=0.6.csv") #151

MI_1_net <- graph.data.frame(MI_1_left_max[,c(1,2)],directed = F)
for(i in 1:dim(MI_1_left_max)[1])
{
  #i <-1
  loc1 <- MI_1_left_max[i,1]
  loc2 <- MI_1_left_max[i,2]
  ### if they have shared one-order neighbor
  ne1 <- setdiff(Node_0[unlist(ego(MI_1_net, order = 1, MI_1_left_max[i,1]))],MI_1_left_max[i,1])
  ne2 <- setdiff(Node_0[unlist(ego(MI_1_net, order = 1, MI_1_left_max[i,2]))],MI_1_left_max[i,1])
  nn <- unique(setdiff(intersect(ne1,ne2),c(MI_1_left_max[i,1],MI_1_left_max[i,2])))
  if(isempty(nn)==F)
  {
    
    # 2-order
    if(length(nn)>1)
    {
      for(k in 1:(length(nn)-1))
      {
        loc3 <- nn[k]
        for(b in (k+1):length(nn))
        {
          loc4 <- nn[b]
          con <- c(dis_data[,loc3],dis_data[,loc4])
          mi <- condinformation(dis_data[,loc1],dis_data[,loc2],con,method="emp")
          MI_2 <- rbind(MI_2,c(MI_0_left[i,c(1,2)],nn[k],nn[b],2,mi))
        }
      }
    }
  }
}

colnames(MI_2) <- c('node1','node2','neighbor1','neighbor2','MI_order','states')
dim(MI_2)
#### 2-order CMI
thre=0.6
u2 <- unique(MI_2[,1])
MI_2_left_max <- rbind()
for(i in 1:length(u2))
{
  loc <- which(MI_2[,1] %in% u2[i])
  k1 <- unique(MI_2[loc,2])
  can <- MI_2[loc,2]
  for(j in 1:length(k1))
  {
    z1 <- apply(as.matrix(MI_2[loc[which(can %in% k1[j])],dim(MI_2)[2]]),
                2,function(x) as.numeric(x))
    if(max(z1) > thre)
    {
      MI_2_left_max <- rbind(MI_2_left_max,c(u2[i],k1[j],max(z1)))
    }
  }
}
dim(MI_2_left_max)
write.csv(MI_2_left_max,"MI_2_left_thre=0.6.csv") #151

MI_2_net <- graph.data.frame(MI_2_left_max[,c(1,2)],directed = F)
for(i in 1:dim(MI_2_left_max)[1])
{
  #i <-1
  loc1 <- MI_2_left_max[i,1]
  loc2 <- MI_2_left_max[i,2]
  ### if they have shared one-order neighbor
  ne1 <- setdiff(Node_0[unlist(ego(MI_2_net, order = 1, MI_1_left_max[i,1]))],MI_2_left_max[i,1])
  ne2 <- setdiff(Node_0[unlist(ego(MI_2_net, order = 1, MI_1_left_max[i,2]))],MI_2_left_max[i,1])
  nn <- unique(setdiff(intersect(ne1,ne2),c(MI_2_left_max[i,1],MI_2_left_max[i,2])))
  if(isempty(nn)==F)
  {
    #3 order
    if(length(nn)>2)
    {
      for(k in 1:(length(nn)-2))
      {
        loc3 <- nn[k]
        for(b in (k+1):(length(nn)-1))
        {
          loc4 <-nn[b]
          for(h in (b+1):length(nn))
          {
            loc5 <- nn[h]
            con <- c(dis_data[,loc3],dis_data[,loc4],dis_data[,loc5])
            mi <- condinformation(dis_data[,loc1],dis_data[,loc2],con,method="emp")
            MI_3 <- rbind(MI_3,c(MI_2_left_max[i,c(1,2)],nn[k],nn[b],nn[h],3,mi))
          }
        }
      }
    }
  }
}
colnames(MI_3) <- c('node1','node2','neighbor1','neighbor2','neighbor3','MI_order','states')
#### 3-order CMI
#max(apply(as.matrix(MI_3[,7]),2,function(x) as.numeric(x)))
u3 <- unique(MI_3[,1])
MI_3_left_max <- rbind()
dim(MI_3)
for(i in 1:length(u3))
{
  #i<-3
  loc <- which(MI_3[,1] %in% u3[i])
  k1 <- unique(MI_3[loc,2])
  can <- MI_3[loc,2]
  for(j in 1:length(k1))
  {
    #j <-4
    z1 <- apply(as.matrix(MI_3[loc[which(can %in% k1[j])],dim(MI_3)[2]]),
                2,function(x) as.numeric(x))
    if(max(z1) > thre)
    {
      MI_3_left_max <- rbind(MI_3_left_max,c(u2[i],k1[j],max(z1)))
    }
  }
}
dim( MI_3_left_max )
dim(MI_3)
MI_3[100:105,]

thre2 <- 1.9
all_net <- rbind(MI_1_left_max,rbind(MI_2_left_max,MI_3_left_max))
all_net <- rbind(MI_1_left_max,MI_2_left_max)
net_left <- rbind()
z1 <- unique(all_net[,1])
for(i in 1:length(z1))
{
  k1 <- which(all_net[,1] == z1[i])
  k2 <- unique(all_net[k1,2])
  can <- all_net[k1,2]
  val <- as.numeric(all_net[k1,3])
  for(j in 1:length(k2))
  {
    zz <- which(can %in% k2[j])
    va <- max(val[zz])
    if(va > thre2)
    {
      net_left <- rbind(net_left,c(z1[i],k2[j],va))
    }
  }
}

dim(unique(net_left)) #283
a=unique(net_left[,1])
b=unique(net_left[,2])
c=unique(c(a,b))
write.csv(highPCC,"highPCC0.4.csv")
write.csv(MI_1,"MI_1.csv")
write.csv(MI_2,"MI_2.csv")
write.csv(MI_3,"MI_3.csv")
write.csv(net_left,"netleft1.9.csv")

