%------------------------------Function CCBYRAD()------------------------------
function process_NL()
    clear all;
	close all;
	echo off;	
    %filename = fullfile('..','data','obv','F182013.v4c_web.stable_lights.avg_vis.tif');		%date dir name
    filename = 'D:/F182013.v4c_web.stable_lights.avg_vis.tif';		%date dir name
	im0=imread(filename);
    %im0=imadjust(im0,[0.2 0.5], [0.0 0.4]);
    %im0(find(im0<0.1))=1.0;
    %imhist(im0(find(im0>0.1)));
    size(im0)
    imhist(im0)
