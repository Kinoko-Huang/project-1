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
    g_data_path ="/home/yangsong3/data/observation/PRECPT/GPCC_precip.mon.total.05x05.v7.nc"

    g_font = 0.02
    g_season="SON" 
    g_latS=-20.
    g_latN=20.
    g_lonW=60.
    g_lonE=180.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/MAM-PR-land-num-guage"
    g_strt_yyyymm=190101
    g_end_yyyymm=201012

    ctrl_in1     = addfile (g_data_path, "r")   ; note the "s" of addfile
    time := ctrl_in1->time
    yyyymm :=floor( cd_calendar(time,-1))
    istrt = ind(yyyymm .eq. g_strt_yyyymm)
    ilast = ind(yyyymm .eq. g_end_yyyymm)
    var1 = short2flt(ctrl_in1->p(istrt:ilast,:,:))
    var2 = short2flt(ctrl_in1->s(istrt:ilast,:,:))
    var1=var1(:,::-1,:)
    var2=var2(:,::-1,:)
    var1&lat@units="degree_north"
    var2&lat@units="degree_north"
   ; var1=var1*86400
    ;var2=where(var2 .eq. var2@_FillValue, 0, var2)
    ;var1=where(var1 .eq. var1@_FillValue, 0, var1)
    var1= where(var2 .gt. 0, var1, var1@_FillValue)

    dvar1bar_dt      = var1(0:11,:,:) ; dvar1'dt of every indivadual month  
    var1bar = month_to_season12(var1)
    dimz = dimsizes(var1bar(0::12,0,0))
    do ii=0,11
        var1bar_oneseason=var1bar(ii::12,:,:)
        dvar1bar_dt(ii,:,:) = (/regCoef(ispan(0,dimz-1,1), var1bar_oneseason(lat|:,lon|:,time|:))/)
    end do
    diff_var1=dvar1bar_dt
    delete(diff_var1@_FillValue)
    diff_var1=where(diff_var1 .lt. -999, 0, diff_var1)
    dvar1bar_dt= dimz*dvar1bar_dt
    diff_var1:=f2fsh_Wrap(diff_var1,(/72, 144/))

    clim_var2_e=dim_avg_n_Wrap(var2(0:29*12,:,:),0)
    clim_var2_e=where(clim_var2_e .eq. clim_var2_e@_FillValue, 0, 1)
    delete(clim_var2_e@_FillValue)
    clim_var2_e:=f2fsh_Wrap(clim_var2_e,(/72, 144/))
    diff_var1@_FillValue=-999
    do ii=0,11
        diff_var1(ii,:,:)=where(clim_var2_e .gt. 0, diff_var1(ii,:,:)/clim_var2_e,diff_var1@_FillValue)
    end do
    print(wgt_areaave_Wrap(diff_var1(:,{-15:15},{90:150}),1.0,1.0,0))
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file
 gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"MPL_StepSeq")
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
 res@cnMinLevelValF        = -0.5         ; set min contour level
 res@cnMaxLevelValF        = 0.5        ; set max contour level
 res@cnLevelSpacingF       = 0.05          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@cnFillMode           = "CellFill"
  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  ;res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
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
  res@tmYLTickSpacingF = 10
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = "NOAA 20CR 10muv & PRCC Rain diff"
  res@gsnRightString = ""
       
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 3.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.025
  vcres@vcRefAnnoString1  = "3 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.012
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.008
  vcres@vcLineArrowHeadMaxSizeF   = 0.008
 


  plot_sh= gsn_csm_contour_map(wks,diff_var1(3,:,:),res) ; create a default plot
  ;plot_cn_max = gsn_csm_contour(wks,var1_clim_max({g_level},:,:),res3)
  draw(plot_sh)
  frame(wks)


end
