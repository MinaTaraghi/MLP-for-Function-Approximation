function W=InitNW(hl_no,sizes,Input_no)
W=cell(1,hl_no);
W{1}=rand(Input_no,hid_lay_size(1))-0.5;
beta=0.7*sizes(i)^(1/sizes(i-1));
    for j=1:Input_no
        for k=sizes(1)
            W{i}(j,k)=beta*(W{i}(j,k)/norm(W{i}(j,k)));
        end
    end
for i=1:hl_no
    W{i}=rand(sizes(i-1),sizes(i))-0.5;
    beta=0.7*sizes(i)^(1/sizes(i-1));
    for j=1:sizes(i-1)
        for k=sizes(i)
            W{i}(j,k)=beta*(W{i}(j,k)/norm(W{i}(:,k)));
        end
    end
end
end