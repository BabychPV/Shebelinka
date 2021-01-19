Imports OSIsoft.PI.ACE

Public Class TopMidBmDToD
    Inherits PIACENetClassModule
    Private Tankis15Virsus As PIACEPoint
    Private Tankis15Vidurys As PIACEPoint
    Private Tankis15Apacia As PIACEPoint
    Private Tankis15 As PIACEPoint
    Private clCalcFailed As ArrayList
    '
    '      Tag Name/VB Variable Name Correspondence Table
    ' Tag Name                                VB Variable Name
    ' ------------------------------------------------------------
	' Tankis15                                Tankis15
	' Tankis15Apacia                          Tankis15Apacia
	' Tankis15Vidurys                         Tankis15Vidurys
	' Tankis15Virsus                          Tankis15Virsus
    '
    Public Overrides Sub ACECalculations()
        Dim dblDtop, dblDMid, dblDbot, dblD As Double

        'Load Density
        If clsFunctions.LoadValueFromACEPoint(Tankis15Virsus, Me, dblDtop) = False Then
            CalcFailed()
            Exit Sub
        End If
        If clsFunctions.LoadValueFromACEPoint(Tankis15Apacia, Me, dblDbot) = False Then
            CalcFailed()
            Exit Sub
        End If
        If clsFunctions.LoadValueFromACEPoint(Tankis15Vidurys, Me, dblDMid) = False Then
            CalcFailed()
            Exit Sub
        End If
        dblD = (dblDtop + 3 * dblDMid + dblDbot) / 5
        Tankis15.Value = dblD

    End Sub

    Protected Overrides Sub InitializePIACEPoints()
		Tankis15 = GetPIACEPoint("Tankis15")
		Tankis15Apacia = GetPIACEPoint("Tankis15Apacia")
		Tankis15Vidurys = GetPIACEPoint("Tankis15Vidurys")
		Tankis15Virsus = GetPIACEPoint("Tankis15Virsus")
    End Sub

    '
    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        ACECalculations()
    End Sub

    '
    ' User-written module dependent termination code
    '
    Protected Overrides Sub ModuleDependentTermination()
    End Sub
    Private Sub CalcFailed()
        clCalcFailed = New ArrayList
        clCalcFailed.Add(Tankis15) : clCalcFailed.Add(Tankis15Apacia) : clCalcFailed.Add(Tankis15Virsus) : clCalcFailed.Add(Tankis15Vidurys)
        clsFunctions.SendToPI_CalcIsFailed(Me, clCalcFailed)
    End Sub
End Class
