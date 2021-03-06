Imports OSIsoft.PI.ACE

Public Class ComponentTToD
    Inherits PIACENetClassModule
    Private Temperature As PIACEPoint
    Private Density As PIACEPoint
    Private Component As PIACEPoint
    '
    '      Tag Name/VB Variable Name Correspondence Table
    ' Tag Name                                VB Variable Name
    ' ------------------------------------------------------------
    '

    Private pmRoot As PISDK.PIModule
    Private clAliases As New Hashtable
    Private clCalcFailed As ArrayList

	' Component                               Component
	' Density                                 Density
	' Temperature                             Temperature

    Public Overrides Sub ACECalculations()
        Dim dblTemp, dblD As Double, s As String

        Try

            If clsFunctions.LoadValueFromACEPoint(Temperature, Me, dblTemp) = False Then
                CalcFailed()
                Exit Sub
            End If
            Dim clComp As New ICalcComponentLib.StructCollection


            GetComponentsColl(clComp)
            If clComp.Count = 0 Then
                CalcFailed()
                Exit Sub
            End If


            dblD = clsFunctions.mCalcNew.StartFunctionVB("DensityFromCompStructAndTemper", clComp, dblTemp)

            If dblD < 0 Or Double.IsInfinity(dblD) Then

                Try
                    s = clsFunctions.mCalcNew.StartStringFunction(dblD)
                Catch ex1 As Exception
                End Try
                PIACEBIFunctions.LogPIACEMessage(OSIsoft.PI.ACE.MessageLevel.mlErrors, "ERROR. Density calculation faild! >> " & s, MyBase.Name)
                CalcFailed()
                Exit Sub
            End If

            Density.Value = dblD * 1000
            clComp = Nothing

        Catch ex As Exception
            PIACEBIFunctions.LogPIACEMessage(OSIsoft.PI.ACE.MessageLevel.mlErrors, "ERROR >> " & ex.Message, MyBase.Name)
            CalcFailed()
        End Try
    End Sub

    Protected Overrides Sub InitializePIACEPoints()
		Component = GetPIACEPoint("Component")
		Density = GetPIACEPoint("Density")
		Temperature = GetPIACEPoint("Temperature")
    End Sub

    '
    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        Dim pa As PISDK.PIAlias
        Dim paNewName As String, ptlist As PISDK.PointList
        pmRoot = PIACEBIFunctions.GetPIModuleFromPath(Context)
        clAliases = New Hashtable
        For Each pa In pmRoot.PIAliases
            If Not pa.Name = "Component" And Not pa.Name = "Density" And Not pa.Name = "Temperature" Then
                paNewName = pa.Name
                Try
                    Select Case paNewName
                        Case "1,3-butadienas"
                            paNewName = "Бутадиен-1,3"
                        Case "C2H4"
                            paNewName = "Этан"
                        Case "C2H6"
                            paNewName = "Этан"
                        Case "~C2 kiekis (suma)"
                            paNewName = "Этан"
                        Case "C3H6"
                            paNewName = "Пропен"
                        Case "C3H8"
                            paNewName = "Пропан"
                        Case "~C3 kiekis (suma)"
                            paNewName = "Пропен"
                        Case "~C4H10 (suma)"
                            paNewName = "Бутен-1"
                        Case "~C4H8 (suma)"
                            paNewName = "Бутен-1"
                        Case "C4H8-1"
                            paNewName = "Бутен-1"
                        Case "~C4 kiekis (suma)"
                            paNewName = "Бутен-1"
                        Case "C5H10"
                            paNewName = "Циклопентан"
                        Case "~C5 kiekis (suma)"
                            paNewName = "Пентен-1"
                        Case "~C6 kiekis"
                            paNewName = "н-Гексан"
                        Case "~C7 kiekis"
                            paNewName = "н-Гептан"
                        Case "~C8 kiekis"
                            paNewName = "н-Октан"
                        Case "CH4"
                            paNewName = "Этан"
                        Case "cisC4H8-2"
                            paNewName = "цис-Бутен-2"
                        Case "iC4H10"
                            paNewName = "Изобутан"
                        Case "izoC4H8"
                            paNewName = "Изобутен"
                        Case "Izopentanas(iC5H12)"
                            paNewName = "Изопентан"
                        Case "nC4H10"
                            paNewName = "н-Бутан"
                        Case "nC5H12"
                            paNewName = "н-Пентан"
                        Case "transC4H8-2"
                            paNewName = "транс-Бутен-2"
                        Case "~C6 kiekis"
                            paNewName = "транс-Бутен-2"
                        Case "~C7 kiekis"
                            paNewName = "транс-Бутен-2"
                        Case "~C8 kiekis"
                            paNewName = "транс-Бутен-2"
                        
                        Case Else
                            paNewName = ""
                    End Select
                Catch ex As Exception
                End Try
                Try
                    If Not paNewName = "" Then clAliases.Add(paNewName, New PISDK.PointList)
                Catch ex As Exception
                End Try
                If Not paNewName = "" Then
                    ptlist = clAliases(paNewName)
                    ptlist.Add(pa.DataSource)
                End If
            End If
        Next
    End Sub

    '
    ' User-written module dependent termination code
    '
    Protected Overrides Sub ModuleDependentTermination()
    End Sub
    Private Sub GetComponentsColl(ByRef clComp As ICalcComponentLib.StructCollection)
        Dim time, dbl As Double
        Dim iDEn As IDictionaryEnumerator
        Dim ptlist As PISDK.PointList, pt As PISDK.PIPoint

        'time = pmRoot.Server.PIPoints(Component.Tag).Data.ArcValue(ExeTime + 1, PISDK.RetrievalTypeConstants.rtBefore).TimeStamp.UTCSeconds
        time = pmRoot.PIAliases("Component").DataSource.Data.ArcValue(ExeTime + 1, PISDK.RetrievalTypeConstants.rtBefore).TimeStamp.UTCSeconds

        iDEn = clAliases.GetEnumerator
        Do While iDEn.MoveNext
            dbl = 0
            ptlist = iDEn.Value
            For Each pt In ptlist
                Try
                    dbl += pt.Data.ArcValue(time, PISDK.RetrievalTypeConstants.rtCompressed).Value
                Catch ex As Exception
                End Try
            Next
            clComp.Add(iDEn.Key, dbl)
        Loop
    End Sub
    Private Sub CalcFailed()
        clCalcFailed = New ArrayList
        clCalcFailed.Add(Density)
        clsFunctions.SendToPI_CalcIsFailed(Me, clCalcFailed)
    End Sub
End Class
