USE [PI_Temp]
GO
/****** Object:  StoredProcedure [dbo].[AF_GetReportData_Inventories]    Script Date: 25.02.2021 14:39:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Babych P.V
-- Create date: 2021-02-24
-- Last modify: 2021-03-02
-- Description:	Get Element PI AF
-- =============================================
ALTER PROCEDURE [dbo].[AF_GetReportData_Inventories]
	@DateTime nvarchar(24) = '2020-10-26 23:59:59',
	@ReportNumber nvarchar(5) = '237'
AS
BEGIN

	SET NOCOUNT ON;

DECLARE @OPENQUERY				nvarchar(4000),
		@TSQL					nvarchar(max),
		@LinkedServer			nvarchar(4000),
		@CurrentDate			date,
		@InputDateTime			datetime,
		@TimeStamp				datetime;

-- Підготовка періоду

	SET @InputDateTime		= convert (datetime, @DateTime, 120);


-- Проміжна таблица
IF ( OBJECT_ID('tempdb..#GetInventTemp') IS NOT NULL)
DROP TABLE #GetInventTemp
CREATE TABLE [dbo].[#GetInventTemp]
(
--[Element] nvarchar(100)  NULL,
--[Version] nvarchar(100)  NULL,
[col1] nvarchar(100)  NULL,
[col2] nvarchar(100)  NULL,
[col3] nvarchar(100)  NULL,
[col4] decimal(14,1) null,
[col5] decimal(14,1) null,
[col6] decimal(14,3) null,
[col7] decimal(14,3) null,
[col8] decimal(14,3) null,
[col9] decimal(14,3) null,
[col10] decimal(14,3) null,
[col11] decimal(14,3) null,
[col12] decimal(14,4) null,
[col13] decimal(14,3) null,
[col14] decimal(14,4) null,
[col15] decimal(14,3) null,
[col16] decimal(14,3) null,
[col17] decimal(14,3) null,
[col18] decimal(14,3) null,
[col19] decimal(14,3) null,
[col20] decimal(14,3) null,
)

IF (ISNUMERIC(@ReportNumber)=0) return

SET @LinkedServer = N'LINKEDAF_DB3333'
SET @OPENQUERY = N'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''

	SET @TSQL = N'SELECT tid.col1, tid.col2, tid.col3, tid.col4, tid.col5, tid.col6, tid.col7, tid.col8, tid.col9, tid.col10, tid.col11, tid.col12, tid.col13, tid.col14, tid.col15, tid.col16, tid.col17, tid.col18, tid.col19, tid.col20
					FROM
					(
						SELECT DATE(N'''''+ convert(nvarchar(24),@InputDateTime,120) +''''') [Time]
						UNION
						SELECT DATE(N'''''+ convert(nvarchar(24),@InputDateTime,120) +''''')
					) t,
						[ШВПГКН].[Asset].[ElementTemplate] et
						INNER JOIN [ШВПГКН].[Asset].[Element] e
							ON et.ID = e.ElementTemplateID
						INNER JOIN [ШВПГКН].[Asset].[ElementHierarchy] eh
							ON e.ID = eh.ElementID
						CROSS APPLY [ШВПГКН].DataT.[TransposeInterpolateDiscrete_Інвентаризація.Резервуар]
						(
							eh.ElementID,
							t.[Time]
						) tid
					WHERE eh.Path = N''''\Інвентарізація\N ' + @ReportNumber + '\''''
					order by eh.Name
					OPTION (FORCE ORDER, IGNORE ERRORS, EMBED ERRORS)'')';


INSERT INTO [dbo].[LogRunQuery]([NameProc],[Query])
     VALUES
           ('AF_GetReportData_Inventories',@TSQL)

--select  @TSQL
	SET @TSQL = @OPENQUERY+@TSQL

	INSERT INTO #GetInventTemp
	exec sp_executesql @TSQL

	--IF (@ReportNumber = '236')
	--	BEGIN
	--		SELECT * FROM  #GetInventTemp
	--		UNION ALL
	--		SELECT
	--			[NOM_NAME] as[col1],
	--			NULL as[col2], --???
	--			NULL as[col3],
	--			NULL as[col4],
	--			NULL as[col5],
	--			NULL as[col6] ,
	--			NULL as[col7] ,
	--			NULL as[col8] ,
	--			NULL as[col9] ,
	--			NULL as[col10] ,
	--			NULL as[col11] ,
	--			NULL as[col12],
	--			NULL as[col13] ,
	--			NULL as[col14],
	--			NULL as[col15] ,
	--			NULL as[col16] ,
	--			NULL as[col17] ,
	--			NULL as[col18] ,
	--			[KOL] as[col19] ,
	--			[KOL] as[col20]
	--		FROM [idrms].[dbo].[1COstatki4]
	--		WHERE NOM_NAME = 'Мазут М-100'
	--	END
	--ELSE
	--	BEGIN
	--		select * from  #GetInventTemp
	--	END

	select * from  #GetInventTemp

	DROP TABLE #GetInventTemp

END



