%read file
row=512;  col=512;
fin=fopen('slice150.raw','r');
%I=fread(fin,[row,col],'uint16');
I=fread(fin,[row,col],'ubit12=>uint16',4,'l');
input=reshape(I,[row,col]);
input=input';
figure
subplot(1,2,1)
imshow(input,[]);title('Original Image with blue middle line');axis on
line([col 1], [col col]/2)

%(a)Profile line
X=1 : col;
Y=input(col/2,:);
subplot(1,2,2)
plot(X, Y, 'b-');title('Profile line of the mid data line');xlabel('X');ylabel('Y');
legend({'profile line'},'Location','southwest')

%(b) Mean
meanOfImage=mean(input(:));

%(b) Variance
varianceOfImage=var(single(input(:)));
fid = fopen('output.txt','w');
fprintf(fid, 'Mean           Variance\n'); % writing values to file
fprintf(fid,'%f  %f\n',meanOfImage,varianceOfImage);
fclose(fid);

%(c) Histogram
figure
subplot(1,2,1)
histogram(input(:));title('Histogram of the 2D image');xlabel('X');ylabel('Y');
values = unique(input);
frequencies = double([values,histc(input(:),values)]);
subplot(1,2,2)
plot(frequencies(:,1),frequencies(:,2));title('Line graph of Histogram of the 2D image');xlabel('Occurences');ylabel('Frequencies');


PDF=frequencies(:,2)./(row*col);
%CDF
CDF=[size(PDF) 1];
CDF(1)=PDF(1);
for i=2:row
    CDF(i)=PDF(i)+CDF(i-1);
end
band=255;
for i=1:row
    CDF(i)=round(CDF(i)*band);
end

%(d) LINEAR TRANSFORMATION Refrence https://www.cse.unr.edu/~looney/cs674/unit2/unit2.pdf
MAXg=255;
MINg=0;
MINf=min(frequencies(:,1));
MAXf=max(frequencies(:,1));
input1=single(input);
a=(MAXg-MINg)/(MAXf-MINf);
r1=[512 512];
for i=1:row
    for j=1:col
       r1(i,j)=(a*(input1(i,j)-MINf)+MINg);
       %r1(i,j)=((input(i,j)-MINf)/(MAXf-MINf))*255;
    end
end
maximumAfterLinearTransformation=max(r1(:))
figure
subplot(1,2,1)
imshow(r1,[]); title('Image after Linear Transformation');axis on

%(e) NON-LINEAR g(m,n) = (31.875)log (f(m,n) + 1) Refrence https://www.cse.unr.edu/~looney/cs674/unit2/unit2.pdf
r2=[512 512];
for i=1:row
    for j=1:col
       r2(i,j)=(31.875)*log2(input1(i,j)+1);
    end
end
maximumAfterNonLinearTransformation=max(r2(:))
subplot(1,2,2)
imshow(r2,[]); title('Image after Non-Linear Transformation');axis on

%(f) Boxcar Smoothing
%mask initialization
masksize=11;
boxcar=uint16(ones(masksize));
newImage1=uint16([row-masksize-1 col-masksize-1]);
for i=1:row-masksize-1   %mask application
    for j=1:col-masksize-1
        temp=input(i:(i+masksize-1),j:(j+masksize-1)); %sub image
        temp1=temp.*boxcar; %convolve mask
        subtotal=sum(temp1);
        total=sum(subtotal);
        newImage1(i,j)=total/(masksize^2);
    end
end
figure
subplot(1,2,1)
imshow(newImage1,[]); title('Image after Carbox Masks');axis on

%(g) Median Mask
newImage2=uint16([row-masksize-1 col-masksize-1]);
for i=1:row-masksize-1
    for j=1:col-masksize-1
        temp=input(i:(i+masksize-1),j:(j+masksize-1)); %sub image
        temp1=sort(temp); %convolve mask
        mid=median(temp1(:));
        newImage2(i,j)=mid;
    end
end
subplot(1,2,2)
imshow(newImage2,[]); title('Image after Median Masks');axis on