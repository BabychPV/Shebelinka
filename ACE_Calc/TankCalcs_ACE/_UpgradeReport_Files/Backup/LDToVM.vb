Imports OSIsoft.PI.ACE

Public Class LDToVM
    Inherits PIACENetClassModule
    Private T_ris As PIACEPoint
    Private Nepaimamas_likutis As PIACEPoint
    Private Naudingas_T_ris As PIACEPoint
    Private Naudinga_Mas_ As PIACEPoint
    Private Mas__Viso As PIACEPoint
    Private Mas__maksimali As PIACEPoint
    Private Lygis As PIACEPoint
    Private Darbinis_Tankis As PIACEPoint
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
	' Darbinis Tankis                         Darbinis_Tankis
	' Lygis                                   Lygis
	' Masë maksimali                          Mas__maksimali
	' Masë Viso                               Mas__Viso
	' Naudinga Masë                           Naudinga_Mas_
	' Naudingas Tûris                         Naudingas_T_ris
	' Nepaimamas likutis                      Nepaimamas_likutis
	' Tûris                                   T_ris
    Private Const c_LTECoef As String = "LTECoef"
    Public Overrides Sub ACECalculations()
        Dim dblLevel, dblVolume, dblD, dblMTotal, dblMDead, dblMMax As Double
        

        'Load Level
        If clsFunctions.LoadValueFromACEPoint(Lygis, Me, dblLevel) = False Then
            CalcFailed()
            Exit Sub
        End If


        'Load Density
        If clsFunctions.LoadValueFromACEPoint(Darbinis_Tankis, Me, dblD) = False Then
            CalcFailed()
            Exit Sub
        End If


        'Get Volume from Calibration table
        If clsFunctions.CalcForTable(dblLevel * 100, calTable, Me, "Level", "Volume total", dblVolume) = False Then
            CalcFailed()
            Exit Sub
        End If
        dblVolume = dblVolume / 1000
        T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        T_ris.Value = dblVolume * 1000


        'Get Mass
        clsFunctions.CalcMass(dblD / 1000, dblVolume, Me, "Mass", dblMTotal)
        Mas__Viso.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Mas__Viso.Value = dblMTotal
        clsFunctions.CalcMass(dblD / 1000, dblVolumeMax, Me, "Mass Max", dblMMax)
        Mas__maksimali.Value = dblMMax
        clsFunctions.CalcMass(dblD / 1000, dblVolumeDead, Me, "Mass dead", dblMDead)
        Nepaimamas_likutis.Value = dblMDead

        If (dblMTotal - dblMDead) < 0 Then
            Naudinga_Mas_.Value = 0
        Else
            Naudinga_Mas_.Value = dblMTotal - dblMDead
        End If

        If (dblVolume - dblVolumeDead) < 0 Then
            Naudingas_T_ris.Value = 0
        Else
            Naudingas_T_ris.Value = dblVolume - dblVolumeDead
        End If


    End Sub

    Protected Overrides Sub InitializePIACEPoints()
		Darbinis_Tankis = GetPIACEPoint("Darbinis_Tankis")
		Lygis = GetPIACEPoint("Lygis")
		Mas__maksimali = GetPIACEPoint("Mas__maksimali")
		Mas__Viso = GetPIACEPoint("Mas__Viso")
		Naudinga_Mas_ = GetPIACEPoint("Naudinga_Mas_")
		Naudingas_T_ris = GetPIACEPoint("Naudingas_T_ris")
		Nepaimamas_likutis = GetPIACEPoint("Nepaimamas_likutis")
		T_ris = GetPIACEPoint("T_ris")

        Darbinis_Tankis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Lygis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Mas__maksimali.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Mas__Viso.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Naudinga_Mas_.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Naudingas_T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Nepaimamas_likutis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
    End Sub

    '
    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        pmRoot = PIACEBIFunctions.GetPIModuleFromPath(Context)

        'Load Calibration Table
        If clsFunctions.LoadValueFromProperty(pmRoot, c_CalTable, Me, calTable) = False Then calTable = 0

        If clsFunctions.LoadValueFromProperty(pmRoot, c_VolumeMax, Me, dblVolumeMax) = False Then dblVolumeMax = 0
        dblVolumeMax = dblVolumeMax / 1000

        If clsFunctions.LoadValueFromProperty(pmRoot, c_LevelDead, Me, dblLevelDead) = False Then dblLevelDead = 0
        'Get Volume from Calibration table
        If clsFunctions.CalcForTable(dblLevelDead * 100, calTable, Me, "Level dead", "Volume dead", dblVolumeDead) = False Then
            CalcFailed()
            Exit Sub
        End If
        dblVolumeDead = dblVolumeDead / 1000
        clsFunctions.SendValueToProperty(pmRoot, c_VolumeDead, Me, dblVolumeDead * 1000)

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
        clCalcFailed.Add(Lygis) : clCalcFailed.Add(Mas__Viso) : clCalcFailed.Add(T_ris) _
                : clCalcFailed.Add(Nepaimamas_likutis) : clCalcFailed.Add(Mas__maksimali) _
                : clCalcFailed.Add(Darbinis_Tankis) : clCalcFailed.Add(Naudinga_Mas_) : clCalcFailed.Add(Naudingas_T_ris)
        clsFunctions.SendToPI_CalcIsFailed(Me, clCalcFailed)
    End Sub
End Class
