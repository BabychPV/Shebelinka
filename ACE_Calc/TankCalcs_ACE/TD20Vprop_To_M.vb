Imports OSIsoft.PI.ACE

Public Class TD20Vprop_To_M
    Inherits PIACENetClassModule
    Private Temperatûra As PIACEPoint
    Private Tankis20 As PIACEPoint
    Private Masë_Viso As PIACEPoint
    Private Darbinis_Tankis As PIACEPoint



    Private Const c_Volume As String = "Turis"
    Private dblVolume As Double
    Private s_ProductGroup As String
    Private Const c_ProductGr As String = "ProductGroup"
    Private pmRoot As PISDK.PIModule
    Private clCalcFailed As ArrayList
    '
    '      Tag Name/VB Variable Name Correspondence Table
    ' Tag Name                                VB Variable Name
    ' ------------------------------------------------------------
	' Darbinis Tankis                         Darbinis_Tankis
	' Masë Viso                               Masë_Viso
	' Tankis20                                Tankis20
	' Temperatûra                             Temperatûra
    '
    Public Overrides Sub ACECalculations()
        Dim dbl_p60, dbl_T, dbl_T20F, dbl_CTPL60, dbl_CTPL, dbl_PSI, dbl_CTSh As Double
        Dim dblTemp, dblD20, dblD, dblM As Double


        'Load Temperature
        If clsFunctions.LoadValueFromACEPoint(Temperatûra, Me, dblTemp) = False Then
            'CalcFailed()
            'Exit Sub
            dblTemp = 20
        End If

        'Load Density
        If clsFunctions.LoadValueFromACEPoint(Tankis20, Me, dblD20) = False Then
            CalcFailed()
            Exit Sub
        End If


        'Calculate density 
        'Convert engunits to API
        dbl_T = clsFunctions.mCalcNew.StartFunction("CToF", dblTemp)
        'If dbl_T > 300 Then dbl_T = 300
        dbl_T20F = clsFunctions.mCalcNew.StartFunction("CToF", 20)
        'dbl_PSI = clsFunctions.mCalcNew.StartFunction("PaToPsih", (24.6 * 100))


        dbl_CTPL60 = clsFunctions.mCalcNew.StartFunction("CTPL11ToBaseProduct", dblD20, dbl_T20F, 0, s_ProductGroup)

        dbl_p60 = dblD20 / dbl_CTPL60
        dbl_CTPL = clsFunctions.mCalcNew.StartFunction("CTPL11Product", dbl_p60, dbl_T, 0, s_ProductGroup)
        dbl_CTPL = dbl_CTPL60 / dbl_CTPL
        dblD = dblD20 / dbl_CTPL

        Darbinis_Tankis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Darbinis_Tankis.Value = dblD

        'Get Mass
        clsFunctions.CalcMass(dblD / 1000, dblVolume / 1000, Me, "Mass", dblM)
        Masë_Viso.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Masë_Viso.Value = dblM



    End Sub

    Protected Overrides Sub InitializePIACEPoints()
		Darbinis_Tankis = GetPIACEPoint("Darbinis_Tankis")
		Masë_Viso = GetPIACEPoint("Masë_Viso")
		Tankis20 = GetPIACEPoint("Tankis20")
		Temperatûra = GetPIACEPoint("Temperatûra")
    End Sub

    '
    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        pmRoot = PIACEBIFunctions.GetPIModuleFromPath(Context)

        'Load Calibration Table
        If clsFunctions.LoadValueFromProperty(pmRoot, c_Volume, Me, dblVolume) = False Then dblVolume = 0
        'Load Product Group
        If clsFunctions.LoadValueFromProperty(pmRoot, c_ProductGr, Me, s_ProductGroup) = False Then s_ProductGroup = "Crude Oil"
    End Sub

    '
    ' User-written module dependent termination code
    '
    Protected Overrides Sub ModuleDependentTermination()
    End Sub
    Private Sub CalcFailed()
        clCalcFailed = New ArrayList
        clCalcFailed.Add(Darbinis_Tankis) : clCalcFailed.Add(Masë_Viso)
        clsFunctions.SendToPI_CalcIsFailed(Me, clCalcFailed)
    End Sub
End Class
