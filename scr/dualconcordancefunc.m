function z2=dualconcordancefunc(z)
% #concordance
% Returns an aggregation matrix to add rows that are dependant.
% Input is a concordance matrix (z); output is a condensed concordance
% matrix (z2), where any overlapping maps are aggregated (e.g. if row wheat
% goes to column grain and row barley also goes to column grain, then z2
% adds the two rows together. eg.: 
% G=[1,0;1,1];
% dualconcordancefunc(G)
% ans =
% 
%      1     1
%      
% Richard Wood, 07.05.2009

n=0;
z2=zeros(1,size(z,1));
for i=1:size(z,1)
    if sum((z2(:,i)==1))==0
        F111=reducerows(z,i);
        n=n+1;
        if ~isempty(F111),z2(n,F111)=1;end
    end
end
if isempty(z2),z2=[];end
if size(z2,1)==1 & sum(sum(z2,2))==0,z2=[];end

function F111=reducerows(z,F1)

F2=find(sum(z(F1,:)~=0,1));
F11=find(sum(z(:,F2)~=0,2));
if size(F11)==size(F1), F111=F11;return, end
F111=reducerows(z,F11);

