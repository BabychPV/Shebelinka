'Imports OSIsoft.PI.ACE

Public Class clsFunctions

    Private Shared _mCalcNew As ICalcComponentLib.ICalculator
    '=================Calculate Mass============================='
    Public Shared Sub CalcMass(ByVal dblDensity As Double, ByVal dblVolume As Double, ByRef dblMass As Double)
        dblMass = dblDensity * dblVolume
    End Sub
    
    '=================================Load values from properties======================
    '  Public Shared Function LoadValueFromProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    '  ByRef arValue As Object) As Boolean
    '      Dim pp As PISDK.PIProperty

    '      Try
    '          pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
    '      Catch ex As Exception
    '          Try
    '              pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
    '          Catch ex1 As Exception
    '              PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Can't load property. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)
    '          End Try
    '          Return False
    '      End Try

    '      If pp.Value.GetType Is GetType(System.Double()) Then
    '          arValue = pp.Value
    '      ElseIf IsNumeric(pp.Value) Then
    '          arValue = pp.Value
    '      Else
    '          PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Property value have wrong type. Name=" & nameProperty & _
    '          ". Type=" & pp.Value.GetType.ToString, aceClass.Name)
    '          Return False
    '      End If

    '      PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Property have been loaded. Name=" & nameProperty, aceClass.Name)
    '      Return True
    '  End Function
    '  Public Shared Function LoadValueFromProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    '  ByRef value As Double) As Boolean
    '      Dim pp As PISDK.PIProperty

    '      Try
    '          pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)

    '      Catch ex As Exception
    '          Try
    '              pp = pm.PIProperties(nameProperty)

    '          Catch ex2 As Exception


    '              Try
    '                  pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
    '              Catch ex1 As Exception
    '                  PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Can't load property. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)
    '                  Return False
    '              End Try
    '          End Try
    '      End Try

    '      If IsNumeric(pp.Value) Then
    '          value = pp.Value
    '      ElseIf pp.Value.GetType Is GetType(System.Double()) Then
    '          value = pp.Value
    '      Else
    '          PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Property value have wrong type. Name=" & nameProperty & _
    '          ". Type=" & pp.Value.GetType.ToString, aceClass.Name)
    '          Return False
    '      End If

    '      PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Property have been loaded. Name=" & nameProperty & ". Value=" & value, aceClass.Name)
    '      Return True

    '  End Function
    '  Public Shared Function LoadValueFromProperty(ByVal pm As PISDK.PIModule, ByVal nameProperty As String, ByVal aceClass As PIACENetClassModule, _
    'ByRef value As String) As Boolean
    '      Dim pp As PISDK.PIProperty

    '      Try
    '          pp = pm.PIProperties("I-OMS").PIProperties(nameProperty)
    '      Catch ex As Exception
    '          Try
    '              pp = pm.PIProperties("I-OMS").PIProperties("Additional Properties").PIProperties(nameProperty)
    '          Catch ex1 As Exception
    '              PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Can't load property. Name=" & nameProperty & " >> " & ex.Message, aceClass.Name)
    '              Return False
    '          End Try

    '      End Try

    '      If pp.Value.GetType Is GetType(String) Then
    '          value = pp.Value
    '      Else
    '          PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlErrors, "ERROR. Property value have wrong type. Name=" & nameProperty & _
    '          ". Type=" & pp.Value.GetType.ToString, aceClass.Name)
    '          Return False
    '      End If

    '      PIACEBIFunctions.LogPIACEMessage(MessageLevel.mlCalculationExecuted, "Property have been loaded. Name=" & nameProperty & ". Value=" & value, aceClass.Name)
    '      Return True

    '  End Function

   
    

    Public Shared ReadOnly Property mCalcNew() As ICalcComponentLib.ICalculator
        Get
            If _mCalcNew Is Nothing Then
                _mCalcNew = New ICalcComponentLib.Calculator

            End If
            Return _mCalcNew
        End Get
    End Property

   
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
