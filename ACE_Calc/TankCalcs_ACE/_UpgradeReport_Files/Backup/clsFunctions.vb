Imports OSIsoft.PI.ACE
Public Class clsFunctions

    Private Shared _mCalcNew As ICalcComponentLib.ICalculator
    '=================================Load values from properties======================
    Public Shared Function LoadValueFromProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    ByRef arValue As Object) As Boolean
        Dim pp As PISDK.PIProperty

        Try
            pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
        Catch ex As Exception
            Try
                pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
            Catch ex1 As Exception
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Can't load property. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)
            End Try
            Return False
        End Try

        If pp.Value.GetType Is GetType(System.Double()) Then
            arValue = pp.Value
        ElseIf IsNumeric(pp.Value) Then
            arValue = pp.Value
        Else
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Property value have wrong type. Name=" & nameProperty & _
            ". Type=" & pp.Value.GetType.ToString, aceClass.Name)
            Return False
        End If

        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Property have been loaded. Name=" & nameProperty, aceClass.Name)
        Return True
    End Function
    Public Shared Function LoadValueFromProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    ByRef value As Double) As Boolean
        Dim pp As PISDK.PIProperty

        Try
            pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
        Catch ex As Exception
            Try
                pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
            Catch ex1 As Exception
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Can't load property. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)
                Return False
            End Try

        End Try

        If IsNumeric(pp.Value) Then
            value = pp.Value
        ElseIf pp.Value.GetType Is GetType(System.Double()) Then
            value = pp.Value
        Else
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Property value have wrong type. Name=" & nameProperty & _
            ". Type=" & pp.Value.GetType.ToString, aceClass.Name)
            Return False
        End If

        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Property have been loaded. Name=" & nameProperty & ". Value=" & value, aceClass.Name)
        Return True

    End Function
    Public Shared Function LoadValueFromProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
  ByRef value As String) As Boolean
        Dim pp As PISDK.PIProperty

        Try
            pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
        Catch ex As Exception
            Try
                pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
            Catch ex1 As Exception
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Can't load property. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)
                Return False
            End Try

        End Try

        If pp.Value.GetType Is GetType(String) Then
            value = pp.Value
        Else
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Property value have wrong type. Name=" & nameProperty & _
            ". Type=" & pp.Value.GetType.ToString, aceClass.Name)
            Return False
        End If

        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Property have been loaded. Name=" & nameProperty & ". Value=" & value, aceClass.Name)
        Return True

    End Function
    '===================Getting value from ACE Points========================='
    Public Shared Function LoadValueFromACEPoint(ByVal ptACE As PIACEPoint, ByVal aceClass As PIACENetClassModule, ByRef dblValue As Double) As Boolean

        If ptACE.IsSet("s") = True Then ptACE.ResetCurrentValue()

        If Not ptACE.IsGood Then
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Value have bad status. Tag name=" & ptACE.Tag & ". Value=" & _
            ptACE.Value.ToString, aceClass.Name)
            Return False
        End If

        Try
            dblValue = ptACE.Value
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Value have been loaded. Tag name=" & ptACE.Tag & _
            ". Value=" & dblValue, aceClass.Name)
            Return True
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. can't get Value. Tag name=" & ptACE.Tag, aceClass.Name)
            Return False
        End Try

    End Function
    Public Shared Function LoadValueFromACEPoint(ByVal ptACE As PIACEPoint, ByVal aceClass As PIACENetClassModule, ByRef value As String) As Boolean

        If ptACE.IsSet("s") = True Then ptACE.ResetCurrentValue()

        If Not ptACE.IsGood Then
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Value have bad status. Tag name=" & ptACE.Tag & ". Value=" & _
            ptACE.Value.ToString, aceClass.Name)
            Return False
        End If

        Try
            value = ptACE.Value
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Value have been loaded. Tag name=" & ptACE.Tag & _
            ". Value=" & value, aceClass.Name)
            Return True
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. can't get Value. Tag name=" & ptACE.Tag, aceClass.Name)
            Return False
        End Try

    End Function
    Public Shared Function LoadLastValueFromACEPoint(ByVal server As PISDK.Server, ByVal ptACE As PIACEPoint, ByVal aceClass As PIACENetClassModule, _
    ByRef value As String, ByRef time As Double) As Boolean
        Dim pv As PISDK.PIValue
        pv = server.PIPoints(ptACE.Tag).Data.ArcValue(Now, PISDK.RetrievalTypeConstants.rtBefore)

        If Not pv.IsGood Then
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Value have bad status. Tag name=" & ptACE.Tag & ". Value=" & _
            pv.Value.ToString, aceClass.Name)
            Return False
        End If

        Try
            value = pv.Value
            time = pv.TimeStamp.UTCSeconds
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Value have been loaded. Tag name=" & ptACE.Tag & _
            ". Value=" & value, aceClass.Name)
            Return True
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. can't get Value. Tag name=" & ptACE.Tag, aceClass.Name)
            Return False
        End Try

    End Function
    '=================Calculate Volume============================='
    Public Shared Function CalcForTable(ByVal dblSource As Double, ByVal calTable As Object, ByVal aceClass As PIACENetClassModule, _
    ByVal paramSource As String, ByVal paramResult As String, ByRef dblResult As Double) As Boolean

        If calTable.GetType Is GetType(System.Double()) Then
            If RecalcForTable(calTable, dblSource, dblResult) = False Then
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Data not calculated. Name=" & paramResult & ". Source data=" & paramSource & _
                ". Value=" & dblSource, aceClass.Name)
                Return False
            End If
        ElseIf IsNumeric(calTable) Then
            dblResult = dblSource * CType(calTable, Double)
        Else
            Return False
        End If

        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Data have been calculated. Name=" & paramResult & ". Value=" & dblResult, aceClass.Name)
        Return True

    End Function
    Private Shared Function RecalcForTable(ByVal arCm As Object, ByVal dblSource As Double, ByRef dblResult As Double) As Boolean
        Dim dblSourcePrev, dblSourceNext As Double

        dblResult = 0
        dblSourcePrev = Fix(dblSource)

        Try
            dblResult = CType(arCm(dblSourcePrev), Double)
        Catch ex As Exception
            Return False
        End Try

        If dblSource = dblSourcePrev Then Return True

        dblSourceNext = dblSourcePrev + 1
        Try
            dblResult += ((CType(arCm(dblSourceNext), Double) - dblResult) * (dblSource - dblSourcePrev))
        Catch ex As Exception
        End Try

        dblResult = FormatNumber(dblResult, 4)
        Return True
    End Function

    '=================Calculate Mass============================='
    Public Shared Sub CalcMass(ByVal dblDensity As Double, ByVal dblVolume As Double, ByVal aceClass As PIACENetClassModule, _
    ByVal paramName As String, ByRef dblMass As Double)
        dblMass = dblDensity * dblVolume
        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Data have been calculated. Name=" & paramName & ". Value=" & dblMass, aceClass.Name)
    End Sub
    Public Shared Sub CalcMass(ByVal dblDensity As Double, ByVal dblVolume As Double, ByVal dblVolumeDead As Double, ByVal aceClass As PIACENetClassModule, _
    ByVal paramName As String, ByRef dblMass As Double)
        dblMass = dblDensity * (dblVolume - dblVolumeDead)
        If dblMass < 0 Then dblMass = 0
        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Data have been calculated. Name=" & paramName & ". Value=" & dblMass, aceClass.Name)
    End Sub
    Public Shared Sub CalcMassSumTime(ByVal startTime As Date, ByVal endTime As Date, ByVal aceClass As PIACENetClassModule, ByVal pt As PISDK.PIPoint, _
    ByVal paramName As String, ByRef dblMass As Double)
        dblMass = 0

        Try
            dblMass = pt.Data.Summary(startTime, endTime, PISDK.ArchiveSummaryTypeConstants.astTotal, PISDK.CalculationBasisConstants.cbEventWeighted).Value
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Data have been calculated. Name=" & paramName & ". Value=" & dblMass, aceClass.Name)
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Data not calculated. Name=" & paramName & ". Tag=" & pt.Name & _
            ". Start time=" & startTime & ". End time=" & endTime & " >> " & ex.Message, aceClass.Name)
        End Try
    End Sub

    '=================Calculate density============================='
    Public Shared Sub CalcDensityH2SO4(ByVal dblMp As Double, ByRef dblD As Double, ByVal aceClass As PIACENetClassModule, _
    ByVal paramName As String)
        Dim Mp1, Mp2, D1, D2 As Double

        Mp1 = 0.261 : Mp2 = 3.242 : D1 = 1 : D2 = 1.02
        If dblMp < 0 Then
            dblD = 0 : Exit Sub
        End If

        If dblMp >= 0 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 3.242 : Mp2 = 6.237 : D1 = 1.02 : D2 = 1.04
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 6.237 : Mp2 = 9.129 : D1 = 1.04 : D2 = 1.06
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 9.129 : Mp2 = 11.96 : D1 = 1.06 : D2 = 1.08
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 11.96 : Mp2 = 14.73 : D1 = 1.08 : D2 = 1.1
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 14.73 : Mp2 = 17.43 : D1 = 1.1 : D2 = 1.12
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 17.43 : Mp2 = 18.76 : D1 = 1.12 : D2 = 1.13
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2) : Exit Sub
        End If

        Mp1 = 18.76 : Mp2 = 23.95 : D1 = 1.13 : D2 = 1.17
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 23.95 : Mp2 = 25.21 : D1 = 1.17 : D2 = 1.18
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 25.21 : Mp2 = 27.72 : D1 = 1.18 : D2 = 1.2
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 27.72 : Mp2 = 30.18 : D1 = 1.2 : D2 = 1.22
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 30.18 : Mp2 = 32.61 : D1 = 1.22 : D2 = 1.24
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 30.18 : Mp2 = 32.61 : D1 = 1.22 : D2 = 1.24
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 32.61 : Mp2 = 35.01 : D1 = 1.24 : D2 = 1.26
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 35.01 : Mp2 = 37.36 : D1 = 1.26 : D2 = 1.28
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 37.36 : Mp2 = 39.68 : D1 = 1.28 : D2 = 1.3
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 39.68 : Mp2 = 41.95 : D1 = 1.3 : D2 = 1.32
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 41.95 : Mp2 = 44.17 : D1 = 1.32 : D2 = 1.34
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 44.17 : Mp2 = 46.33 : D1 = 1.34 : D2 = 1.36
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 46.33 : Mp2 = 48.45 : D1 = 1.36 : D2 = 1.38
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 48.45 : Mp2 = 50.5 : D1 = 1.38 : D2 = 1.4
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 50.5 : Mp2 = 52.51 : D1 = 1.4 : D2 = 1.42
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 52.51 : Mp2 = 54.49 : D1 = 1.42 : D2 = 1.44
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 54.49 : Mp2 = 56.41 : D1 = 1.44 : D2 = 1.46
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 56.41 : Mp2 = 58.31 : D1 = 1.46 : D2 = 1.48
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 58.31 : Mp2 = 60.17 : D1 = 1.48 : D2 = 1.5
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 60.17 : Mp2 = 62 : D1 = 1.5 : D2 = 1.52
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 62 : Mp2 = 63.81 : D1 = 1.52 : D2 = 1.54
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 63.81 : Mp2 = 65.59 : D1 = 1.54 : D2 = 1.56
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 65.59 : Mp2 = 67.35 : D1 = 1.56 : D2 = 1.58
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 67.35 : Mp2 = 69.09 : D1 = 1.58 : D2 = 1.6
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 69.09 : Mp2 = 70.82 : D1 = 1.6 : D2 = 1.62
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 70.82 : Mp2 = 72.52 : D1 = 1.62 : D2 = 1.64
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 72.52 : Mp2 = 74.22 : D1 = 1.64 : D2 = 1.66
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 74.22 : Mp2 = 75.92 : D1 = 1.66 : D2 = 1.68
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 75.92 : Mp2 = 77.63 : D1 = 1.68 : D2 = 1.7
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 77.63 : Mp2 = 79.37 : D1 = 1.7 : D2 = 1.72
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 79.37 : Mp2 = 81.16 : D1 = 1.72 : D2 = 1.74
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 81.16 : Mp2 = 83.06 : D1 = 1.74 : D2 = 1.76
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 83.06 : Mp2 = 85.16 : D1 = 1.76 : D2 = 1.78
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 85.16 : Mp2 = 87.69 : D1 = 1.78 : D2 = 1.8
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 87.69 : Mp2 = 91.11 : D1 = 1.8 : D2 = 1.82
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 91.11 : Mp2 = 91.56 : D1 = 1.82 : D2 = 1.822
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 91.56 : Mp2 = 92 : D1 = 1.822 : D2 = 1.824
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 92 : Mp2 = 92.51 : D1 = 1.824 : D2 = 1.826
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 92.51 : Mp2 = 93.03 : D1 = 1.826 : D2 = 1.828
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 93.03 : Mp2 = 93.64 : D1 = 1.828 : D2 = 1.83
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 93.64 : Mp2 = 94.32 : D1 = 1.83 : D2 = 1.832
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 94.32 : Mp2 = 95.12 : D1 = 1.832 : D2 = 1.834
        If dblMp >= Mp1 And dblMp <= Mp2 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        Mp1 = 95.12 : Mp2 = 95.72 : D1 = 1.834 : D2 = 1.835
        If dblMp >= Mp1 Then
            dblD = Formula_MptoD(dblMp, Mp1, Mp2, D1, D2)
            Exit Sub
        End If

        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Data have been calculated. Name=" & paramName & ". Value=" & dblD, aceClass.Name)
    End Sub
    Private Shared Function Formula_MptoD(ByVal dblMp As Double, ByVal Mp1 As Double, ByVal Mp2 As Double, ByVal D1 As Double, ByVal D2 As Double) As Double
        Return (D1 + (dblMp - Mp1) * (D2 - D1) / (Mp2 - Mp1))
    End Function

    '**********************************************If calculating faild********************************************************
    Public Shared Sub SendToPI_CalcIsFailed(ByVal aceClass As PIACENetClassModule, ByVal arACEPoints As ArrayList)
        Dim ptACE As PIACEPoint
        Dim iEn As IEnumerator
        Dim s As String = ""

        iEn = arACEPoints.GetEnumerator
        Do While iEn.MoveNext
            ptACE = iEn.Current
            If s.Length = 0 Then
                s = "Attention. Calculation faild for next data. Tags="
                s += ptACE.Tag
            Else
                s += "," & ptACE.Tag
            End If
            ptACE.SendDataToPI = False
        Loop
        PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlWarnings, s, aceClass.Name)
    End Sub

    Public Shared ReadOnly Property mCalcNew() As ICalcComponentLib.ICalculator
        Get
            If _mCalcNew Is Nothing Then
                _mCalcNew = New ICalcComponentLib.Calculator

            End If
            Return _mCalcNew
        End Get
    End Property

    Public Shared Sub SendValueToProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    ByVal value As String)
        Dim pp As PISDK.PIProperty

        Try
            pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
        Catch ex As Exception
            Try
                pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
            Catch ex1 As Exception
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Ķå ńģīć ēąćšóēčņü ńāīéńņāī. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)

            End Try

        End Try

        Try

            pp.Value = value.ToString
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Ēąļčńąķī ńāīéńņāī. Name=" & nameProperty & ". Value=" & value, aceClass.Name)
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Value ńāīéńņāą ķå ēąļčńąķī. Name=" & nameProperty _
            , aceClass.Name)

        End Try




    End Sub
    Public Shared Sub SendValueToProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    ByVal value As Double)
        Dim pp As PISDK.PIProperty

        Try
            pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
        Catch ex As Exception
            Try
                pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
            Catch ex1 As Exception
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Ķå ńģīć ēąćšóēčņü ńāīéńņāī. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)

            End Try

        End Try

        Try

            pp.Value = value
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Ēąļčńąķī ńāīéńņāī. Name=" & nameProperty & ". Value=" & value, aceClass.Name)
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Value ńāīéńņāą ķå ēąļčńąķī. Name=" & nameProperty _
            , aceClass.Name)

        End Try




    End Sub
    Public Shared Sub SendValueToAlias(ByVal pm As PISDK.PIModule, ByVal nameAlias As String, ByVal aceClass As PIACENetClassModule, _
ByVal value As Object, ByVal timest As Double)
        Dim pp As PISDK.PIAlias
        Dim pipt As PISDK.PIPoint

        Try
            pp = pm.PIAliases(nameAlias)
            pipt = pp.DataSource
        Catch ex As Exception
            Try
                pp = pm.PIAliases(nameAlias)
                pipt = pp.DataSource
            Catch ex1 As Exception
                PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Ķå ńģīć ēąćšóēčņü ąėčąń. Name=" & nameAlias & " >> " & ex.Message, aceClass.Name)

            End Try

        End Try

        Try

            pipt.Data.UpdateValue(value, timest)
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Ēąļčńąķī Value ā ąėčąń. Name=" & nameAlias & ". Value=" & value, aceClass.Name)
        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Value ķå ēąļčńąķī ā ąėčąń. Name=" & nameAlias _
            , aceClass.Name)

        End Try

    End Sub
    '===============Calculate Volume by API MPMS 12.1.1.9.1.3==================
    Public Shared Function CTSh_API_12_1_1Izolated(ByVal TSh As Double, ByVal Tb As Double, ByVal a As Double) As Double
        Dim dT As Double
        dT = TSh - Tb
        CTSh_API_12_1_1Izolated = 1 + 2 * a * dT + a * a * dT * dT
    End Function
    Public Shared Function CTSh_API_12_1_1NonIzolated(ByVal Tl As Double, ByVal Ta As Double, ByVal Tb As Double, ByVal a As Double) As Double
        Dim dT, TSh As Double
        TSh = (7 * Tl + Ta) / 8
        dT = TSh - Tb
        CTSh_API_12_1_1NonIzolated = 1 + 2 * a * dT + a * a * dT * dT
    End Function
End Class
