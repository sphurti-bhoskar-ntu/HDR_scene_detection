%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Code for algorithm for HDR detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load image package
pkg image load
% for all samples loop start, This will loop through all folders with AEB images, Figure names are considered as 1.JPG, 2.JPG, 3.JPG
folders = dir ;
folders = folders([folders.isdir]);
folders = folders(arrayfun(@(x) x.name(1), folders) ~= '.');
for i = 1:length(folders)
	liste = folders(i).name ;
	cd(liste) ;
	clear  Ic
	clear  Ic1
	% for all samples processing start
	% define focus measure HMomentum start
function fm = HMomentum(Image, max)
	[M N] = size(Image);
	Hist = imhist(Image,max)/(M*N);
	fm = sum(abs( ( transpose(1:max)-  mean(mean(Image)))/  mean(mean(Image)) ).*Hist) ;
end
	% define focus measure HMomentum end
	ALGORITHM = {'HMomentum' };
[S] = size(ALGORITHM);
Ic = zeros(4*S+5);
windowSize = 500 ;
Sr_No = 1 ;
f1= ['1.JPG'];
f2= ['2.JPG'];
f3= ['3.JPG'];
% Reading images : Start
I1=rgb2gray(imread(f1));
I_1= I1 ;
I2=rgb2gray(imread(f2));
I_2= I2;
I3=rgb2gray(imread(f3));
I_3= I3;
[rows_windowSize,columns_windowSize]=size(I_1);
% Reading images : End
% filter noise to supress aberation affecting computation : Start
H = fspecial('disk',5);
I1 = imfilter(I_1,H,'replicate');
I2 = imfilter(I_2,H,'replicate');
I3 = imfilter(I_3,H,'replicate');
% filter noise to supress aberation affecting computation : End

max1=2^8;    % for 8 bit image
% divide image in to square blocks of size defined by "windowSize" as its size : Start
[rows_windowSize,columns_windowSize]=size(I1);

for row = 1 : windowSize : rows_windowSize
for column = 1 : windowSize : columns_windowSize
	Sr_No = Sr_No +1 ;
	min_x = row ;
	min_y = column ;
if ((row+windowSize-1)<rows_windowSize) && (column+windowSize-1 <columns_windowSize)
	T1 = I1(row:row+windowSize-1, column:column+windowSize-1);
	T2 = I2(row:row+windowSize-1, column:column+windowSize-1);
	T3 = I3(row:row+windowSize-1, column:column+windowSize-1);
	max_x =  row+windowSize-1 ;
	max_y = column+windowSize-1 ;
elseif (column+windowSize-1 >columns_windowSize) &&  (row+windowSize-1>rows_windowSize)
	T1 = I1(row:rows_windowSize-1, column:columns_windowSize-1);
	T2 = I2(row:rows_windowSize-1, column:columns_windowSize-1);
	T3 = I3(row:rows_windowSize-1, column:columns_windowSize-1);
	max_x =  rows_windowSize-1;
	max_y = columns_windowSize-1 ;
elseif (row+windowSize-1>rows_windowSize)
	T1 = I1(row:rows_windowSize-1, column:column+windowSize-1);
	T2 = I2(row:rows_windowSize-1, column:column+windowSize-1);
	T3 = I3(row:rows_windowSize-1, column:column+windowSize-1);
	max_x =  rows_windowSize-1 ;
	max_y = column+windowSize-1 ;
elseif (column+windowSize-1 >columns_windowSize)
	T1 = I1(row:row+windowSize-1, column:columns_windowSize-1);
	T2 = I2(row:row+windowSize-1, column:columns_windowSize-1);
	T3 = I3(row:row+windowSize-1, column:columns_windowSize-1);
	max_x =  row+windowSize-1 ;
	max_y = columns_windowSize-1 ;
endif 
	Ic1=[ Sr_No, min_y, min_x, max_y-min_y, max_x-min_x] ;
	% Apply selected fmeasure :Start
	fm1 =HMomentum(T1,max1) ;
	fm2 =HMomentum(T2,max1) ;
	fm3 =HMomentum(T3,max1) ;
	% Apply selected fmeasure :End

	% Apply weightage to low and mid exposure to avoid getting high  exposure for minor additions
	A =[fm1*1.1  fm2*1.1  fm3];
	% find frame needed for capturing maximum variation
	B=find(A==(max(A)));
	A = [A ,  B(1)];
	Ic1 = [Ic1 ,  A];
	%Build final fmeasure table with block ID , dimetions of block , focus measures for all exposure frames and most usable frame	
	Ic = [Ic;Ic1];
end
end

	% divide image in to square blocks of size defined by "windowSize" as its size : End
	% Write fmeasure table in to csv for debug
	dlmwrite ('Ic.csv' , Ic ) ;
	% list most usable exposure frames ,Ignore 0 ,  If frames needed are more than one then scene is HDR beyond camera's capability to capture in single frame
	dlmwrite ('unique' , transpose(unique(Ic(:,9))) ) ;

	Idiff = 'Ic , I_1 , I_2 , I_3';
	cd ..
end

	% Debug function to show any delected block : Start
function [img]  = showme (No, Ic, I1 , I2 , I3)
	close all ;
	location = Ic(No,2:5);
	Z1=imcrop(I1,location);
	Z2=imcrop(I2,location);
	Z3=imcrop(I3,location);
	imshow (Z1) , figure , imshow(Z2),figure,imshow(Z3);

endfunction 
	% Debug function to show any delected block : End
