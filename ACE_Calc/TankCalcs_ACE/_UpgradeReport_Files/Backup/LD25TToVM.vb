Imports OSIsoft.PI.ACE

Public Class LD25TToVM
    Inherits PIACENetClassModule
    Private T_ris As PIACEPoint
    Private Temperat_ra As PIACEPoint
    Private Tankis25 As PIACEPoint
    Private Nepaimamas_likutis As PIACEPoint
    Private Naudingas_T_ris As PIACEPoint
    Private Naudinga_Mas_ As PIACEPoint
    Private Mas__Viso As PIACEPoint
    Private Mas__maksimali As PIACEPoint
    Private Lygis As PIACEPoint
    Private Darbinis_Tankis As PIACEPoint
    Private AmbTemperature As PIACEPoint
    '
    '      Tag Name/VB Variable Name Correspondence Table
    ' Tag Name                                VB Variable Name
    ' ------------------------------------------------------------
    '

    Private pmRoot As PISDK.PIModule, dblVolumeDead, dblLevelDead, dblVolumeMax, dblLevelMax, dblLTEC As Double
    Private s_ProductGroup As String
    Private calTable As Object
    Private clCalcFailed As ArrayList

    Private Const c_CalTable As String = "Calibration Table"
    Private Const c_ProductGr As String = "ProductGroup"
    Private Const c_LevelDead As String = "DeadLevel"
    Private Const c_VolumeDead As String = "DeadVolume"
    Private Const c_LevelMax As String = "MaxLevel"
    Private Const c_VolumeMax As String = "MaxVolume"
	' AmbTemperature                          AmbTemperature
	' Darbinis Tankis                         Darbinis_Tankis
	' Lygis                                   Lygis
	' Masë maksimali                          Mas__maksimali
	' Masë Viso                               Mas__Viso
	' Naudinga Masë                           Naudinga_Mas_
	' Naudingas Tûris                         Naudingas_T_ris
	' Nepaimamas likutis                      Nepaimamas_likutis
	' Tankis25                                Tankis25
	' Temperatûra                             Temperat_ra
	' Tûris                                   T_ris
    Private Const c_LTECoef As String = "LTECoef"
    Public Overrides Sub ACECalculations()
        Dim dblLevel, dblVolume, dblTemp, dblAmbTemp, dblD25, dblD, dblMTotal, dblMDead, dblMMax As Double
        Dim dbl_p60, dbl_T, dbl_T25F, dbl_CTPL60, dbl_CTPL, dbl_PSI, dbl_CTSh As Double


        'Load Level
        If clsFunctions.LoadValueFromACEPoint(Lygis, Me, dblLevel) = False Then
            CalcFailed()
            Exit Sub
        End If


        'Load Temperature
        If clsFunctions.LoadValueFromACEPoint(Temperat_ra, Me, dblTemp) = False Then
            CalcFailed()
            Exit Sub
        End If
        If clsFunctions.LoadValueFromACEPoint(AmbTemperature, Me, dblAmbTemp) = False Then
            CalcFailed()
            Exit Sub
        End If

        'Load Density
        If clsFunctions.LoadValueFromACEPoint(Tankis25, Me, dblD25) = False Then
            CalcFailed()
            Exit Sub
        End If


        'Get Volume from Calibration table
        If clsFunctions.CalcForTable(dblLevel * 100, calTable, Me, "Level", "Volume total", dblVolume) = False Then
            CalcFailed()
            Exit Sub
        End If
        dblVolume = dblVolume / 1000

        'Correction for the Effect of Temperature on the Steel Shell of the Tank (CTSh)
        dbl_CTSh = clsFunctions.CTSh_API_12_1_1NonIzolated(dblTemp, dblAmbTemp, 15, dblLTEC)
        dblVolume = dblVolume * dbl_CTSh
        T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        T_ris.Value = dblVolume * 1000



        'Calculate density 
        'Convert engunits to API
        dbl_T = clsFunctions.mCalcNew.StartFunction("CToF", dblTemp)
        dbl_T25F = clsFunctions.mCalcNew.StartFunction("CToF", 25)
        'dbl_PSI = clsFunctions.mCalcNew.StartFunction("PaToPsih", (24.6 * 100))


        dbl_CTPL60 = clsFunctions.mCalcNew.StartFunction("CTPL11ToBaseProduct", dblD25, dbl_T25F, 0, s_ProductGroup)

        dbl_p60 = dblD25 / dbl_CTPL60
        'If dbl_T > 300 Then dbl_T = 300
        dbl_CTPL = clsFunctions.mCalcNew.StartFunction("CTPL11Product", dbl_p60, dbl_T, 0, s_ProductGroup)
        dbl_CTPL = dbl_CTPL60 / dbl_CTPL
        dblD = dblD25 / dbl_CTPL

        'Get Mass
        clsFunctions.CalcMass(dblD / 1000, dblVolume, Me, "Mass", dblMTotal)
        Mas__Viso.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Mas__Viso.Value = dblMTotal
        clsFunctions.CalcMass(dblD / 1000, dblVolumeMax, Me, "Mass Max", dblMMax)
        Mas__maksimali.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Mas__maksimali.Value = dblMMax
        clsFunctions.CalcMass(dblD / 1000, dblVolumeDead, Me, "Mass dead", dblMDead)
        Nepaimamas_likutis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Nepaimamas_likutis.Value = dblMDead

        Naudinga_Mas_.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Darbinis_Tankis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Darbinis_Tankis.Value = dblD
        If (dblMTotal - dblMDead) < 0 Then
            Naudinga_Mas_.Value = 0
        Else
            Naudinga_Mas_.Value = dblMTotal - dblMDead
        End If
        Naudingas_T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        If (dblVolume - dblVolumeDead) < 0 Then
            Naudingas_T_ris.Value = 0
        Else
            Naudingas_T_ris.Value = (dblVolume - dblVolumeDead) * 1000
        End If


    End Sub

    Protected Overrides Sub InitializePIACEPoints()
		AmbTemperature = GetPIACEPoint("AmbTemperature")
		Darbinis_Tankis = GetPIACEPoint("Darbinis_Tankis")
		Lygis = GetPIACEPoint("Lygis")
		Mas__maksimali = GetPIACEPoint("Mas__maksimali")
		Mas__Viso = GetPIACEPoint("Mas__Viso")
		Naudinga_Mas_ = GetPIACEPoint("Naudinga_Mas_")
		Naudingas_T_ris = GetPIACEPoint("Naudingas_T_ris")
		Nepaimamas_likutis = GetPIACEPoint("Nepaimamas_likutis")
		Tankis25 = GetPIACEPoint("Tankis25")
		Temperat_ra = GetPIACEPoint("Temperat_ra")
		T_ris = GetPIACEPoint("T_ris")
    End Sub

    '
    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        pmRoot = PIACEBIFunctions.GetPIModuleFromPath(Context)

        'Load Calibration Table
        If clsFunctions.LoadValueFromProperty(pmRoot, c_CalTable, Me, calTable) = False Then calTable = 0

        'Load Product Group
        If clsFunctions.LoadValueFromProperty(pmRoot, c_ProductGr, Me, s_ProductGroup) = False Then s_ProductGroup = "Crude Oil"

        'Load Linear Thermal Expansion Coefficient
        If clsFunctions.LoadValueFromProperty(pmRoot, c_LTECoef, Me, dblLTEC) = False Then dblLTEC = 0.0000112


        'Load dead and maximum level
        'Get dead and maximum volue
        If clsFunctions.LoadValueFromProperty(pmRoot, c_LevelDead, Me, dblLevelDead) = False Then dblVolumeDead = 0
        If clsFunctions.CalcForTable(dblLevelDead * 100, calTable, Me, c_LevelDead, c_VolumeDead, dblVolumeDead) = False Then dblVolumeDead = 0
        clsFunctions.SendValueToProperty(pmRoot, c_VolumeDead, Me, dblVolumeDead)
        dblVolumeDead = dblVolumeDead / 1000

        'If clsFunctions.LoadValueFromProperty(pmRoot, c_LevelMax, Me, dblLevelMax) = False Then dblVolumeMax = 0
        'If clsFunctions.CalcForTable(dblLevelMax * 100, calTable, Me, c_LevelMax, c_VolumeMax, dblVolumeMax) = False Then dblVolumeMax = 0
        'clsFunctions.SendValueToProperty(pmRoot, c_VolumeMax, Me, dblVolumeMax)

        If clsFunctions.LoadValueFromProperty(pmRoot, c_VolumeMax, Me, dblVolumeMax) = False Then dblVolumeMax = 0
        dblVolumeMax = dblVolumeMax / 1000
        'If clsFunctions.LoadValueFromProperty(pmRoot, c_VolumeDead, Me, dblVolumeDead) = False Then dblVolumeDead = 0
        'dblVolumeDead = dblVolumeDead / 1000
    End Sub

    '
    ' User-written module dependent termination code
    '
    Protected Overrides Sub ModuleDependentTermination()
    End Sub
    Private Sub CalcFailed()
        clCalcFailed = New ArrayList
        clCalcFailed.Add(Lygis) : clCalcFailed.Add(Tankis25) : clCalcFailed.Add(Mas__Viso) : clCalcFailed.Add(T_ris) _
                    : clCalcFailed.Add(Nepaimamas_likutis) : clCalcFailed.Add(Mas__maksimali) : clCalcFailed.Add(AmbTemperature) _
                    : clCalcFailed.Add(Temperat_ra) : clCalcFailed.Add(Naudinga_Mas_) : clCalcFailed.Add(Naudingas_T_ris) : clCalcFailed.Add(Darbinis_Tankis)
        clsFunctions.SendToPI_CalcIsFailed(Me, clCalcFailed)
    End Sub
End Class
