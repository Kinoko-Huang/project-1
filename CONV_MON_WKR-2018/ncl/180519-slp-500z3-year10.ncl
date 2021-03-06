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

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters
    g_var_name = "r"
    g_data_path1 ="/users/yangsong3/L_Zealot/F/aquac4/pro/aquac4.cam.h1.YEAR.0010.daily.PSL.nc"
    g_data_path2 ="/users/yangsong3/L_Zealot/F/aquac4/pro/aquac4.cam.h1.YEAR.0010.daily.Z3.nc"
 ;    g_data_path ="/home/yangsong3/L_Zealot/data-mirror/obv/SST/HadISST/HadISST_sst.nc"

    g_font = 0.02
    g_latS=-90.
    g_latN=90.
    g_lonW=0.
    g_lonE=360.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/year10/aqua-psl-500z3"

    ctrl_in1     = addfile (g_data_path1, "r")   ; note the "s" of addfile
    var1 = ctrl_in1->PSL
    var1=var1/100
    clim_var1=dim_rmvmean_n_Wrap(var1,0)
    ctrl_in2     = addfile (g_data_path2, "r")   ; note the "s" of addfile
    var2 = ctrl_in2->Z3(:,13,:,:)
    var2=var2/10
    clim_var2=dim_rmvmean_n_Wrap(var2,0)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  gsn_define_colormap(wks,"precip2_17lev")
  plot = new((/1/),graphic)

;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -40         ; set min contour level
 res@cnMaxLevelValF        = 40        ; set max contour level
 res@cnLevelSpacingF       = 4         ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  ;res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True 
  res@gsnPaperOrientation = "portrait"
  ;res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True  ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 2 


  res@mpFillOn   =False   ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpMaxLatF  =g_latN
  res@mpMinLatF  =g_latS
  res@mpMaxLonF  =g_lonE
  res@mpMinLonF  =g_lonW
  res@mpCenterLonF=180
;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.
    
     ; now change the size of the tickmark labels
  res@tmXBMode="Explicit"
 ; res@tmXBValues=ispan(g_lonW,g_lonE,30)
 ; res@tmXBLabels=ispan(g_lonW,g_lonE,30)+"E"
  res@tmYLTickSpacingF = 30
  res@tmXBTickSpacingF = 60
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     
  res@gsnRightString = "hPa & gpm"
      
    res3                  = True       ; use plot options
    res3@cnFillOn         = False;True       ; Fill contours
    res3@cnLinesOn        = True      ; turn off contour lines
  ;for tp masking
    res3@gsnFrame         = False
    res3@gsnDraw  = False
    res3@cnLineLabelsOn   = False      ; turn off contour line labels
    res3@cnLineThicknessF = 3 
    res3@cnInfoLabelOn = False
   
   
    res3@cnLevelSelectionMode="ExplicitLevels"
    res3@cnLevels = ispan(10,120,10) 
    ;res3@cnLevels = (/0.1,0.5,1,2,3,4,5/)
    res3@cnLineColor      = "Red"
    res3@gsnLeftString      = " "
    res3@gsnRightString      = " "



  do ii=0,59
      wks = gsn_open_wks("png",g_fig_name+sprinti("%0.3i", ii+1))  ; open a ps file
      res@gsnLeftString ="Day" +sprinti("%0.3i", ii+1)+ " Aqua Planet PSL & GPH"      
      print("Day" +sprinti(" %0.3i ", ii+1))
      plot_sh= gsn_csm_contour_map(wks,clim_var1(ii,:,:),res) ; create a default plot
      plot_cn_pos = gsn_csm_contour(wks,clim_var2(ii,:,:),res3)
      res3@cnLevels = -res3@cnLevels
      res3@cnLineColor      = "Blue"
      res3@cnLineDashPattern      = 1
      plot_cn_neg = gsn_csm_contour(wks,clim_var2(ii,:,:),res3)
      res3@cnLevels = -res3@cnLevels
      res3@cnLineColor      = "Red"
      res3@cnLineDashPattern      = 0

      overlay(plot_sh,plot_cn_neg)
      overlay(plot_sh,plot_cn_pos)
      draw(plot_sh)
      frame(wks)
  end do

end

