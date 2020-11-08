USE [idrms]
GO
/****** Object:  StoredProcedure [dbo].[reportGetMixing_Group]    Script Date: 08.11.2020 17:49:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[reportGetMixing_Group_Test_01]
	@StartDate nvarchar(24)
AS
BEGIN


SET NOCOUNT ON

IF ( OBJECT_ID('tempdb..#GetMixing') IS NOT NULL)
DROP TABLE #GetMixing
CREATE TABLE [dbo].[#GetMixing]
(
   [isdeleted] [int] NULL
  ,[createcaseid] [int] NULL
  ,[deletecaseid] [int] NULL
  ,nodeid  [int] NULL
  ,[isInput]  [int] NULL
  ,[parentID]  [int] NULL
  ,[CaseId]  [int] NULL
  ,[ProductId]  [int] NULL
  ,[Measured][float] NULL
  ,[Reconciled] [float] NULL
  ,[ProductId2] [int] NULL

)


declare	@caseIdBeg int;


SET @caseIdBeg = (SELECT TOP (1) [Id]
FROM [idrms].[dbo].[Cases]
WHERE [StartTime] = dateadd (ss,0,dateadd (mi,0,dateadd (hh,06,convert (datetime,CAST( convert(datetime, @StartDate, 120) AS Date ) )))))

INSERT INTO #GetMixing
--exec [dbo].[reportGetMixing_Group] @caseIdBeg --без сокращения
exec reportGetMixingTrimmed 6101, '-1' -- з сокращением

select T1.Reconciled, T4.Name ProdVer,  T3.Name  ProdHor
from  #GetMixing T1 left join Objects  T2 on  T1.[parentID] = T2.id
left join [Products] T3 on T1.ProductId=T3.id and T3.IsDeleted = 0  left join [Products] T4 on T1.ProductId2=T4.id and T4.IsDeleted = 0
where  T1.isInput = 0 and T1.Reconciled > 0


DROP TABLE #GetMixing

END



USE [idrms]
GO
/****** Object:  StoredProcedure [dbo].[reportGetMixing_Group]    Script Date: 08.11.2020 17:49:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[reportGetStartEndDateForMixing_Group_Test_01]
	@StartDate nvarchar(24) = ''
AS
BEGIN


SET NOCOUNT ON

declare @DefDate nvarchar(100);


if (@StartDate IS NULL OR @StartDate = '')
BEGIN
	SET @StartDate = convert(date, GetDate(), 120);
END


SET @DefDate = (SELECT 	convert ( nvarchar(24),StartTime,120) + ' - ' + convert ( nvarchar(24), EndTime,120)  as StartTimeEndTime
				FROM [idrms].[dbo].[Cases]
				WHERE [StartTime] = dateadd (ss,0,dateadd (mi,0,dateadd (hh,06,convert (datetime,CAST( convert(datetime, @StartDate, 120) AS Date ) ))))
				);
if (@DefDate IS NULL)
	SELECT convert (nvarchar(100) , dateadd (ss,0,dateadd (mi,0,dateadd (hh,06,convert (datetime,CAST( convert(date, GetDate(), 120) AS Date ) )))),120)  + ' - ' + convert (nvarchar(100) , dateadd (ss,0,dateadd (mi,0,dateadd (hh,06,convert (datetime,CAST( convert(date, GetDate(), 120) AS Date ) )))),120)   as StartTimeEndTime;
else
	SELECT @DefDate as StartTimeEndTime;

END




