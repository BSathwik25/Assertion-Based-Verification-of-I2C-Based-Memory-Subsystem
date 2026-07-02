verdiSetActWin -dock widgetDock_<Message>
verdiWindowWorkMode -win $_Verdi_1 -formalVerification
verdiDockWidgetDisplay -dock windowDock_vcstConsole_2
srcSetPreference -vcstOpts \
           {-demo -file run_fpv.tcl -prompt vcf -fmode _default -new_verdi_comm}
verdiSetActWin -win $_vcstConsole_2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_VCF:TaskList
schSetVCSTDelimiter -VHDLGenDelim "."
schUnifiedNetList
schSetVCSTDelimiter -hierDelim "."
srcSetXpropOption "tmerge"
wvSetPreference -overwrite off
wvSetPreference -getAllSignal off
simSetSimulator "-vcssv" -exec \
           "/home/sathwikb/common/Documents/Final_Project/top_I2C/Run/vcst_rtdb/.internal/design/simv" \
           -args
debImport "-simflow" "-smart_load_kdb" "-dbdir" \
          "/home/sathwikb/common/Documents/Final_Project/top_I2C/Run/vcst_rtdb/.internal/design/simv.daidir" \
          -autoalias
srcSetPreference -tabNum 16
srcSetBlackbox -delim . -inst "top_I2C.i_I2C_slave.cover_slave" \
           "top_I2C.i_I2C_slave.u_i2c_slave_cov"
debLoadUserDefinedFile \
           /home/sathwikb/common/Documents/Final_Project/top_I2C/Run/vcst_rtdb/.internal/verdi/constant.uddb
srcSetOptions -userAnnot on -win $_nTrace1 -field 2
opVerdiComponents -xmlstr \
           "<Command delimiter=\"/\" name=\"schSession\">
<HighlightObjs clear=\"true\"/>
</Command>
"
opVerdiComponents -xmlstr \
           "<Command delimiter=\"/\" name=\"schSession\">
<HighlightObjs>
<H_Nets>
<H_Net name=\"top_I2C/reset_n\" text=\"C:1\" color=\"2\"/>
</H_Nets>
</HighlightObjs>
</Command>
"
verdiRunVcstCmd check_fv

verdiSetActWin -dock widgetDock_VCF:GoalList
debExit
