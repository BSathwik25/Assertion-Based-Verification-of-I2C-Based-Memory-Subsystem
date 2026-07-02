verdiSetActWin -dock widgetDock_<Message>
verdiWindowWorkMode -win $_Verdi_1 -formalVerification
verdiDockWidgetDisplay -dock windowDock_vcstConsole_2
srcSetPreference -vcstOpts \
           {-demo -file run_seq.tcl -prompt vcf -fmode _default -new_verdi_comm}
verdiWindowResize -win $_Verdi_1 "0" "24" "1022" "690"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "0" "24" "1024" "692"
verdiWindowResize -win $_Verdi_1 "0" "24" "1022" "690"
schSetVCSTDelimiter -VHDLGenDelim "."
schUnifiedNetList
verdiSetPrefEnv -bSpecifyWindowTitleForDockContainer "off"
paSetPreference -brightenPowerColor on
paSetPreference -AnnotateSignal off -brightenPowerColor on
paSetPreference -AnnotateSignal off -highlightPowerObject off -brightenPowerColor \
           on
schSetVCSTDelimiter -hierDelim "."
srcSetXpropOption "tmerge"
wvSetPreference -overwrite off
wvSetPreference -getAllSignal off
simSetSimulator "-vcssv" -exec \
           "/home/sathwikb/common/Documents/Final_Project/MUX/Run/vcst_rtdb/.internal/design/seq_top.exe" \
           -args
debImport "-simflow" "-smart_load_kdb" "-dbdir" \
          "/home/sathwikb/common/Documents/Final_Project/MUX/Run/vcst_rtdb/.internal/design/seq_top.exe.daidir"
srcSetPreference -tabNum 16
verdiSeqDebug -xml \
           "/home/sathwikb/common/Documents/Final_Project/MUX/Run/vcst_rtdb/.internal/formal/verdiSeqMapping.xml"
schSetPreference -displayAbstractSrc on
verdiSetActWin -dock widgetDock_VCF:GoalList
verdiRunVcstCmd check_fv

verdiSeqDebug -xml \
           "/home/sathwikb/common/Documents/Final_Project/MUX/Run/vcst_rtdb/.internal/formal/verdiSeqMapping.xml"
verdiRunVcstCmd check_fv

debExit
