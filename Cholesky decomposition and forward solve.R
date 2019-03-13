
mchol=function(x)
{
  mn=dim(x)                                                         #x��ά��
  m=mn[1]                                                           #x������
  n=mn[2]                                                           #x������
  if(m!=n) return ("Wrong dimensions of matrix!")                   #����x�Ƿ��Ƿ���
  if(sum(t(x)!=x)>0) return ("Input matrix is not symmetrical!")    #����x�Ƿ��ǶԳ���
  L=matrix(0,m,m)                                                   #�ȸ�L����һ���վ���
  for(i in 1:m)
    {
      L[i,i]=sqrt(x[i,i])                                           #L����(1,1)λ�õ�Ԫ�ص���x11��ƽ����
      if(i<m)
      {
        L[(i+1):m,i]=x[(i+1):m,i]/L[i,i]                            #��������(L21,...,Lm1),m-iά��
        TLV=L[(i+1):m,i]                                            #��(L21,...,Lm1)һ������
        TLM=matrix(TLV,m-i,m-i)                                     #��TLV�������ų�һ��m-iά�ľ���
        TLM=sweep(TLM,2,TLV,"*")                                    #�µ�TLM������ÿ�ж�����TLV
        x[(i+1):m,(i+1):m]=x[(i+1):m,(i+1):m]-TLM                   #��ȥTLM֮��õ�һ���µĿ���cholesky�ֽ�ľ���
      }
    }
  L                                                                 #����L  
}

######EXAM
#y=matrix(rnorm(20),5)#
#x=t(y)%*%y
#mchol(x)
#t(chol(x))                                                         #��ΪR�еķֽ⺯���������һ�������Ǿ���ת��һ��
######EXAM


mforwardsolve=function(L,b)                                                 
{
  mn=dim(L); m=mn[1]; n=mn[2]                                               
  if(m!=n) return ("Wrong dimensions of matrix L!")                         
  if(m!=length(b)) return ("Wrong dimensions of matrix L or vector b!")   
  x=rep(0,m)                                                             
  for(i in 1:m)
  {
    x[i]=b[i]/L[i,i]
    if(i<m) b[(i+1):m]=b[(i+1):m]-x[i]*L[(i+1):m,i]      
  }
  x  
}
mbacksolve=function(L,b){
  mn=dim(L); m=mn[1]; n=mn[2]
  if(m!=n) return ("Wrong dimensions of matrix L!")
  if(m!=length(b)) return ("Wrong dimensions of matrix L or vector b!")
  x=rep(0,m)
  for(i in m:1){
    x[i]=b[i]/L[i,i]
    if(i>1) b[(i-1):1]=b[(i-1):1]-x[i]*L[(i-1):1,i]      
  }
  x  
}
######EXAM
#y=matrix(rnorm(20),5)
#x=t(y)%*%y
#L=mchol(x); b=1:4
#mforwardsolve(L,b)
#forwardsolve(L,b)
######EXAM

ridgereg=function(lambda,x,y)
{
  #y=data[,m]; x=data[,-m]��仰��˼��ȡ���ݵĵڼ�����Ϊ�����
  np=dim(x)
  n=np[1]
  p=np[2]
  x=as.matrix(cbind(rep(1,n),x))                                   #����ؾ���
  V=t(x)%*%x+diag(c(0,rep(lambda,p)))                              #Ҫcholesky�ֽ�ľ���
  U=as.vector(t(x)%*%y)
  R=mchol(V)
  M=mforwardsolve(R,U)
  mbacksolve(t(R),M)   
}

pred=function(b,nx)
{
  #nx=prostate[1:2,1:8]
  b=as.vector(b)
  p=length(b)-1
  nx=as.matrix(nx,ncol=p)
  n=dim(nx)[1]
  apply(t(nx)*b[2:(p+1)],2,sum)+b[1]  
}

cvridgeregerr=function(lambda,x,y){  
  mridge=function(i,lambda,x,y) ridgereg(lambda,x[-i,],y[-i])
  #lambda=1
  np=dim(x);n=np[1];p=np[2]
  coe=t(apply(as.matrix(1:n,ncol=1),1,mridge,lambda,x,y))
  mean((apply(coe*cbind(1,x),1,sum)-y)^2)
}

ridgeregerr=function(lambda,x,y)mean((pred(ridgereg (lambda,x,y),x)-y)^2)
###############################
library(ElemStatLearn)
x=prostate[,1:8]; y=prostate[,9]
LAM=seq(0.001,10,len=50)
err=unlist(lapply(LAM,ridgeregerr,x,y))
pe=unlist(lapply(LAM,cvridgeregerr,x,y))
x=rep(1:50,2)
type=rep(1:2,c(50,50))
interaction.plot(x,type,c(err,pe))

###############################################

library(ElemStatLearn)
x=prostate[,1:8]; y=prostate[,9]
ridgereg(data[,1:9],lambda=1)
library(mda)
ridge1=gen.ridge(prostate[,1:8], y=prostate[,9,drop=FALSE], lambda=1)  
ridge1$coe
