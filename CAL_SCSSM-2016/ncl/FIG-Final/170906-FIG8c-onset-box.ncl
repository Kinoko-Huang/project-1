;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = "FLUT"
    g_data3_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    g_data3_nudg_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/nudg"

    g_obv_rank=(/122,131,131,114,128,108,130,123,119,119,128,102,110,132,135,114,118,112,131,132,93,101,115,114,126,114,123,105,115,109,99,134,114,106,124,126,101/)
    
    g_font = 0.022
    
    ;Andaman Sea convection
    g_latS=5.
    g_latN=15.
    g_lonW=87.5
    g_lonE=97.5

    ; create an array of desired pressure levels:
    g_fig_name = "../../fig/FINAL/FIG8c-model-esm-olr-box-plot"
        
    npos_year = 0
    nneg_year = 0

;Prepare the variables
    ctrl_in_files = systemfunc("ls "+g_data3_path+"/*ESMc_0*"+g_var_name+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     = addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$g_var_name$
    var_areamean=wgt_areaave_Wrap(var(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
 
 
    nudg_in_files = systemfunc("ls "+g_data3_nudg_path+"/*ESMn*"+g_var_name+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     = addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var_nudg  =nudg_in[:]->$g_var_name$(:,0:181,:,:)
   
    var_nudg_areamean=wgt_areaave_Wrap(var_nudg(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)

    var_mean=dim_avg_n_Wrap(var_areamean,0)  
    var_nudg_mean=dim_avg_n_Wrap(var_nudg_areamean,0)  

    var_onset=var_areamean
    var_nudg_onset=var_nudg_areamean

    day_strt=90
    var_onset_M2J=var_onset(:,day_strt:)
    var_nudg_onset_M2J=var_nudg_onset(:,day_strt:)

    var_onset_M2J=where(var_onset_M2J .lt. 235, 1, 0)
    var_nudg_onset_M2J=where(var_nudg_onset_M2J .lt. 235, 1, 0)
    var_onset_M2J=dim_acumrun_n(var_onset_M2J,6,1,1)
    var_nudg_onset_M2J=dim_acumrun_n(var_nudg_onset_M2J,6,1,1)
    
    dim_esm=dimsizes(var_onset)
    dim_esm:=dim_esm(0)
    

    dim_nudg=dimsizes(var_nudg_onset)
    dim_nudg:=dim_nudg(0)
    
    onset_esm=var_onset(:,0)
    onset_nudg=var_nudg_onset(:,0)

    do ii=0,dim_esm-1
        idate= get1Dindex(var_onset_M2J(ii,:), 6)
        onset_esm(ii)=(day_strt+idate-5+1)
    end do

    do jj=0, dim_nudg-1
        idate= get1Dindex(var_nudg_onset_M2J(jj,:), 6)
        onset_nudg(jj)=(day_strt+idate-5+1)
    end do


    box_data = new((/3,5/),"float")
    qsort(onset_esm)
    qsort(onset_nudg)
    qsort(g_obv_rank)
    print(stddev(g_obv_rank))
    print(stddev(onset_nudg))
    print(stddev(onset_esm))
  
    

    box_data(0,0)=g_obv_rank(1)
    box_data(0,1)=g_obv_rank(9)
    box_data(0,2)=g_obv_rank(18)
    box_data(0,3)=g_obv_rank(27)
    box_data(0,4)=g_obv_rank(35)

 
    box_data(1,0)=onset_esm(1)
    box_data(1,1)=onset_esm(5)
    box_data(1,2)=onset_esm(11)
    box_data(1,3)=onset_esm(17)
    box_data(1,4)=onset_esm(21)

    box_data(2,0)=onset_nudg(1)
    box_data(2,1)=onset_nudg(5)
    box_data(2,2)=onset_nudg(11)
    box_data(2,3)=onset_nudg(17)
    box_data(2,4)=onset_nudg(21)+5
    labels    = (/"OBV", "CTRL","NUDG"/)  
    x = (/-2., 0., 2./)
    obv_avg_onset=dim_avg_Wrap(g_obv_rank)
    esm_avg_onset=dim_avg_Wrap(onset_esm)
    nudg_avg_onset=dim_avg_Wrap(onset_nudg)

    ;********************************************************
	; create the plot
	;********************************************************   
   wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)


    res            = True                         ; plot mods desired
    res@tmXBLabels = labels ; labels for each box
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@tiMainFontHeightF    = g_font

    ;**********************************************
    ; resources for polylines that draws the boxes
    ;**********************************************  
    llres                   = True          
    llres@gsLineThicknessF  = 2.0                 ; line thickness 
    ;**********************************************
    ; resources that control color and width of boxes
    ;**********************************************  
    opti          = True            
    opti@boxWidth = 1.              ; Width of box (x units)
    opti@boxColors = (/"darkgreen", "red", "blue"/)     ; Color of box(es)
    ;***********************************************
    
    
   ;***********************************************
   ;add polymarker res
   ;***********************************************
   mres               = True                     ; marker mods desired
   mres@gsMarkerIndex = 3                        ; polymarker style
   mres@gsMarkerSizeF = 30.                      ; polymarker size
   mres@gsMarkerThicknessF = 2.0

   ;***********************************************
   ;add refline res
   ;***********************************************

    lnres = True
    lnres@gsLineThicknessF = 2.0
    
    ;siglnres@gsLineThicknessF = 3.0
    ;siglnres@gsLineDashPattern = 2
    ;siglnres@gsLineColor = "red"
    
    
    res@tiMainString = "(c) Onset Day Box Plot"
    plot_box = boxplot(wks,x,box_data,opti,res,llres) ; All 3 options used...
    mres@gsMarkerColor = "darkgreen"                    ; polymarker color
    dum0 = gsn_add_polymarker(wks,plot_box,x(0),obv_avg_onset,mres) 
    mres@gsMarkerColor = "red"                    ; polymarker color
    dum1 = gsn_add_polymarker(wks,plot_box,x(1),esm_avg_onset,mres) 
    mres@gsMarkerColor = "blue"                    ; polymarker color
    dum2 = gsn_add_polymarker(wks,plot_box,x(2),nudg_avg_onset,mres) 
    draw(plot_box)                                     ; box plot does not call
    frame(wks)                                    ; these for you
end
