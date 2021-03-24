USE [idrms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[reportStructureReceiptAndProcessingResource_Test_01]
	@inputStartDate nvarchar(24),
	@Type int
-- @Type - 1(day), 2(month)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--///////////////////////////////////////
--//////////////////////////////////
declare	@caseIdBeg int,
	@caseIdEnd int,
	@casePrevIdBegMonth int,
	@caseIdBegMonth int,
	@firstDayOfMonth datetime,
	@firstDayOfNextMonth datetime,
	@StartDate  datetime,
	@EndDate  datetime,
--Константи для цього проекту
	@structureId int = 2198

-- Отримати перше число місяця
	IF (@firstDayOfMonth IS NULL)	SET @firstDayOfMonth = dateadd (ss,0,dateadd (mi,0,dateadd (hh,07,convert(datetime, dateadd(day,1,EOMONTH ( @inputStartDate,-1 )) , 120) )));

--Умови проміжку часу
	IF(@Type=1)
		BEGIN
			SET @StartDate =dateadd (ss,0,dateadd (mi,0,dateadd (hh,07,convert (datetime,CAST( convert(datetime, @inputStartDate, 120) AS Date ) ))));
			SET @EndDate = dateadd (day,1,@StartDate);
		END
	ELSE
		BEGIN
			SET @firstDayOfNextMonth = dateadd(m,1,@firstDayOfMonth) ;
			SET @StartDate = @firstDayOfMonth;
			SET @EndDate = @firstDayOfNextMonth;
		END

-- Отримати індент початку
	SET @caseIdBeg = (SELECT TOP (1) [Id]
	FROM [idrms].[dbo].[Cases]
	WHERE [StartTime] = @StartDate)
-- Отримати індент кінця
	SET @caseIdEnd = (CASE @Type	WHEN 1 THEN (SELECT TOP (1) [Id] FROM [idrms].[dbo].[Cases] WHERE [EndTime] = @EndDate)
									WHEN 2 THEN (SELECT  MAX ([Id]) FROM [idrms].[dbo].[Cases] WHERE [StartTime] <= @EndDate)
						END
					)
	SET @caseIdEnd =  ISNULL(@caseIdEnd, @caseIdBeg);


-- Отримати індент початку місяця
	SELECT TOP (1)
		@casePrevIdBegMonth = [PrevCaseId],
		@caseIdBegMonth = id
	FROM [idrms].[dbo].[Cases]
	WHERE [StartTime] =  @firstDayOfMonth

--*************************************************
--Родители для выборки
declare @Parents table ([Id] int,[ParentId] int,[Name] nvarchar(150));

insert into @Parents
select * from fn_GetAllChilds(@structureId)

--*************************************************
--Получаем периоды отчета
IF ( OBJECT_ID('tempdb..#Cases') IS NOT NULL)
DROP TABLE #Cases
select * into #Cases
from (select cs.[id]
	,cs.PrevCaseId
	,convert(nvarchar,cs.StartTime,104) 'StartTime'
	,convert(nvarchar,cs.EndTime,104) 'EndTime'
from [dbo].[Cases] cs
where cs.Id >= @caseIdBeg
	and cs.id <= @caseIdEnd
	and cs.AnalysisSfId =(select AnalysisSfId from dbo.cases where id = @caseIdBeg)) t

--*******************************************************
	-- Получаем список материалов, доступных в конце периода
	IF ( OBJECT_ID('tempdb..#ProductsInCaseEnd') IS NOT NULL)
	DROP TABLE #ProductsInCaseEnd
	SELECT *
	INTO #ProductsInCaseEnd
	FROM dbo.fn_GetProductsInCase(@caseIdEnd)

	-- Отримуємо список матеріалів, доступних на початок місяца
	IF ( OBJECT_ID('tempdb..#ProductsInCaseEndOfMonth') IS NOT NULL)
	DROP TABLE #ProductsInCaseEndOfMonth
	SELECT *
	INTO #ProductsInCaseEndOfMonth
	FROM dbo.fn_GetProductsInCase(@caseIdBegMonth)
--*******************************************************

--*******************************************************
-- Получаем список материалов, доступных в данном периоде
	IF ( OBJECT_ID('tempdb..#ProductsInCases') IS NOT NULL)
	DROP TABLE #ProductsInCases
	SELECT *
	INTO #ProductsInCases
	FROM dbo.fn_GetProductsInIntervalCases(@caseIdBeg,@caseIdEnd)

	-- Отримуємо список матеріалів, доступних на початок місяца
	IF ( OBJECT_ID('tempdb..#ProductsInCasesOfMonth') IS NOT NULL)
	DROP TABLE #ProductsInCasesOfMonth
	SELECT *
	INTO #ProductsInCasesOfMonth
	FROM dbo.fn_GetProductsInIntervalCases(@caseIdBegMonth,@caseIdBegMonth)
--*************************************************
--Получаем общие остатки на начало и конец периода
IF ( OBJECT_ID('tempdb..#Ostatki') IS NOT NULL)
DROP TABLE #Ostatki

select * into #Ostatki
from (
--остатки на конец
	select
		cast(0 as int) as IsNach
		,ost.[Nom_NAME] as [ProductName]
		,pg.[Name] as [GroupName]
		,pc.[Name] as [CategoryName]
		,cast(0 as bit) as [issystem]
		,null as [issystemcategory]
		,sum(isnull(ost.KOL,0)) as [Value]
	from dbo.[1COstatki4Archive] ost
		left join #ProductsInCaseEnd p on p.Id = ost.NOM_ID
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where ost.caseid = @caseIdEnd     --остатки на конец
		and VID = 'Общие'
		and ost.[NOM_ID] not in (52) --Берем все кроме: 52-Вода
		and ost.MVZ_ID in (select id from @Parents)
	group by   ost.[Nom_NAME],pg.[Name],pc.[Name]

--остатки на начало
	union all
	select
		cast(1 as int) as IsNach
		,ost.[Nom_NAME] as [ProductName]
		,pg.[Name] as [GroupName]
		,pc.[Name] as [CategoryName]
		,cast(0 as bit) as [issystem]
		,null as [issystemcategory]
		,sum(isnull(ost.KOL,0)) as [Value]
	from dbo.[1COstatki4Archive] ost
		left join #ProductsInCaseEnd p on p.Id = ost.NOM_ID
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where ost.caseid =( select PrevCaseId from #Cases where id =  @caseIdBeg)--остатки на начало
		and VID = 'Общие'
		and ost.[NOM_ID] not in (52) --Берем все кроме: 52-Вода
		and ost.MVZ_ID in (select id from @Parents)
	group by   ost.[Nom_NAME],pg.[Name],pc.[Name]

-- залишки на початок місяца
	union all
	select
		cast(2 as int) as IsNach
		,ost.[Nom_NAME] as [ProductName]
		,pg.[Name] as [GroupName]
		,pc.[Name] as [CategoryName]
		,cast(0 as bit) as [issystem]
		,null as [issystemcategory]
		,sum(isnull(ost.KOL,0)) as [Value]
	from dbo.[1COstatki4Archive] ost
		left join #ProductsInCaseEndOfMonth p on p.Id = ost.NOM_ID
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where ost.caseid = @casePrevIdBegMonth--остатки на начало
		and VID = 'Общие'
		and ost.[NOM_ID] not in (52) --Берем все кроме: 52-Вода
		and ost.MVZ_ID in (select id from @Parents)
	group by   ost.[Nom_NAME],pg.[Name],pc.[Name]
	) tmp




--******************************************
--Получаем движение по выбранному объекту
IF ( OBJECT_ID('tempdb..#Movement') IS NOT NULL)
DROP TABLE #Movement
CREATE TABLE [dbo].[#Movement]
(
	[Type] [int] NULL,
	[ProductName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[GroupName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[CategoryName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[Reconciled] [float] NULL

)

insert into #Movement
select * from (
	--Приход день
		select
			CAST(1 as int) as [Type]
			,p.[Name] AS [ProductName]
			,pg.[Name] AS [GroupName]
			,pc.[Name] AS [CategoryName]
			,sum(ioa.KOL) as [Reconciled]
		from dbo.[1CTcexInOut2Archive] ioa
			left join #ProductsInCases p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
			left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
			left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		where ioa.CaseId in (select id from #Cases)
			and MVZ_IST_kod is null
		group by p.[Name],pc.[Name],pg.[Name]
	--Расход день
	union all
		select
			CAST(2 as int) as [Type]
			,p.[Name] AS [ProductName]
			,pg.[Name] AS [GroupName]
			,pc.[Name] AS [CategoryName]
			,sum(ioa.KOL) as [Reconciled]
		from dbo.[1CTcexInOut2Archive] ioa
			left join #ProductsInCases p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
			left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
			left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		where ioa.CaseId in (select id from #Cases)
			and  MVZ_PRIEM_KOD is null
		group by p.[Name],pc.[Name],pg.[Name]
	union all
	--Приход місяць
		select
			CAST(3 as int) as [Type]
			,p.[Name] AS [ProductName]
			,pg.[Name] AS [GroupName]
			,pc.[Name] AS [CategoryName]
			,sum(ioa.KOL) as [Reconciled]
		from dbo.[1CTcexInOut2Archive] ioa
			left join #ProductsInCasesOfMonth p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
			left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
			left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		where ioa.CaseId = @caseIdBegMonth
			and MVZ_IST_kod is null
		group by p.[Name],pc.[Name],pg.[Name]
	--Расход місяць
	union all
		select
			CAST(4 as int) as [Type]
			,p.[Name] AS [ProductName]
			,pg.[Name] AS [GroupName]
			,pc.[Name] AS [CategoryName]
			,sum(ioa.KOL) as [Reconciled]
		from dbo.[1CTcexInOut2Archive] ioa
			left join #ProductsInCasesOfMonth p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
			left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
			left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		where ioa.CaseId = @caseIdBegMonth
			and  MVZ_PRIEM_KOD is null
		group by p.[Name],pc.[Name],pg.[Name]

) tmp
--***************


--Переварaчиваем #Ostatki
IF ( OBJECT_ID('tempdb..#PivotOstatki') IS NOT NULL)
DROP TABLE #PivotOstatki

select * into #PivotOstatki
FROM (
	SELECT GroupName, CategoryName, ProductName, [1] AS BalanceBeginningToday, [0] AS BalanceEndToday, [2] AS BalanceBeginningMonth
	FROM
	(select GroupName, CategoryName, IsNach, ProductName, Value
		from #Ostatki) p
	PIVOT(
	SUM (Value)
	FOR IsNach IN ( [1], [0], [2] )
	) AS pvt
) tmp

--Переварaчиваем #Movement
IF ( OBJECT_ID('tempdb..#PivotMovement') IS NOT NULL)
DROP TABLE #PivotMovement

select * into #PivotMovement
FROM (
	SELECT ProductName, GroupName, CategoryName, [2] AS [OutputToday], [1]  AS [InputToday], [3] AS [OutputMonth], [4]  AS [InputMonth]
	FROM
	(select GroupName, CategoryName, ProductName, Reconciled, [Type]
		from #Movement
	) p
	PIVOT(
	SUM (Reconciled)
	FOR [Type] IN ( [1], [2] , [3], [4] )
	) AS pvt

) tmp

--************ DEBUG ************

	--print('@caseIdBeg - ' + cast (@caseIdBeg as nvarchar(50)))
	--print('@@caseIdEnd - ' + cast (@caseIdEnd as nvarchar(50)))
	--print('@casePrevIdBegMonth - ' +cast (@casePrevIdBegMonth as nvarchar(50)))
	--print('@@caseIdBegMonth - ' +cast (@caseIdBegMonth as nvarchar(50)))

	--select * from #ProductsInCaseEndofMonth
	--select * from #ProductsInCasesofMonth
	--select * from #Movement
	--select * from #Ostatki
	--select * from #PivotOstatki
	--select * from #PivotMovement
	--select * from #Cases
--************ DEBUG ************

select
		CASE WHEN T1.ProductName  IS NULL then T2.ProductName ELSE T1.ProductName end as ProductName
		,isnull(T1.GroupName,T2.GroupName) as GroupName
		,isnull(T1.CategoryName,T2.CategoryName) as CategoryName
		,[OutputToday]
		,[InputToday]
		,[OutputMonth]
		,[InputMonth]
		,BalanceBeginningToday
		,BalanceEndToday
		,BalanceBeginningMonth

		FROM		#PivotMovement as T1
		FULL  JOIN  #PivotOstatki T2  on (T1.ProductName = T2.ProductName)

drop table #Movement
drop table #Ostatki
drop table #Cases
DROP TABLE #PivotOstatki
DROP TABLE #PivotMovement
drop table #ProductsInCaseEnd

USE [idrms]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[reportStructurGetLastPeriod_Test_01]
	@inputStartDate nvarchar(24),
	@Type int
-- @Type - 1(day), 2(month)
AS
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE
	@firstDayOfNextMonth date;

	IF (@Type=2)
		BEGIN
			select @firstDayOfNextMonth = dateadd(day,1,EOMONTH ( @inputStartDate ))
--************ DEBUG
	--select @firstDayOfNextMonth
--************ DEBUG
			select convert (date, max(EndTime), 120)  LastEndTime from cases where StartTime <= @firstDayOfNextMonth
		END
	ELSE
		select convert(date, GetDAte(),120)
