;*************************************************************
;Aim: draw HEAT_CP - CON_CP Pr and 850UV, do the significance test 
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process
;     2.1 Climatology 
;     2.2 Difference
;     2.3 Sig test
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-04-06
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-06  Change to fit Season jun
;   2015-06-23  Change to fit 973Report
;   2015-10-05  Change to fit dycore test
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------TS
;================================================
;global variables
    g_plev        =   (/925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 200.0, 100.0, 50.0/)
    g_res  = "f19"
    ;Define parameters
    g_data_path_ctrl = "../../data/model/pre/Ideal_phy/esm03-ctrl"
    g_data_path_sen = "../../data/model/pre/Ideal_phy/esm03"
    
    g_data_path_ctrl0 = "../../data/model/pre/Ideal_phy/CTRL"
    g_data_path_sen0 = "../../data/model/pre/Ideal_phy/SEN"
    
    g_sen_cases   = (/"heat-0.25-folding"/)
    g_season      =   "MAM"
    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
    ;g_latS=-90.
    ;g_latN=90.
    ;g_lonE=360.
    ;g_lonW=0.
; create an array of desired pressure levels:

    g_year_start   =   0 ;Rank from 0
    g_year_end     =   49;Rank from 0 
    g_nsmp        =   g_year_end - g_year_start + 1;number of samples for significance test
    g_idx_start = g_year_start*12
    g_idx_end = (g_year_end+1)*12-1

    g_run_period  =   "0250-0299"
        
    g_font = 0.035

    g_var         = "Z3"
    g_lev         = 12 

    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/scientific_reports/R1-FIGS4_col2_Ideal_day3_9-PSL-"+g_date
    ;g_fig_rank    =   "B2000_F19G16_CAM4_CTRL"
    g_fig_rank    =   (/"b","b","b","d","d","d","f","f","f"/)
    ;g_fig_title   =   g_season+" HEAT_CP-CON_CP"
    g_fig_title   =    "6 Members Mean"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls "+g_data_path_ctrl+"/*")
	setfileoption("nc","suppressclose",False) ; close too many files
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile


	ctrl_var1  = ctrl_in[:]->PSL(:,:,:)			; p for unify the var name
	ctrl_var2  = ctrl_in[:]->U(:,23,:,:)			; p for unify the var name
	ctrl_var3  = ctrl_in[:]->V(:,23,:,:)			; p for unify the var name
	ctrl_var4  = ctrl_in[:]->OMEGA(:,19,:,:)			; p for unify the var name

    all_files = systemfunc ("ls "+g_data_path_ctrl0+"/*")
	setfileoption("nc","suppressclose",False) ; close too many files
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile


	ctrl0_var1  = ctrl_in[:]->PSL(:,:,:)			; p for unify the var name
	ctrl0_var2  = ctrl_in[:]->U(:,23,:,:)			; p for unify the var name
	ctrl0_var3  = ctrl_in[:]->V(:,23,:,:)			; p for unify the var name
	ctrl0_var4  = ctrl_in[:]->OMEGA(:,19,:,:)			; p for unify the var name

    ;Calculate ESM mean
    ctrl_var1 = (ctrl_var1+ctrl0_var1)/2
    ctrl_var2 = (ctrl_var2+ctrl0_var2)/2
    ctrl_var3 = (ctrl_var3+ctrl0_var3)/2
    ctrl_var4 = (ctrl_var4+ctrl0_var4)/2

	do i = 0,dimsizes(g_sen_cases)-1
;*************************For F_Compset Heat***********************************

    ; ==============================================================
    ; Mission 1. Open the file: Read only the user specified period
    ; ==============================================================
	    all_files = systemfunc ("ls "+g_data_path_sen+"/*")
	    setfileoption("nc","suppressclose",False) ; close too many files
	    exp_in      = addfiles (all_files, "r")   ; note the "s" of addfile


        exp_var1  = exp_in[:]->PSL(:,:,:)			; p for unify the var name
        exp_var2  = exp_in[:]->U(:,23,:,:)			; p for unify the var name
        exp_var3  = exp_in[:]->V(:,23,:,:)			; p for unify the var name
        exp_var4  = exp_in[:]->OMEGA(:,19,:,:)			; p for unify the var name
        
        all_files = systemfunc ("ls "+g_data_path_sen0+"/*")
	    setfileoption("nc","suppressclose",False) ; close too many files
	    exp_in      = addfiles (all_files, "r")   ; note the "s" of addfile


        exp0_var1  = exp_in[:]->PSL(:,:,:)			; p for unify the var name
        exp0_var2  = exp_in[:]->U(:,23,:,:)			; p for unify the var name
        exp0_var3  = exp_in[:]->V(:,23,:,:)			; p for unify the var name
        exp0_var4  = exp_in[:]->OMEGA(:,19,:,:)			; p for unify the var name
        
        ;Calculate ESM mean
        exp_var1 = (exp_var1+exp0_var1)/2
        exp_var2 = (exp_var2+exp0_var2)/2
        exp_var3 = (exp_var3+exp0_var3)/2
        exp_var4 = (exp_var4+exp0_var4)/2


        diff_var1 = exp_var1
        diff_var2 = exp_var2
        diff_var3 = exp_var3
        diff_var4 = exp_var4

        diff_var1 = (exp_var1-ctrl_var1)
        diff_var2 = (exp_var2-ctrl_var2)
        diff_var3 = (exp_var3-ctrl_var3)
        diff_var4 = (exp_var4-ctrl_var4)
        
        diff_speed = diff_var2
        diff_speed = sqrt(diff_var2*diff_var2+diff_var3*diff_var3)
        diff_var2@_FillValue=-999
        diff_var2 = where(diff_speed .lt. 0.5, diff_var2@_FillValue,diff_var2)
	end do

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file
  plot_cn_pos = new((/9/),graphic)
  plot_cn_neg = new((/9/),graphic)
  plot_V = new((/9/),graphic)
  plot_sh = new((/9/),graphic)
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"MPL_bwr")

 do n = 0,8
    
    ;-----------------------------------------------------------------------------
    res                  = True       ; use plot options

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels



    ;i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
    ;j = NhlNewColor(wks,1,0.,0.)
    ;  res@mpLandFillColor       = "gray"            ; set land to be gray

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -200          ; set min contour level
    res@cnMaxLevelValF        =  200          ; set max contour level
    res@cnLevelSpacingF       =  20          ; set contour interval

    ;res@cnMinLevelValF        =  -0.15          ; set min contour level
    ;res@cnMaxLevelValF        =  0.15        ; set max contour level
    ;res@cnLevelSpacingF       =  0.025          ; set contour interval
    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    ;res@gsnSpreadColorStart  = 21                ; start at color 17
    ;res@gsnSpreadColorEnd    = 236                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnRightString = ""
    res@gsnCenterString = g_fig_title
    res@gsnLeftString = g_fig_rank(1) 


   ; res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = False
   ; res@gsnPaperOrientation = "portrait"
   ; res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 4 

    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 2 
    res@mpGeophysicalLineColor      = "black";"white" 
    ;res@mpFillDrawOrder="PostDraw"

    res@mpCenterLonF = 180.
    res@mpMaxLonF  = g_lonE
    res@mpMinLonF  = g_lonW

    res@mpMaxLatF  = g_latN
    res@mpMinLatF  = g_latS
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
    res@tmXBTickSpacingF = 30
    res@tmYLTickSpacingF = 15 
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
   	res@tmXBMajorThicknessF = 3.0
	res@tmYLMajorThicknessF = 3.0
	res@tmXBMinorThicknessF = 3.0
	res@tmYLMinorThicknessF = 3.0
	res@tmBorderThicknessF = 3.0
    
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font    
    res@gsnLeftString = "("+g_fig_rank(n)+") Day "+(n+1)
    res@gsnRightString = g_fig_title
    res@gsnCenterString = ""



    plot_sh(n) = gsn_csm_contour_map_ce(wks,diff_var1(n+1,:,:),res) ; create a default plot
      
      res3                  = True       ; use plot options
      res3@cnFillOn         = False;True       ; Fill contours
      res3@cnLinesOn        = True      ; turn off contour lines
    ;for tp masking
      res3@gsnFrame         = False
      res3@gsnDraw  = False
      res3@cnLineLabelsOn   = False      ; turn off contour line labels
      res3@cnLineThicknessF = 2 
      res3@cnInfoLabelOn = False
     
     
      res3@cnLevelSelectionMode="ExplicitLevels"
      res3@cnLevels = (/0.004,0.008,0.012,0.016/)
      res3@cnLineColor      = "Red"
      res3@gsnLeftString      = " "
      res3@gsnRightString      = " "


      plot_cn_pos(n) = gsn_csm_contour(wks,diff_var4(n+1,:,:),res3)

      res3@cnLevels = (/-0.004,-0.008,-0.012,-0.016/)
      res3@cnLineColor      = "Blue"
      res3@cnLineDashPattern      = 1
      
      res3@cnSmoothingOn = True
      
      plot_cn_neg(n) = gsn_csm_contour(wks,diff_var4(n+1,:,:),res3)

    ;
    ;-----------------------------------------------------------------------------
       ;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
    vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.032
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.018
    vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector

    vcres@vcLineArrowHeadMinSizeF   = 0.015
    vcres@vcLineArrowHeadMaxSizeF   = 0.02       
    
    plot_V(n) = gsn_csm_vector(wks,diff_var2(n+1,:,:),diff_var3(n+1,:,:),vcres)

    ;do i = 0,3
    ;    res@gsnLeftString = g_fig_rank(i)
    ;    res@gsnCenterString = g_fig_title(i)
    ;    res@gsnRightString = ""
    ;    plot(i) = gsn_csm_contour_map_ce(wks,dvar1_dt(i,:,:),res) ; create a default plot
    ;end do


    ;************************************************
    ; create points for box in SCS and WNP
    ;************************************************
    ypts = (/ 15.0,  15.0, -0.0,  -0.0, 15.0/)
    xpts = (/110.0, 155.0,155.0, 110.0,110.0/)
    ;************************************************
    ; add the box
    ;************************************************
    resp                  = True                      ; polyline mods desired
    resp@gsLineColor      = "Black"                     ; color of lines
    resp@gsLineThicknessF = 6.0                       ; thickness of lines
    ;resp@gsLineLabelString= "test"                    ; adds a line label string

;    ; create array of dummy graphic variables. This is required, b/c each line
;    ; must be associated with a unique dummy variable.
;
;    dum = new(4,graphic)  
;
;    ; draw each line separately. Each line must contain two points.
;    do i = 0 , 3
;        dum(i)=gsn_add_polyline(wks,plot_sh(n),xpts(i:i+1),ypts(i:i+1),resp)      
;    end do 
;    ;************************************************
;    ; create points for box in southern China
;    ;************************************************
;
;    resp@gsLineDashPattern      = 1                     ; color of lines
;    ypts = (/ 35.0,  35.0, 20.0,  20.0, 35.0/)
;    xpts = (/110.0, 135.0,135.0, 110.0,110.0/)
;
;    dum2 = new(4,graphic)  
;
;    ; draw each line separately. Each line must contain two points.
;    do i = 0 , 3
;        dum2(i)=gsn_add_polyline(wks,plot_sh(n),xpts(i:i+1),ypts(i:i+1),resp)      
;    end do 
      overlay(plot_sh(n),plot_cn_pos(n))
      overlay(plot_sh(n),plot_cn_neg(n))
      overlay(plot_sh(n),plot_V(n))
    delete([/resp,res,res3,vcres/])
end do

  gsn_panel(wks,plot_sh(2::3),(/3,1/),False)
  
  draw(plot_sh)
  frame(wks)
end 
