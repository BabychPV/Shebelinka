Imports OSIsoft.PI.ACE

Public Class LD20TToVM_
    Inherits PIACENetClassModule
    Private PI___________________ As PIACEPoint
    Private PI___________ As PIACEPoint
    Private PI________________2 As PIACEPoint
    Private PI______ As PIACEPoint
    Private PI______________2 As PIACEPoint
    Private PI_______________ As PIACEPoint
    Private PI_____________________ As PIACEPoint
    Private PI_____________ As PIACEPoint
    Private PI_______20 As PIACEPoint
    Private PI______________ As PIACEPoint


    Private T_ris As PIACEPoint
    Private Temperat_ra As PIACEPoint
    Private TankState As PIACEPoint
    Private Tankis20 As PIACEPoint
    Private Nepaimamas_likutis As PIACEPoint
    Private Naudingas_T_ris As PIACEPoint
    Private Naudinga_Mas_ As PIACEPoint
    Private Mas__Viso As PIACEPoint
    Private Mas__maksimali As PIACEPoint
    Private Lygis As PIACEPoint
    Private Darbinis_Tankis As PIACEPoint
    Private AmbTemperature As PIACEPoint


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
    Private Const c_LTECoef As String = "LTECoef"
    '
    '      Tag Name/VB Variable Name Correspondence Table
    ' Tag Name                                VB Variable Name
    ' ------------------------------------------------------------
    '
	' ������� ������                          PI______________
	' �������20                               PI_______20
	' ���� ��������                           PI_____________
	' ���� �������� �������                   PI_____________________
	' ������� �������                         PI_______________
	' ��� ��������                           PI______________2
	' г����                                  PI______
	' ���� ����������                         PI________________2
	' �����������                             PI___________
	' ����������� ������                     PI___________________
    '
    Public Overrides Sub ACECalculations()
        Dim dblLevel, dblVolume, dblTemp, dblAmbTemp, dblD20, dblD, dblMTotal, dblMDead, dblMMax As Double
        Dim dbl_p60, dbl_T, dbl_T20F, dbl_CTPL60, dbl_CTPL, dbl_PSI, dbl_CTSh As Double


        If clsFunctions.InRepair(TankState) Then

            Darbinis_Tankis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            Darbinis_Tankis.Value = 0

            T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            T_ris.Value = 0

            Mas__Viso.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            Mas__Viso.Value = 0

            ' Mas__maksimali.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            'Mas__maksimali.Value = 0

            Nepaimamas_likutis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            Nepaimamas_likutis.Value = dblMDead

            Naudinga_Mas_.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            Naudinga_Mas_.Value = 0

            ' Naudingas_T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
            ' Naudingas_T_ris.Value = 0



            Exit Sub
        End If

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
        If clsFunctions.LoadValueFromACEPoint(Tankis20, Me, dblD20) = False Then
            CalcFailed()
            Exit Sub
        End If


        'Get Volume from Calibration table
        ' If clsFunctions.CalcForTable(dblLevel * 100, calTable, Me, "Level", "Volume total", dblVolume) = False Then
        If clsFunctions.CalcForTable(dblLevel, calTable, Me, "Level", "Volume total", dblVolume) = False Then

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
        'If dbl_T > 300 Then dbl_T = 300
        dbl_T20F = clsFunctions.mCalcNew.StartFunction("CToF", 20)
        'dbl_PSI = clsFunctions.mCalcNew.StartFunction("PaToPsih", (24.6 * 100))


        dbl_CTPL60 = clsFunctions.mCalcNew.StartFunction("CTPL11ToBaseProduct", dblD20, dbl_T20F, 0, s_ProductGroup)

        dbl_p60 = dblD20 / dbl_CTPL60
        dbl_CTPL = clsFunctions.mCalcNew.StartFunction("CTPL11Product", dbl_p60, dbl_T, 0, s_ProductGroup)
        dbl_CTPL = dbl_CTPL60 / dbl_CTPL
        dblD = dblD20 / dbl_CTPL

        'Get Mass
        clsFunctions.CalcMass(dblD / 1000, dblVolume, Me, "Mass", dblMTotal)
        Mas__Viso.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Mas__Viso.Value = dblMTotal

        'clsFunctions.CalcMass(dblD / 1000, dblVolumeMax, Me, "Mass Max", dblMMax)
        'Mas__maksimali.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        ' Mas__maksimali.Value = dblMMax

        clsFunctions.CalcMass(dblD / 1000, dblVolumeDead, Me, "Mass dead", dblMDead)
        Nepaimamas_likutis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Nepaimamas_likutis.Value = dblMDead
        Darbinis_Tankis.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        Darbinis_Tankis.Value = dblD

        Naudinga_Mas_.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates


        If (dblMTotal - dblMDead) < 0 Then
            Naudinga_Mas_.Value = 0
        Else
            Naudinga_Mas_.Value = dblMTotal - dblMDead
        End If
        ' Naudingas_T_ris.ArcMode = PISDK.DataMergeConstants.dmReplaceDuplicates
        ' If (dblVolume - dblVolumeDead) < 0 Then
        'Naudingas_T_ris.Value = 0
        '  Else
        '  Naudingas_T_ris.Value = (dblVolume - dblVolumeDead) * 1000
        '  End If



    End Sub

    Protected Overrides Sub InitializePIACEPoints()
		PI______________ = GetPIACEPoint("PI______________")
		PI_______20 = GetPIACEPoint("PI_______20")
		PI_____________ = GetPIACEPoint("PI_____________")
		PI_____________________ = GetPIACEPoint("PI_____________________")
		PI_______________ = GetPIACEPoint("PI_______________")
		PI______________2 = GetPIACEPoint("PI______________2")
		PI______ = GetPIACEPoint("PI______")
		PI________________2 = GetPIACEPoint("PI________________2")
		PI___________ = GetPIACEPoint("PI___________")
		PI___________________ = GetPIACEPoint("PI___________________")

        Tankis20 = GetPIACEPoint("PI_______20")
        Naudinga_Mas_ = GetPIACEPoint("PI_____________________")
        Nepaimamas_likutis = GetPIACEPoint("PI_______________")
        Darbinis_Tankis = GetPIACEPoint("PI______________")
        Mas__Viso = GetPIACEPoint("PI_____________")
        T_ris = GetPIACEPoint("PI______________2")
        Lygis = GetPIACEPoint("PI______")
        TankState = GetPIACEPoint("PI________________2")
        Temperat_ra = GetPIACEPoint("PI___________")
        AmbTemperature = GetPIACEPoint("PI___________________")

    End Sub

    ' �����                                   PI_____
    ' ������� ������                          PI______________
    ' �������20                               PI_______20
    ' ���� ��������                           PI_____________
    ' ���� �������� �������                   PI_____________________
    ' ������� �������                         PI_______________
    ' ��� ��������                           PI______________2
    ' ���� ����������                         PI________________2
    ' �����������                             PI___________
    ' ����������� ������                     PI___________________
    '
    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        pmRoot = PIACEBIFunctions.GetPIModuleFromPath(Context)

        'Load Calibration Table
        If clsFunctions.LoadValueFromProperty(pmRoot, c_CalTable, Me, calTable) = False Then calTable = 0

        'Load Product Group
        If clsFunctions.LoadValueFromProperty(pmRoot, c_ProductGr, Me, s_ProductGroup) = False Then s_ProductGroup = "Crude Oil"
        If s_ProductGroup = "" Then s_ProductGroup = "Refined Products"

        'Load Linear Thermal Expansion Coefficient
        If clsFunctions.LoadValueFromProperty(pmRoot, c_LTECoef, Me, dblLTEC) = False Then dblLTEC = 0.0000112


        'Load dead and maximum level
        'Get dead and maximum volue
        If clsFunctions.LoadValueFromProperty(pmRoot, c_LevelDead, Me, dblLevelDead) = False Then dblVolumeDead = 0
        If clsFunctions.CalcForTable(dblLevelDead, calTable, Me, c_LevelDead, c_VolumeDead, dblVolumeDead) = False Then dblVolumeDead = 0
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
        clCalcFailed.Add(Lygis) : clCalcFailed.Add(Tankis20) : clCalcFailed.Add(Mas__Viso) : clCalcFailed.Add(T_ris) _
                  : clCalcFailed.Add(Nepaimamas_likutis) : clCalcFailed.Add(AmbTemperature) _
                  : clCalcFailed.Add(Temperat_ra) : clCalcFailed.Add(Naudinga_Mas_) : clCalcFailed.Add(Darbinis_Tankis)
        clsFunctions.SendToPI_CalcIsFailed(Me, clCalcFailed)
    End Sub
End Class
