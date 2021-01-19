Imports Indusoft.OMSClient.Common
'Imports OSIsoft.PI.ACE

Public Class LD20TToVM_UOB : Implements ICalculator


    Public Sub Calculate(ByVal currentTime As Date, ByRef mTank As OMSClient.Common.clsMyNewTank, ByVal userPref As System.Collections.Hashtable) Implements OMSClient.Common.ICalculator.Calculate
        Dim mAliasLevel, mAliasVolumeTot, mAliasDensity, mAliasMassTot, mAliasTemperature As clsAlias
        Dim mAliasAmbTemperature, mAliasMassWork As clsAlias
        Dim mAliasMassDead, mAliasDensity20, mAliasTankState As clsAlias
        ' Dim srv As Server
        'Dim _pisdk As New PISDK.PISDK
        'Dim pmRoot As PIModule

        Dim dblLevel, dblVolume, dblVolumeDead, dblTemp, dblAmbTemp, dblD20, dblD, dblMTotal, dblMDead, dblMMax, dblMaxLevel As Double
        Dim dbl_p60, dbl_T, dbl_T20F, dbl_CTPL60, dbl_CTPL, dbl_CTSh, dblLTEC As Double
        'Dim dbl_p60, dbl_T, dbl_T15F, dbl_CTPL60, dbl_CTPL, dbl_PSI, dbl_CTSh, dblLTEC As Double
        Dim s_ProductGroup As String


        mAliasLevel = mTank.aliases(My.Resources.Level)
        mAliasVolumeTot = mTank.aliases(My.Resources.VolumeTotal)
        'mAliasVolumeWork = mTank.aliases(My.Resources.VolumeWork)
        mAliasDensity = mTank.aliases(My.Resources.Density)
        mAliasDensity20 = mTank.aliases(My.Resources.Density20)
        mAliasMassTot = mTank.aliases(My.Resources.MassTotal)
        mAliasMassWork = mTank.aliases(My.Resources.MassWork)
        'mAliasMassMax = mTank.aliases(My.Resources.MassMax)
        mAliasMassDead = mTank.aliases(My.Resources.MassDead)
        mAliasAmbTemperature = mTank.aliases(My.Resources.AmbTemperature)
        mAliasTemperature = mTank.aliases(My.Resources.Temperature)
        mAliasTankState = mTank.aliases(My.Resources.TankState)
        'Try
        'mAliasLevel = mTank.aliases(userPref(My.Resources.Path_Level).ToString)
        '    mAliasVolumeTot = mTank.aliases(userPref(My.Resources.Path_VolumeTotal).ToString)
        '    ' mAliasVolumeWork = mTank.aliases(userPref(My.Resources.Path_VolumeWork).ToString)
        '    mAliasDensity = mTank.aliases(userPref(My.Resources.Path_Density).ToString)
        '    mAliasDensity20 = mTank.aliases(userPref(My.Resources.Path_Density20).ToString)
        '    mAliasMassTot = mTank.aliases(userPref(My.Resources.Path_MassTotal).ToString)
        '    mAliasMassWork = mTank.aliases(userPref(My.Resources.Path_MassWork).ToString)
        '    'mAliasMassMax = mTank.aliases(userPref(My.Resources.Path_MassMax).ToString)
        '    mAliasMassDead = mTank.aliases(userPref(My.Resources.Path_MassDead).ToString)
        '    mAliasAmbTemperature = mTank.aliases(userPref(My.Resources.Path_AmbTemp).ToString)
        '    mAliasTemperature = mTank.aliases(userPref(My.Resources.Path_Temp).ToString)
        'Catch ex As Exception

        'End Try


        If mAliasTankState Is Nothing Then
            MsgBox("Can't find Alias TankState")
            Exit Sub
        End If

        '#Region "Get Tank props"
        'Try
        '  dblVolumeMax = Convert.ToDouble(mTank.userParameters(My.Resources.VolumeMax.ToLower))
        '   dblVolumeMax = dblVolumeMax / 1000
        ' Catch ex As Exception
        '     dblVolumeMax = 0
        ' End Try


        Try
            dblVolumeDead = Convert.ToDouble(mTank.userParameters(My.Resources.VolumeDead.ToLower))
            dblVolumeDead = dblVolumeDead / 1000
        Catch ex As Exception
            dblVolumeDead = 0
        End Try


        Try
            dblLTEC = Convert.ToDouble(mTank.userParameters("LTECoef"))
            If dblLTEC = 0.0 Then
                dblLTEC = 0.0000112
            End If
        Catch ex As Exception
            dblLTEC = 0.0000112
        End Try

        Try
            s_ProductGroup = Convert.ToString(mTank.userParameters("ProductGroup"))
            If s_ProductGroup = "" Then s_ProductGroup = "Refined Products"
        Catch ex As Exception
            s_ProductGroup = "Refined Products"
        End Try
        '#End Region

        '#Region "Check Aliases"
        If mAliasLevel Is Nothing Then
            MsgBox("Can't find Alias Level")
            Exit Sub
        End If
        If mAliasVolumeTot Is Nothing Then
            MsgBox("Can't find Alias Volume Tot")
            Exit Sub
        End If

        If mAliasDensity Is Nothing Then
            MsgBox("Can't find Alias Density")
            Exit Sub
        End If
        If mAliasMassTot Is Nothing Then
            MsgBox("Can't find Alias Mass Tot")
            Exit Sub
        End If
        '  If mAliasVolumeWork Is Nothing Then
        'MsgBox("Can't find Alias Volume Work")
        '   Exit Sub
        '  End If
        If mAliasMassDead Is Nothing Then
            MsgBox("Can't find Alias MassDead")
            Exit Sub
        End If
        '  If mAliasMassMax Is Nothing Then
        'MsgBox("Can't find Alias MassMax")
        '  Exit Sub
        '  End If
        If mAliasDensity Is Nothing Then
            MsgBox("Can't find Alias Density")
            Exit Sub
        End If

        If mAliasAmbTemperature Is Nothing Then
            MsgBox("Can't find Alias AmbTemp")
            Exit Sub
        End If
        If mAliasDensity20 Is Nothing Then
            MsgBox("Can't find Alias Density20")
            Exit Sub
        End If
        If mAliasTemperature Is Nothing Then
            MsgBox("Can't find Alias Temperature")
            Exit Sub
        End If
        '#End Region

        If mAliasTankState.valueForCalc = "ремонт" Then

            mAliasMassTot.calcValue = 0
            'mAliasMassMax.calcValue = 0
            mAliasMassDead.calcValue = 0
            mAliasMassWork.calcValue = 0

            mAliasVolumeTot.calcValue = 0
            'mAliasVolumeWork.calcValue = 0

            mAliasDensity.calcValue = 0

            Exit Sub
        End If


        If IsNumeric(mAliasLevel.valueForCalc) And IsNumeric(mAliasAmbTemperature.valueForCalc) _
            And IsNumeric(mAliasTemperature.valueForCalc) And IsNumeric(mAliasDensity20.valueForCalc) Then

            dblLevel = mAliasLevel.valueForCalc
            dblD20 = mAliasDensity20.valueForCalc
            dblAmbTemp = mAliasAmbTemperature.valueForCalc
            dblTemp = mAliasTemperature.valueForCalc


            dblMaxLevel = mTank.userParameters("maxlevel") ' 2021_01_13 babych
            dblLevel = dblMaxLevel - dblLevel ' 2021_01_13 babych

            'Get Volume from Calibration table
            ' If mTank.GetVolume(dblLevel * 100, dblVolume) = False Then
            'mAliasVolumeTot.calcValue = Nothing
            '   mAliasMassTot.calcValue = Nothing
            '  Exit Sub
            ' End If
            If mTank.GetVolume(dblLevel, dblVolume) = False Then
                mAliasVolumeTot.calcValue = Nothing
                mAliasMassTot.calcValue = Nothing
                Exit Sub
            End If

            dblVolume = dblVolume / 1000

            'Correction for the Effect of Temperature on the Steel Shell of the Tank (CTSh)
            dbl_CTSh = clsFunctions.CTSh_API_12_1_1NonIzolated(dblTemp, dblAmbTemp, 15, dblLTEC)
            dblVolume = dblVolume * dbl_CTSh

            Dim dispDig As Double

            dispDig = mAliasVolumeTot.tag.displayDigits

            'Calculate density 

            dbl_T = clsFunctions.mCalcNew.StartFunction("CToF", dblTemp)
            dbl_T20F = clsFunctions.mCalcNew.StartFunction("CToF", 20)

            dbl_CTPL60 = clsFunctions.mCalcNew.StartFunction("CTPL11ToBaseProduct", dblD20, dbl_T20F, 0, s_ProductGroup)

            dbl_p60 = dblD20 / dbl_CTPL60
            dbl_CTPL = clsFunctions.mCalcNew.StartFunction("CTPL11Product", dbl_p60, dbl_T, 0, s_ProductGroup)
            dbl_CTPL = dbl_CTPL60 / dbl_CTPL
            dblD = dblD20 / dbl_CTPL



            'Get Mass
            dispDig = mAliasMassTot.tag.displayDigits
            clsFunctions.CalcMass(dblD / 1000, dblVolume, dblMTotal)
            'clsFunctions.CalcMass(dblD / 1000, dblVolumeMax, dblMMax)
            clsFunctions.CalcMass(dblD / 1000, dblVolumeDead, dblMDead)


            If (dblMTotal - dblMDead) < 0 Then
                mAliasMassWork.calcValue = 0
            Else
                If dispDig > 0 Then
                    mAliasMassWork.calcValue = System.Math.Round(dblMTotal - dblMDead, CType(dispDig, Integer)) '* 1000 Butko 2017/10/03 delete change babych 2021_01_13
                Else
                    mAliasMassWork.calcValue = (dblMTotal - dblMDead) '* 1000 Butko 2017/10/03 delete change babych 2021_01_13
                End If

            End If

            '   If (dblVolume - dblVolumeDead) < 0 Then
            'mAliasVolumeWork.calcValue = 0
            ' Else
            '      If dispDig > 0 Then
            '   mAliasVolumeWork.calcValue = System.Math.Round(dblVolume - dblVolumeDead, CType(dispDig, Integer))
            'Else
            '     mAliasVolumeWork.calcValue = dblVolume - dblVolumeDead
            '   End If
            ' End If

            If (dispDig >= 0) Then
                dblMTotal = System.Math.Round(dblMTotal, CType(dispDig, Integer))
            End If
            mAliasMassTot.calcValue = dblMTotal

            If (dispDig >= 0) Then
                dblMMax = System.Math.Round(dblMMax, CType(dispDig, Integer))
            End If
            ' mAliasMassMax.calcValue = dblMMax


            If (dispDig >= 0) Then
                dblMDead = System.Math.Round(dblMDead, CType(dispDig, Integer))
            End If
            mAliasMassDead.calcValue = dblMDead


            dispDig = mAliasDensity.tag.displayDigits
            If (dispDig >= 0) Then
                dblD = System.Math.Round(dblD, CType(dispDig, Integer))
            End If
            mAliasDensity.calcValue = dblD

            dblVolume = dblVolume * 1000 ' *1000 - Butko 2017/10/03
            dblVolumeDead = dblVolumeDead * 1000
            ' dblVolumeMax = dblVolumeMax * 1000

            If (dispDig >= 0) Then
                dblVolume = System.Math.Round(dblVolume, CType(dispDig, Integer))
                dblVolumeDead = System.Math.Round(dblVolumeDead, CType(dispDig, Integer))
                'dblVolumeMax = System.Math.Round(dblVolumeMax, CType(dispDig, Integer))
            End If
            mAliasVolumeTot.calcValue = dblVolume

        End If


    End Sub

    Public ReadOnly Property UID() As String Implements OMSClient.Common.ICalculator.UID
        Get
            Return My.Resources.const_UID
        End Get
    End Property
End Class
