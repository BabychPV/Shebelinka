USE [master]
GO

/****** Object:  LinkedServer [LINKEDAF_DB3333]    Script Date: 24.11.2020 13:09:48 ******/
EXEC master.dbo.sp_dropserver @server=N'LINKEDAF_DB3333', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [LINKEDAF_DB3333]    Script Date: 24.11.2020 13:09:48 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LINKEDAF_DB3333', @srvproduct=N'UPG01SV-PI1V', @provider=N'PIOLEDBENT', @datasrc=N'UPG01SV-PI1V', @provstr=N'Integrated Security=SSPI;
', @catalog=N'Configuration'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LINKEDAF_DB3333',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'connect timeout', @optvalue=N'30'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'query timeout', @optvalue=N'300'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF_DB3333', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO




USE [PI_Temp]
GO
/****** Object:  StoredProcedure [dbo].[AF_GetReportData_Balance_oms]    Script Date: 09.12.2020 0:04:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

USE [PI_Temp]
GO
/****** Object:  StoredProcedure [dbo].[AF_GetReportData_Balance_oms]    Script Date: 10.02.2021 15:57:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Babych P.V
-- Create date: 2020-11-13
-- Last modify: 2021-02-10
-- Description:	Get Element PI AF
-- =============================================
ALTER PROCEDURE [dbo].[AF_GetReportData_Balance_oms]
	@Date nvarchar(24) = '2020-10-26 23:59:59',
	@Unit nvarchar(30) = 'УГФ-1'
AS
BEGIN

	SET NOCOUNT ON;

DECLARE @OPENQUERY				nvarchar(4000),
		@TSQL					nvarchar(max),
		@LinkedServer			nvarchar(4000),
		@CurrentDate			date,
		@PrevDate				datetime,
		@InputDate				date,
		@InputDateTime			datetime,
		@TimeStamp				datetime,
		@CurrentDateTime		datetime,
		@CurrentMorning			datetime,
		@NextMorning 			datetime,
		@CurrentRange_07		datetime,
		@CurrentRange_19		datetime,
		@CurrentNextDateRange_19	datetime,
		@NextRange_07			datetime,
		@IDDate					bigint,
		@range24				nvarchar(5) = '24h',
		@range12				nvarchar(5) = '12h',
		@part					nvarchar(10),
		@hour					int,
		@minute					int;

-- Підготовка періоду
	SET @TimeStamp			= GetDate();
	SET	@CurrentDate		= convert(date,@TimeStamp,120);
	SET @CurrentDateTime	= convert (datetime, @CurrentDate, 120);

	SET @hour				= datepart(hh, @TimeStamp);
	SET @minute				= datepart(mi, @TimeStamp);

	SET	@InputDate			= convert(date,@Date,120);
	SET @InputDateTime		= convert (datetime, @InputDate, 120);

	if ( @CurrentDate <= @InputDate)
		BEGIN
			if (@hour < 7) -- В проміжок з 00:00 годин до 07:00
				begin
					SET @PrevDate					= dateadd (dd, -1, @InputDateTime);
					SET @CurrentMorning				= dateadd (hh, 7, @PrevDate);
					SET @NextMorning 				= dateadd (hh, @hour, @InputDateTime);
					SET @CurrentRange_07			= @CurrentMorning;
					SET @CurrentRange_19			= dateadd (ss,0,dateadd (mi,0,dateadd (hh,19,@PrevDate)));
					SET @CurrentNextDateRange_19	= @CurrentRange_19;
					SET @NextRange_07				= @NextMorning;
					if (@hour=0)
						begin
							SET @range24 = convert (nvarchar(3),24-7) + N'h';
						end
					else
						begin
							SET @range24 = convert (nvarchar(3),24-@hour) + N'h';
						end
					SET @range12					= @range24;
				end

			else
				begin  -- В проміжок з 07:00 годин до * плинної

					SET @CurrentMorning				= dateadd (hh, 7, @CurrentDateTime);
					SET @NextMorning 				= dateadd (ss,0,dateadd (mi,0,dateadd (hh,@hour,@CurrentDateTime)));
					SET @CurrentRange_07			= @CurrentMorning;
					SET @CurrentRange_19			= @NextMorning ;
					SET @CurrentNextDateRange_19	= @CurrentMorning;
					SET @NextRange_07				= @NextMorning ;
					if (@hour=7)
						begin
							SET @range24 = convert (nvarchar(5),@minute) + N'm';
						end
					else
						begin
							SET @range24 = convert (nvarchar(3),@hour-7) + N'h';
						end
					SET @range12					= @range24;
				end

		END
	else
		BEGIN-- В проміжок з 07:00 годин до 07:00 архівний звіт
			SET @CurrentMorning				= dateadd (hh, 7, @InputDateTime);
			SET @NextMorning 				= dateadd (hh, 7, dateadd (day,+1,@InputDateTime));
			SET @CurrentRange_07			= @CurrentMorning;
			SET @CurrentRange_19			= dateadd (ss,0,dateadd (mi,0,dateadd (hh,19,@InputDateTime)));
			SET @CurrentNextDateRange_19	= @CurrentRange_19;
			SET @NextRange_07				= @NextMorning;
		END

-- Проміжна таблица
IF ( OBJECT_ID('tempdb..#GetBalanceTemp') IS NOT NULL)
DROP TABLE #GetBalanceTemp
CREATE TABLE [dbo].[#GetBalanceTemp]
(
   Element nvarchar(50) NULL
  ,Attribute nvarchar(200)  NULL
  ,Path nvarchar(100)  NULL
  ,Level nvarchar(5)  NULL
  ,Pos nvarchar(20) NULL
  ,IsInput  nvarchar(20) NULL
  ,Total nvarchar(100) null
  ,Average  nvarchar(100) NULL
  ,Total6_18  nvarchar(100) NULL
  ,Total18_6  nvarchar(100) NULL
  ,[Percent]  nvarchar(100) NULL
)

-- Вихідна таблица
IF ( OBJECT_ID('tempdb..#GetBalance') IS NOT NULL)
DROP TABLE #GetBalance
CREATE TABLE [dbo].[#GetBalance]
(
   Element nvarchar(50) NULL
  ,Attribute nvarchar(200)  NULL
  ,Path nvarchar(100)  NULL
  ,Level nvarchar(100)  NULL
  ,Pos nvarchar(20) NULL
  ,IsInput  nvarchar(20) NULL
  ,Total decimal(10,3) null
  ,Average  decimal(10,3) NULL
  ,Total6_18  decimal(10,3) NULL
  ,Total18_6  decimal(10,3) NULL
  ,Total6_6  decimal(10,3) NULL
  ,[Percent]  decimal(10,3) NULL
)




SET @LinkedServer = N'LINKEDAF_DB3333'
SET @OPENQUERY = N'SELECT * FROM OPENQUERY('+ @LinkedServer + ','''

	SET @TSQL = N'SELECT el.Name Element, ea.Name Attribute, ea.Path path, ea.level, ea.Description Pos,cat.name IsInput, s.ValueDbl as Total, s1.ValueDbl as Average, s2.ValueDbl as Total6_18, s3.ValueDbl as Total18_6,
				pr.Percent
				FROM (SELECT ID,name FROM [ШВПГКН].[Asset].[Element] WHERE Name ='''''+@Unit+''''') el
				INNER JOIN ШВПГКН.Asset.ElementAttribute ea ON ea.ElementID = el.ID
				INNER JOIN ШВПГКН.Asset.ElementAttributeCategory eac ON eac.ElementAttributeID = ea.ID
				INNER JOIN [ШВПГКН].[Asset].[Category] cat ON (eac.CategoryID = cat.ID and cat.Name in (''''Input'''',''''Output''''))
				INNER JOIN (
					SELECT ea.name,s0.ValueStr Percent
					FROM ШВПГКН.Asset.ElementHierarchy eh
					INNER JOIN ШВПГКН.Asset.ElementAttribute ea ON ea.ElementID = eh.ElementID
					INNER JOIN ШВПГКН.Data.Snapshot s0 ON s0.ElementAttributeID = ea.ID
					WHERE eh.Name = '''''+@Unit+''''' and ea.Description =''''%'''') pr on  pr.name = ea.Name+'''', %''''
				CROSS APPLY ШВПГКН.Data.Summarize (ea.ID, N'''''+ convert(nvarchar(24),@CurrentMorning,120) +''''', N'''''+ convert(nvarchar(24),@NextMorning ,120) +''''', N'''''+ @range24 +''''', N''''Total'''' , N''''TimeWeighted'''', N''''MostRecentTime'''') s
				CROSS APPLY ШВПГКН.Data.Summarize (ea.ID, N'''''+ convert(nvarchar(24),@CurrentMorning,120) +''''', N'''''+ convert(nvarchar(24),@NextMorning ,120) +''''', N'''''+ @range24 +''''', N''''Average'''' , N''''TimeWeighted'''', N''''MostRecentTime'''')  s1
				CROSS APPLY ШВПГКН.Data.Summarize (ea.ID, N'''''+ convert(nvarchar(24),@CurrentRange_07,120) +''''', N'''''+ convert(nvarchar(24),@CurrentRange_19,120) +''''', N'''''+ @range12 +''''', N''''Total'''' , N''''TimeWeighted'''', N''''MostRecentTime'''')  s2
				CROSS APPLY ШВПГКН.Data.Summarize (ea.ID, N'''''+ convert(nvarchar(24),@CurrentNextDateRange_19,120) +''''', N'''''+ convert(nvarchar(24),@NextRange_07,120) +''''', N'''''+ @range12 +''''', N''''Total'''' , N''''TimeWeighted'''', N''''MostRecentTime'''')  s3
				where ea.ValueType = N''''Single''''
				OPTION (FORCE ORDER, EMBED ERRORS)'')';

INSERT INTO [dbo].[LogRunQuery]([Query])
     VALUES
           (@TSQL)

--select  @TSQL
	SET @TSQL = @OPENQUERY+@TSQL

	INSERT INTO #GetBalanceTemp
	exec sp_executesql @TSQL
--select * from  #GetBalanceTemp

	INSERT INTO #GetBalance (Element, Attribute, Path, Level, Pos, IsInput, Total, Average,Total6_18,Total18_6,Total6_6,[Percent])
	select  Element, Attribute, Path, Level, Pos, IsInput,
		case WHEN ISNUMERIC(Total) = 1 then Total else null end,
		case WHEN ISNUMERIC(Average) = 1 then Average else null end,
		case WHEN ISNUMERIC(Total6_18) = 1 then Total6_18 else null end,
		case WHEN ISNUMERIC(Total18_6) = 1 then Total18_6 else null end,
		case WHEN ISNUMERIC(Total18_6) = 1 and ISNUMERIC(Total6_18) = 1 then cast(Total18_6 as decimal(10,3)) + cast(Total6_18 as decimal(10,3)) else null end,
		case WHEN ISNUMERIC([Percent]) = 1 then [Percent] else null end
	from #GetBalanceTemp


	select Element, Attribute, Path, Level, Pos, IsInput, Total, Average,Total6_18,Total18_6,Total6_6,[Percent] from #GetBalance


	DROP TABLE #GetBalance
	DROP TABLE #GetBalanceTemp

END






