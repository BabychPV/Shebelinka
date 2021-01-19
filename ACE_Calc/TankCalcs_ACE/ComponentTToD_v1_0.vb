Imports OSIsoft.PI.ACE

Public Class ComponentTToD_v1_0

    Inherits PIACENetClassModule
    Private pmRoot As PISDK.PIModule
    Private clAliases As New Hashtable
    Private clCalcFailed As ArrayList
    Private clComp As New ICalcComponentLib.StructCollection

    Private Temperature As PIACEPoint
    Private Density As PIACEPoint
    Private Component As PIACEPoint

    '
    '      Tag Name/VB Variable Name Correspondence Table
    ' Tag Name                                VB Variable Name
    ' ------------------------------------------------------------



	' Густина робоча                          PI______________
	' Ключовий компонент                      PI__________________
	' Температура                             PI___________

    Public Overrides Sub ACECalculations()
        Dim dblTemp, dblDensity, dblD As Double, s As String

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
        Density = GetPIACEPoint("PI______________")
        Component = GetPIACEPoint("PI__________________")
        Temperature = GetPIACEPoint("PI___________")
    End Sub

    ' User-written module dependent initialization code
    '
    Protected Overrides Sub ModuleDependentInitialization()
        Dim pa As PISDK.PIAlias
        Dim paNewName As String, ptlist As PISDK.PointList
        pmRoot = PIACEBIFunctions.GetPIModuleFromPath(Context)
        clAliases = New Hashtable
        For Each pa In pmRoot.PIAliases
            Try
                Select Case pa.Name
                    Case "Метан", "Этан та Этилен", "Пропан", "Пропен", "Изобутан", "н-Бутан", "Бутен-1", "Изобутен", "транс-Бутен-2", "цис-Бутен-2", "Изопентан", "н-Пентан", "1,3-Бутадиен"
                        Select Case pa.Name
                            Case "1,3-Бутадиен"
                                paNewName = "Бутадиен-1,3"
                            Case "Метан"
                                paNewName = "этан"
                            Case "Этан та Этилен"
                                paNewName = "этан"
                            Case "Пропен"
                                paNewName = "пропен"
                            Case "Пропан"
                                paNewName = "пропан"
                            Case "Бутен-1"
                                paNewName = "бутен-1"
                            Case "цис-Бутен-2"
                                paNewName = "цис-бутен-2"
                            Case "Изобутан"
                                paNewName = "изобутан"
                            Case "Изобутен"
                                paNewName = "изобутен"
                            Case "Изопентан"
                                paNewName = "изопентан"
                            Case "н-Бутан"
                                paNewName = "н-бутан"
                            Case "н-Пентан"
                                paNewName = "н-пентан"
                            Case "транс-Бутен-2"
                                paNewName = "транс-бутен-2"
                            Case Else
                                paNewName = ""
                        End Select
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
        time = pmRoot.PIAliases("Ключовий компонент").DataSource.Data.ArcValue(ExeTime + 1, PISDK.RetrievalTypeConstants.rtBefore).TimeStamp.UTCSeconds

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
