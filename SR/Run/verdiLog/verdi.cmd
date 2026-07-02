verdiSetActWin -dock widgetDock_<Message>
verdiWindowWorkMode -win $_Verdi_1 -formalVerification
verdiDockWidgetDisplay -dock windowDock_vcstConsole_2
srcSetPreference -vcstOpts \
           {-demo -file run_seq.tcl -prompt vcf -fmode _default -new_verdi_comm}
verdiWindowResize -win $_Verdi_1 "0" "24" "1022" "690"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_VCF:TaskList
verdiWindowResize -win $_Verdi_1 "0" "24" "1022" "690"
schSetVCSTDelimiter -VHDLGenDelim "."
schUnifiedNetList
schSetVCSTDelimiter -hierDelim "."
srcSetXpropOption "tmerge"
wvSetPreference -overwrite off
wvSetPreference -getAllSignal off
simSetSimulator "-vcssv" -exec \
           "/home/sathwikb/common/Documents/Final_Project/SR/Run/vcst_rtdb/.internal/design/seq_top.exe" \
           -args
debImport "-simflow" "-smart_load_kdb" "-dbdir" \
          "/home/sathwikb/common/Documents/Final_Project/SR/Run/vcst_rtdb/.internal/design/seq_top.exe.daidir"
srcSetPreference -tabNum 16
verdiSeqDebug -xml \
           "/home/sathwikb/common/Documents/Final_Project/SR/Run/vcst_rtdb/.internal/formal/verdiSeqMapping.xml"
schSetPreference -displayAbstractSrc on
debLoadUserDefinedFile \
           /home/sathwikb/common/Documents/Final_Project/SR/Run/vcst_rtdb/.internal/verdi/constant.uddb
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
<H_Net name=\"seq_top/spec/Clear\" text=\"C:1\" color=\"2\"/>
</H_Nets>
</HighlightObjs>
</Command>
"
verdiRunVcstCmd check_fv

verdiSeqDebug -xml \
           "/home/sathwikb/common/Documents/Final_Project/SR/Run/vcst_rtdb/.internal/formal/verdiSeqMapping.xml"
verdiSetActWin -dock widgetDock_VCF:GoalList
verdiSetActWin -win $_vcstConsole_2
debExit
