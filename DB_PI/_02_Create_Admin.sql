USE [PI_Temp]
GO
/****** Object:  StoredProcedure [dbo].[AF_GetReportDataofTanks]    Script Date: 19.11.2020 16:32:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Babych P.V
-- Create date: 2020-10-16
-- Last modify: 2020-11-19
-- Description:	Get Element PI AF
-- =============================================
CREATE PROCEDURE [dbo].[AF_GetReportDataofTanks]
	@Date nvarchar(24) = '2020-10-26 23:59:59'
AS
BEGIN

	SET NOCOUNT ON;

DECLARE @OPENQUERY nvarchar(4000),
		@TSQL nvarchar(max),
		@LinkedServer nvarchar(4000),
		@CurrentMidnight datetime

	SET @CurrentMidnight	= convert(datetime, @Date, 120);

	IF ( OBJECT_ID('tempdb..#TempToPivot') IS NOT NULL)
	DROP TABLE #TempToPivot

	CREATE TABLE #TempToPivot(

	  ElementName nvarchar(1000),
	  TankNumber int,
	  AttributeName  nvarchar(1000),
	  Value nvarchar(1000)

	)

	SET @LinkedServer = N'LINKEDAF'
	SET @OPENQUERY = N'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''

	SET @TSQL = N'SELECT  el.name ElementName ,REPLACE(el.name,''''Резервуар №'''', '''''''')  TankNumber, ea.name AttributeName, i.ValueStr
	FROM (	SELECT ID,name
			FROM [ШВПГКН].[Asset].[Element]
			WHERE Name like (''''Резервуар №%'''')) el
	INNER JOIN [ШВПГКН].[Asset].[ElementAttribute] ea ON ea.ElementID = el.ID
	CROSS APPLY ШВПГКН.Data.InterpolateRange (ea.ID, N'''''+ convert(nvarchar(24),@CurrentMidnight,120) +''''', N'''''+ convert(nvarchar(24),@CurrentMidnight,120)+''''', N''''1d'''') i WHERE  ea.name in (''''AI_Info01'''',''''AI_Info02'''',''''AI_Info03'''',''''AI_Info04'''',''''Material'''')
	OPTION (FORCE ORDER,EMBED ERRORS)'')'

	SET @TSQL = @OPENQUERY+@TSQL

	INSERT INTO #TempToPivot
	exec sp_executesql @TSQL

		SELECT convert (nvarchar(30),ElementName) ElementName, convert(int,TankNumber) TankNumber, convert (nvarchar(50),[Material]) Material, convert (nvarchar(8),[AI_Info02]) as [Density] , convert (nvarchar(8),[AI_Info01]) as [HeightTank] , convert (nvarchar(8),[AI_Info04]) as [LevelWater], convert (nvarchar(8),[AI_Info03]) as [Temperature]
		FROM
		(select ElementName,TankNumber,AttributeName,Value
		FROM #TempToPivot) p
		PIVOT
		(MAX (Value)
		FOR AttributeName IN ( [Material], [AI_Info01], [AI_Info02] , [AI_Info03] , [AI_Info04]  )
		) AS pvt
		order by pvt.TankNumber


END