USE [idrms]
GO

/****** Object:  StoredProcedure [dbo].[reportGetProductionName]    Script Date: 02.11.2020 13:19:48 ******/
DROP PROCEDURE [dbo].[reportGetProductionName]
GO

/****** Object:  StoredProcedure [dbo].[reportGetProductionName]    Script Date: 02.11.2020 13:19:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[reportGetProductionName] 
AS
SET NOCOUNT ON
SET XACT_ABORT ON
 
SELECT  T1.[Name], T2.[SortIndex],T1.id
FROM [idrms].[dbo].[Objects] T1 left join [idrms].[dbo].[ObjectSorting] T2 on (T1.Id=T2.ObjectId)
where [ParentId] = 100 and ObjectTypeId = 1
order by T1.[Name] desc
GO


USE [idrms]
GO

/****** Object:  StoredProcedure [dbo].[reportGetFirstProductionName]    Script Date: 02.11.2020 13:19:58 ******/
DROP PROCEDURE [dbo].[reportGetFirstProductionName]
GO

/****** Object:  StoredProcedure [dbo].[reportGetFirstProductionName]    Script Date: 02.11.2020 13:19:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[reportGetFirstProductionName] 
AS
SET NOCOUNT ON
SET XACT_ABORT ON
 
SELECt TOP(1) T1.[Name], T2.[SortIndex],T1.id
FROM [idrms].[dbo].[Objects] T1 left join [idrms].[dbo].[ObjectSorting] T2 on (T1.Id=T2.ObjectId)
where [ParentId] = 100 and ObjectTypeId = 1
order by T1.[Name] desc

GO

USE [idrms]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetAllChilds_Test_01]    Script Date: 02.11.2020 13:20:19 ******/
DROP FUNCTION [dbo].[fn_GetAllChilds_Test_01]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetAllChilds_Test_01]    Script Date: 02.11.2020 13:20:19 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetAllChilds_Test_01] (@ParentId nvarchar(max))  
RETURNS @table table(Id int, ParentId int, Name nvarchar(200))  AS  
BEGIN 
declare @last table(Id int)
declare @prev table(Id int)
declare @ProductionId table(Id int)

insert into @ProductionId (id)
select cast(item as int) from [idrms].[dbo].[ufnSplit_Test_01] (@ParentId,',')

insert into @prev (id) 
select id from @ProductionId
if (select top (1) ParentId from dbo.Objects where Id in (select id from @ProductionId) and ParentId is null) is not null
begin
insert  into @table values(null,null,'Tёх')
end
insert into @table select Id,ParentId,Name from Objects where (Id in (select id from @ProductionId))
table_loop:
insert into @last select Id from Objects where (ParentId in (select Id from @prev)) AND (ObjectTypeId=1)
if (ROWCOUNT_BIG ( ) > 0)
begin
	insert into @table select Id,ParentId,Name from Objects where (Id in (select Id from @last))
	delete from @prev
	insert into @prev select Id from Objects where (Id in (select Id from @last))
	delete from @last
	goto table_loop
end
return
END
GO

USE [idrms]
GO

/****** Object:  UserDefinedFunction [dbo].[ufnSplit_Test_01]    Script Date: 02.11.2020 13:21:15 ******/
DROP FUNCTION [dbo].[ufnSplit_Test_01]
GO

/****** Object:  UserDefinedFunction [dbo].[ufnSplit_Test_01]    Script Date: 02.11.2020 13:21:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[ufnSplit_Test_01]
   (@RepParam nvarchar(max), @Delim char(1)= ',')
RETURNS @Values TABLE (Item nvarchar(100))AS

  BEGIN
  DECLARE @chrind INT
  DECLARE @Piece nvarchar(100)
  SELECT @chrind = 1
  WHILE @chrind > 0
    BEGIN
      SELECT @chrind = CHARINDEX(@Delim,@RepParam)
      IF @chrind  > 0
        SELECT @Piece = LEFT(@RepParam,@chrind - 1)
      ELSE
        SELECT @Piece = @RepParam
      INSERT  @Values(Item) VALUES(@Piece)
      SELECT @RepParam = RIGHT(@RepParam,LEN(@RepParam) - @chrind)
      IF LEN(@RepParam) = 0 BREAK
    END
  RETURN
  END
GO

USE [idrms]
GO

/****** Object:  StoredProcedure [dbo].[reportStructureMovement2ProductsGroup_Test_01]    Script Date: 02.11.2020 13:22:23 ******/
DROP PROCEDURE [dbo].[reportStructureMovement2ProductsGroup_Test_01]
GO

/****** Object:  StoredProcedure [dbo].[reportStructureMovement2ProductsGroup_Test_01]    Script Date: 02.11.2020 13:22:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--EXEC reportStructureMovement2ProductsGroup 696, 696, 5424 drop table #Toplivo
CREATE PROCEDURE [dbo].[reportStructureMovement2ProductsGroup_Test_01] 
	@StartDate nvarchar(24),
	@EndDate  nvarchar(24),
	@ProductionName nvarchar(max)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--///////////////////////////////////////
--//////////////////////////////////
declare	@caseIdBeg int,
	@caseIdEnd int,
	@structureId int;


	SET @caseIdBeg = (SELECT TOP (1) [Id]
	FROM [idrms].[dbo].[Cases]
	WHERE [StartTime] = dateadd (ss,0,dateadd (mi,0,dateadd (hh,06,convert (datetime,CAST( convert(datetime, @StartDate, 120) AS Date ) )))))

	SET @caseIdEnd = (SELECT TOP (1) [Id]
	FROM [idrms].[dbo].[Cases]
	WHERE [StartTime] = dateadd (ss,0,dateadd (mi,0,dateadd (hh,06,convert (datetime,CAST( convert(datetime, @EndDate, 120) AS Date ) )))))

	SET @structureId = (SELECT top(1) T1.[Id]
	FROM [idrms].[dbo].[Objects] T1
	where [Name] = @ProductionName)

exec dbo.reportStructureMovement2ProductsGroup_from1C_Test_01 @caseIdBeg,@caseIdEnd,@structureId

GO

USE [idrms]
GO

/****** Object:  StoredProcedure [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_01]    Script Date: 02.11.2020 13:22:36 ******/
DROP PROCEDURE [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_01]
GO

/****** Object:  StoredProcedure [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_01]    Script Date: 02.11.2020 13:22:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--EXEC reportStructureMovement2ProductsGroup 696, 696, 5424 drop table #Toplivo
CREATE PROCEDURE [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_01] 
	@caseIdBeg int,
	@caseIdEnd int,
	@structureId int
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--///////////////////////////////////////
--//////////////////////////////////


--*************************************************
--Родители для выборки
declare @Parents table ([Id] int,[ParentId] int,[Name] nvarchar(150));
	
insert into @Parents
select * from fn_GetAllChilds (@structureId)

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

--	select * from #cases

IF ( OBJECT_ID('tempdb..#ProductsInCaseEnd') IS NOT NULL)
DROP TABLE #ProductsInCaseEnd
SELECT *
INTO #ProductsInCaseEnd
FROM dbo.fn_GetProductsInCase(@caseIdEnd)

-- Получаем список материалов, доступных в данном периодах
IF ( OBJECT_ID('tempdb..#ProductsInCases') IS NOT NULL)
DROP TABLE #ProductsInCases
SELECT *
INTO #ProductsInCases
FROM dbo.fn_GetProductsInIntervalCases(@caseIdBeg,@caseIdEnd)
--*************************************************
--Получаем общие остатки на начало и конец периода
IF ( OBJECT_ID('tempdb..#Ostatki') IS NOT NULL)
DROP TABLE #Ostatki

select * into #Ostatki
from (
--остатки на конец
	select
		cast(0 as bit) as IsNach
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
	group by  ost.[Nom_NAME],pg.[Name],pc.[Name]

--остатки на начало	
	union all
	select
		cast(1 as bit) as IsNach
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
	) tmp
 
--******************************************
--Получаем движение по выбранному объекту
IF ( OBJECT_ID('tempdb..#Movement') IS NOT NULL)
DROP TABLE #Movement
CREATE TABLE [dbo].[#Movement]
(
	[Type] [int] NULL,
	[UnitName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[IsInput] [bit] NULL,
	[ProductName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[GroupName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[CategoryName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[Measured] [float] NULL,
	[Reconciled] [float] NULL,
	[IncludeInParentCeh] [BIT] NULL
)

insert into #Movement
select * from (
	--Приход
	select 
		CAST(10 as int) as [Type]
		,ioa.MVZ_IST_NAME as UnitName
		,CAST(1 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(ioa.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CTcexInOut2Archive] ioa
		left join #ProductsInCases p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where ioa.CaseId in (select id from #Cases)
		and MVZ_PRIEM_ID in (select id  from @Parents)
		and MVZ_IST_ID not in (select id  from @Parents)
		and ioa.KOL<>0
	group by ioa.MVZ_IST_NAME,p.[Name],pc.[Name],pg.[Name]
	--Расход
	union all
	select 
		CAST(15 as int) as [Type]
		,ioa.MVZ_PRIEM_NAME as [UnitName]
		,CAST(0 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(ioa.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CTcexInOut2Archive] ioa
		left join #ProductsInCases p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where ioa.CaseId in (select id from #Cases)
		and MVZ_IST_ID in (select id  from @Parents)
		and MVZ_PRIEM_ID not in (select id  from @Parents)
		and ioa.KOL<>0
	group by ioa.MVZ_PRIEM_NAME,p.[Name],pc.[Name],pg.[Name]

	--Из смешения
	union all
	select 
		CAST(35 as int) as [Type]
		,'З змішування' as [UnitName]
		,CAST(1 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(mx.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CMixing6Archive] mx
		left join #ProductsInCases p on p.Id = mx.NOM_PROD_ID and p.CaseId = mx.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where mx.CaseId in (select id from #Cases)
		and mx.MVZ_ID in (select id  from @Parents)
	group by mx.NOM_PROD_NAME,p.[Name],pc.[Name],pg.[Name]

	--В смешение
	union all
	select 
		CAST(35 as int) as [Type]
		,'В змішання' as [UnitName]
		,CAST(0 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(mx.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CMixing6Archive] mx
		left join #ProductsInCases p on p.Id = mx.NOM_KOMP_ID and p.CaseId = mx.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where mx.CaseId in (select id from #Cases)
		and mx.MVZ_ID in (select id  from @Parents)
	group by mx.NOM_KOMP_NAME,p.[Name],pc.[Name],pg.[Name]


	--Получено на установках выбранного производства
	union all
	select 
		CAST(20 as int) as [Type]
		,um.MVZ_NAME as UnitName
		,CAST(1 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(um.KOL) as [Reconciled]
		,CAST(1 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CUnitsInOut1.1Archive] um
		left join #ProductsInCases p on p.Id = um.NOM_ID and p.CaseId = um.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where um.CaseId in (select id from #Cases)
		and um.MVZ_ID in (select id  from @Parents)
		and um.IsInput = 0
		and um.KOL<>0
	group by um.MVZ_NAME,p.[Name],pg.[Name],pc.[Name]
	
	--Потреблено установками выбранного производства
	union all
	select 
		CAST(20 as int) as [Type]
		,um.MVZ_NAME as UnitName
		,CAST(0 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(um.KOL) as [Reconciled]
		,CAST(1 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CUnitsInOut1.1Archive] um
		left join #ProductsInCases p on p.Id = um.NOM_ID and p.CaseId = um.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
	where um.CaseId in (select id from #Cases)
		and um.MVZ_ID in (select id  from @Parents)
		and um.IsInput = 1
		and um.KOL<>0
	group by um.MVZ_NAME,p.[Name],pg.[Name],pc.[Name]
) tmp






--***********************************
--**Возвращаем данные отчета*********

--Часть таблиц возвращаю пустыми только что бы правильно отрабатывал построитель отчетов.
----*******************************************************************************************
--DECLARE @links TABLE(SourceId int, DestId int, SourceType int, DestType int, SourceName nvarchar(100), DestName nvarchar(100), SourceParent nvarchar(50), DestParent nvarchar(50), SourceParentId int, DestParentId int, ProductName nvarchar(500), GroupName nvarchar(500), CategoryName nvarchar(500), Measured float, Reconciled FLOAT,OutOfBalanceTceh bit)

-------Вывод результатов-----
--SELECT * FROM @links      --0 --В текущей радакции всегда пустое (не совсем понимаю что должно быть)
--WHERE [OutOfBalanceTceh]=0
--SELECT * FROM @links      --1 --В текущей радакции всегда пустое (не совсем понимаю что должно быть)
--WHERE [OutOfBalanceTceh]=1
-----------------------------

--Формируем данные для datatable по потокам в балансе!!! --2
select 	
		
		Type
		,UnitName
		,CASE WHEN IsInput = 0 THEN 'Витрати' 
		ELSE 'Прихiд'
		END IsInput
		,T1.ProductName
		,GroupName
		,CategoryName
		,Measured
		,Reconciled
		,IncludeInParentCeh
		 ,T3.ProductSortIndex
		 ,T4.BalanceBeginning
		 ,T4.BalanceEnd

		from #Movement as T1
								left join  (SELECT    ISNULL((SELECT   dbo.Sorting.SortIndex
															  FROM     dbo.Sorting
															  WHERE    (dbo.Sorting.ProductId = #ProductsInCaseEnd.Id) AND (dbo.Sorting.StructureId = @structureId)), #ProductsInCaseEnd.SortIndex) AS ProductSortIndex,
															#ProductsInCaseEnd.Name as ProductName
											FROM         #ProductsInCaseEnd) T3
								on  (T1.ProductName = T3.ProductName)
								left join (SELECT ProductName, [1] AS BalanceBeginning, [0] AS BalanceEnd
											FROM   
											(select IsNach,ProductName,Value
											 from #Ostatki) p  
											PIVOT  
											(SUM (Value)  
											FOR IsNach IN ( [1], [0] )  
											) AS pvt ) T4
								on (T1.ProductName = T4.ProductName)



---------------------------
--Формируем данные для datatable по потокам вне баланса!!! --3
--select * from #Movement where 1=2 --В текущей радакции всегда пустое (не совсем понимаю что должно быть)

---------------------------
--Формируем данные для datatable по потокам в балансе!!! 4
--select IsNach,ProductName,GroupName,CategoryName,issystem,issystemcategory,Value
-- from #Ostatki
--order by [ProductName]


--SELECT ProductName, [1] AS IsNach_1, [0] AS IsNach_0
--FROM   
--(select IsNach,ProductName,Value
-- from #Ostatki) p  
--PIVOT  
--(SUM (Value)  
--FOR IsNach IN ( [1], [0] )  
--) AS pvt  










---------------------------
--Формируем данные для datatable по потокам в балансе!!! 5
--пустышка
--select * from #Ostatki 
--where 2=1 
--order by [ProductName]

--по неизвестному продукту --6
--select 0 ,0 ,0 ,0 ,0 where 2=1

-- сортировка по продуктам 9
--SELECT    ISNULL((SELECT     dbo.Sorting.SortIndex
--                              FROM         dbo.Sorting
--                              WHERE     (dbo.Sorting.ProductId = #ProductsInCaseEnd.Id) AND (dbo.Sorting.StructureId = @structureId)), #ProductsInCaseEnd.SortIndex) AS SortIndex,
--	#ProductsInCaseEnd.Name as ProductName
--FROM         #ProductsInCaseEnd

---- сортировка по установкам 10
--SELECT    	 ISNULL
--                          ((SELECT     dbo.ObjectSorting.SortIndex
--                              FROM         dbo.ObjectSorting
--                              WHERE     (dbo.ObjectSorting.ObjectId = dbo.Objects.Id) AND (dbo.ObjectSorting.StructureId =  @structureId)), 65565) AS SortIndex,
--	dbo.fn_GetName(dbo.Objects.Id, @CaseIdEnd) as ObjectName
--FROM  dbo.Objects
--WHERE dbo.Objects.ParentId in (select id from @Parents) and
--((dbo.Objects.ObjectTypeId = 8) OR (dbo.Objects.ObjectTypeId = 256)) 
----AND ((dbo.Objects.ParentId=@structureId) OR (dbo.fn_IsInStructure(dbo.Objects.ParentId, @structureId)=1))

----11
--select count(*) from objects where parentid in (select id from @Parents) and objecttypeid=8

----12
----пустышка
--select 0

----13
---- Топливо
--select 
--	tpl.MVZ_NAME
--	,tpl.NOM_KOD as [ProductCode]
--	,tpl.NOM_NAME as [ProductName]
--	,dbo.fn_GetParentId(tpl.MVZ_ID) as [StructureId]
--	,tpl.KOL
--	,tpl.CaseId
--from dbo.[1CToplivo5Archive] tpl
--where tpl.CaseId in (select id from #Cases)
--	and tpl.MVZ_ID in (select id from @Parents) 

drop table #Movement
drop table #Ostatki
drop table #Cases

drop table #ProductsInCaseEnd



GO

USE [idrms]
GO

/****** Object:  StoredProcedure [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_02]    Script Date: 02.11.2020 13:22:47 ******/
DROP PROCEDURE [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_02]
GO

/****** Object:  StoredProcedure [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_02]    Script Date: 02.11.2020 13:22:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--EXEC reportStructureMovement2ProductsGroup 696, 696, 5424 drop table #Toplivo
CREATE PROCEDURE [dbo].[reportStructureMovement2ProductsGroup_from1C_Test_02] 
	@caseIdBeg int,
	@caseIdEnd int,
	@structureId nvarchar(max)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
--///////////////////////////////////////
--//////////////////////////////////


--*************************************************
--Родители для выборки
declare @Parents table ([Id] int,[ParentId] int,[Name] nvarchar(150));
	
insert into @Parents
select * from fn_GetAllChilds_Test_01 (@structureId)

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

--	select * from #cases

IF ( OBJECT_ID('tempdb..#ProductsInCaseEnd') IS NOT NULL)
DROP TABLE #ProductsInCaseEnd
SELECT *
INTO #ProductsInCaseEnd
FROM dbo.fn_GetProductsInCase(@caseIdEnd)

-- Получаем список материалов, доступных в данном периодах
IF ( OBJECT_ID('tempdb..#ProductsInCases') IS NOT NULL)
DROP TABLE #ProductsInCases
SELECT *
INTO #ProductsInCases
FROM dbo.fn_GetProductsInIntervalCases(@caseIdBeg,@caseIdEnd)
--*************************************************
--Получаем общие остатки на начало и конец периода
IF ( OBJECT_ID('tempdb..#Ostatki') IS NOT NULL)
DROP TABLE #Ostatki

select * into #Ostatki
from (
--остатки на конец
	select
		par.id
		,par.ParentId
		,cast(0 as bit) as IsNach
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
		left join  @Parents par on par.id=ost.MVZ_ID 
	where ost.caseid = @caseIdEnd     --остатки на конец
		and VID = 'Общие'
		and ost.[NOM_ID] not in (52) --Берем все кроме: 52-Вода
		and ost.MVZ_ID in (select id from @Parents)
	group by par.id,par.ParentId, ost.[Nom_NAME],pg.[Name],pc.[Name]

--остатки на начало	
	union all
	select
		par.id
		,par.ParentId
		,cast(1 as bit) as IsNach
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
		left join  @Parents par on par.id=ost.MVZ_ID
	where ost.caseid =( select PrevCaseId from #Cases where id =  @caseIdBeg)--остатки на начало
		and VID = 'Общие'
		and ost.[NOM_ID] not in (52) --Берем все кроме: 52-Вода
		and ost.MVZ_ID in (select id from @Parents)
	group by  par.id,par.ParentId, ost.[Nom_NAME], pg.[Name], pc.[Name]
	) tmp
 
--******************************************
--Получаем движение по выбранному объекту
IF ( OBJECT_ID('tempdb..#Movement') IS NOT NULL)
DROP TABLE #Movement
CREATE TABLE [dbo].[#Movement]
(
	[ParentId] [int] Null,
	[UnitId] [int] NULL,
	[Type] [int] NULL,
	[UnitName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[IsInput] [bit] NULL,
	[ProductName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[GroupName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[CategoryName] [nvarchar](250) COLLATE Cyrillic_General_CI_AS NULL,
	[Measured] [float] NULL,
	[Reconciled] [float] NULL,
	[IncludeInParentCeh] [BIT] NULL
)

insert into #Movement
select * from (
	--Приход
	select 
		par.ParentId
		,par.id
		,CAST(10 as int) as [Type]
		,ioa.MVZ_IST_NAME as UnitName
		,CAST(1 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(ioa.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CTcexInOut2Archive] ioa
		left join #ProductsInCases p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		left join  @Parents par on par.id=ioa.MVZ_PRIEM_ID
	where ioa.CaseId in (select id from #Cases)
		and MVZ_PRIEM_ID in (select id  from @Parents)
		and MVZ_IST_ID not in (select id  from @Parents)
		and ioa.KOL<>0
	group by par.id, par.ParentId, ioa.MVZ_IST_NAME ,p.[Name],pc.[Name],pg.[Name]
	--Расход
	union all
	select 
		par.ParentId
		,par.id
		,CAST(15 as int) as [Type]
		,ioa.MVZ_PRIEM_NAME as [UnitName]
		,CAST(0 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(ioa.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CTcexInOut2Archive] ioa
		left join #ProductsInCases p on p.Id = ioa.NOM_ID and p.CaseId = ioa.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		left join  @Parents par on par.id=ioa.MVZ_IST_ID
	where ioa.CaseId in (select id from #Cases)
		and MVZ_IST_ID in (select id  from @Parents)
		and MVZ_PRIEM_ID not in (select id  from @Parents)
		and ioa.KOL<>0
	group by par.id, par.ParentId, ioa.MVZ_PRIEM_NAME,p.[Name],pc.[Name],pg.[Name]

	--Из смешения
	union all
	select 
		par.ParentId
		,par.id
		,CAST(35 as int) as [Type]
		,'З змішування' as [UnitName]
		,CAST(1 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(mx.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CMixing6Archive] mx
		left join #ProductsInCases p on p.Id = mx.NOM_PROD_ID and p.CaseId = mx.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		left join  @Parents par on par.id=mx.MVZ_ID
	where mx.CaseId in (select id from #Cases)
		and mx.MVZ_ID in (select id  from @Parents)
	group by par.id, par.ParentId, mx.NOM_PROD_NAME,p.[Name],pc.[Name],pg.[Name]

	--В смешение
	union all
	select 
		par.ParentId
		,par.id
		,CAST(35 as int) as [Type]
		,'В змішання' as [UnitName]
		,CAST(0 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(mx.KOL) as [Reconciled]
		,CAST(0 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CMixing6Archive] mx
		left join #ProductsInCases p on p.Id = mx.NOM_KOMP_ID and p.CaseId = mx.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		left join  @Parents par on par.id=mx.MVZ_ID
	where mx.CaseId in (select id from #Cases)
		and mx.MVZ_ID in (select id  from @Parents)
	group by par.id, par.ParentId, mx.NOM_KOMP_NAME,p.[Name],pc.[Name],pg.[Name]


	--Получено на установках выбранного производства
	union all
	select 
		par.ParentId
		,par.id
		,CAST(20 as int) as [Type]
		,um.MVZ_NAME as UnitName
		,CAST(1 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(um.KOL) as [Reconciled]
		,CAST(1 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CUnitsInOut1.1Archive] um
		left join #ProductsInCases p on p.Id = um.NOM_ID and p.CaseId = um.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		left join  @Parents par on par.id=um.MVZ_ID
	where um.CaseId in (select id from #Cases)
		and um.MVZ_ID in (select id  from @Parents)
		and um.IsInput = 0
		and um.KOL<>0
	group by par.id, par.ParentId,um.MVZ_NAME,p.[Name],pg.[Name],pc.[Name]
	
	--Потреблено установками выбранного производства
	union all
	select 
		par.ParentId
		,par.id
		,CAST(20 as int) as [Type]
		,um.MVZ_NAME as UnitName
		,CAST(0 as bit) AS [IsInput]
		,p.[Name] AS [ProductName]
		,pg.[Name] AS [GroupName]
		,pc.[Name] AS [CategoryName]
		,CAST(0 as int) as [Measured]
		,sum(um.KOL) as [Reconciled]
		,CAST(1 AS INT) AS [IncludeInParentCeh] 
	from dbo.[1CUnitsInOut1.1Archive] um
		left join #ProductsInCases p on p.Id = um.NOM_ID and p.CaseId = um.CaseId
		left join [dbo].[ProductCategories] pc on pc.id = p.CategoryId
		left join [dbo].[ProductGroups] pg on pg.Id = p.GroupId
		left join  @Parents par on par.id=um.MVZ_ID
	where um.CaseId in (select id from #Cases)
		and um.MVZ_ID in (select id  from @Parents)
		and um.IsInput = 1
		and um.KOL<>0
	group by par.id, par.ParentId,um.MVZ_NAME,p.[Name],pg.[Name],pc.[Name]
) tmp






--***********************************
--**Возвращаем данные отчета*********

--Часть таблиц возвращаю пустыми только что бы правильно отрабатывал построитель отчетов.
----*******************************************************************************************
--DECLARE @links TABLE(SourceId int, DestId int, SourceType int, DestType int, SourceName nvarchar(100), DestName nvarchar(100), SourceParent nvarchar(50), DestParent nvarchar(50), SourceParentId int, DestParentId int, ProductName nvarchar(500), GroupName nvarchar(500), CategoryName nvarchar(500), Measured float, Reconciled FLOAT,OutOfBalanceTceh bit)

-------Вывод результатов-----
--SELECT * FROM @links      --0 --В текущей радакции всегда пустое (не совсем понимаю что должно быть)
--WHERE [OutOfBalanceTceh]=0
--SELECT * FROM @links      --1 --В текущей радакции всегда пустое (не совсем понимаю что должно быть)
--WHERE [OutOfBalanceTceh]=1
-----------------------------

--Формируем данные для datatable по потокам в балансе!!! --2
select 	
		ParentId
		,UnitId
		,Type
		,UnitName
		,CASE WHEN IsInput = 0 THEN 'Витрати' 
		ELSE 'Прихiд'
		END IsInput
		,T1.ProductName
		,GroupName
		,CategoryName
		,Measured
		,Reconciled
		,IncludeInParentCeh
		 ,0 as ProductSortIndex
		 --,T4.BalanceBeginning
		-- ,T4.BalanceEnd
		 --,  CASE WHEN IsInput = 1
		 --THEN sum(Reconciled) over (partition by T1.ProductName,IsInput) + T4.BalanceBeginning else 
			--	sum(Reconciled) over (partition by T1.ProductName,IsInput) + T4.BalanceEnd  
		 --END test
		from #Movement as T1-- left join (SELECT Id, ProductName, [1] AS BalanceBeginning, [0] AS BalanceEnd
		--									FROM   
		--									(select IsNach,ProductName,id,Value
		--									 from #Ostatki) p  
		--									PIVOT  
		--									(SUM (Value)  
		--									FOR IsNach IN ( [1], [0] )  
		--									) AS pvt ) T4
		--						on (T1.UnitId =T4.id and T1.ProductName = T4.ProductName)


	--left join @Parents T2 on (T1.UnitId =T2.id) 
		
		
								--left join  (SELECT ISNULL(T.SortIndex, #ProductsInCaseEnd.SortIndex) AS ProductSortIndex, #ProductsInCaseEnd.Name as ProductName	
								--			FROM (SELECT		dbo.Sorting.SortIndex, dbo.Sorting.StructureId
								--					FROM		dbo.Sorting
								--					WHERE    (dbo.Sorting.ProductId = #ProductsInCaseEnd.Id) AND (dbo.Sorting.StructureId in (select distinct ParentId  from @Parents))) T

								--		FROM  #ProductsInCaseEnd) T3
								--on (T2.ParentId = T3.Structureid) and (T1.ProductName = T3.ProductName)
---------------------------
--Формируем данные для datatable по потокам вне баланса!!! --3
--select * from #Movement where 1=2 --В текущей радакции всегда пустое (не совсем понимаю что должно быть)

---------------------------
--Формируем данные для datatable по потокам в балансе!!! 4
--select IsNach,ProductName,GroupName,CategoryName,issystem,issystemcategory,Value
-- from #Ostatki
--order by [ProductName]


--SELECT ProductName, [1] AS IsNach_1, [0] AS IsNach_0
--FROM   
--(select IsNach,ProductName,Value
-- from #Ostatki) p  
--PIVOT  
--(SUM (Value)  
--FOR IsNach IN ( [1], [0] )  
--) AS pvt  










---------------------------
--Формируем данные для datatable по потокам в балансе!!! 5
--пустышка
--select * from #Ostatki 
--where 2=1 
--order by [ProductName]

--по неизвестному продукту --6
--select 0 ,0 ,0 ,0 ,0 where 2=1

-- сортировка по продуктам 9
--SELECT    ISNULL((SELECT     dbo.Sorting.SortIndex
--                              FROM         dbo.Sorting
--                              WHERE     (dbo.Sorting.ProductId = #ProductsInCaseEnd.Id) AND (dbo.Sorting.StructureId = @structureId)), #ProductsInCaseEnd.SortIndex) AS SortIndex,
--	#ProductsInCaseEnd.Name as ProductName
--FROM         #ProductsInCaseEnd

---- сортировка по установкам 10
--SELECT    	 ISNULL
--                          ((SELECT     dbo.ObjectSorting.SortIndex
--                              FROM         dbo.ObjectSorting
--                              WHERE     (dbo.ObjectSorting.ObjectId = dbo.Objects.Id) AND (dbo.ObjectSorting.StructureId =  @structureId)), 65565) AS SortIndex,
--	dbo.fn_GetName(dbo.Objects.Id, @CaseIdEnd) as ObjectName
--FROM  dbo.Objects
--WHERE dbo.Objects.ParentId in (select id from @Parents) and
--((dbo.Objects.ObjectTypeId = 8) OR (dbo.Objects.ObjectTypeId = 256)) 
----AND ((dbo.Objects.ParentId=@structureId) OR (dbo.fn_IsInStructure(dbo.Objects.ParentId, @structureId)=1))

----11
--select count(*) from objects where parentid in (select id from @Parents) and objecttypeid=8

----12
----пустышка
--select 0

----13
---- Топливо
--select 
--	tpl.MVZ_NAME
--	,tpl.NOM_KOD as [ProductCode]
--	,tpl.NOM_NAME as [ProductName]
--	,dbo.fn_GetParentId(tpl.MVZ_ID) as [StructureId]
--	,tpl.KOL
--	,tpl.CaseId
--from dbo.[1CToplivo5Archive] tpl
--where tpl.CaseId in (select id from #Cases)
--	and tpl.MVZ_ID in (select id from @Parents) 

drop table #Movement
drop table #Ostatki
drop table #Cases

drop table #ProductsInCaseEnd



GO



USE [idrms]
GO
/****** Object:  Table [dbo].[1CLosses3Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1CLosses3Archive](
	[MVZ_KOD] [bigint] NULL,
	[MVZ_NAME] [nvarchar](250) NULL,
	[NOM_KOD] [bigint] NULL,
	[NOM_NAME] [nvarchar](250) NULL,
	[KOL] [float] NULL,
	[CaseId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[1CMixing6Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1CMixing6Archive](
	[NOM_KOMP_KOD] [bigint] NULL,
	[NOM_KOMP_NAME] [nvarchar](250) NULL,
	[NOM_PROD_KOD] [bigint] NULL,
	[NOM_PROD_NAME] [nvarchar](250) NULL,
	[MVZ_KOD] [bigint] NULL,
	[MVZ_NAME] [nvarchar](250) NULL,
	[TYP] [nvarchar](250) NOT NULL,
	[KOL] [float] NULL,
	[CaseId] [int] NULL,
	[NOM_KOMP_ID] [int] NULL,
	[NOM_PROD_ID] [int] NULL,
	[MVZ_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[1COstatki4Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1COstatki4Archive](
	[MVZ_KOD] [bigint] NULL,
	[MVZ_NAME] [nvarchar](250) NULL,
	[NOM_KOD] [bigint] NULL,
	[NOM_NAME] [nvarchar](250) NULL,
	[KOL] [float] NULL,
	[VID] [varchar](50) NOT NULL,
	[CaseId] [int] NOT NULL,
	[NOM_ID] [int] NULL,
	[MVZ_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[1CTcexInOut2Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1CTcexInOut2Archive](
	[MVZ_IST_KOD] [bigint] NULL,
	[MVZ_IST_NAME] [nvarchar](250) NULL,
	[MVZ_PRIEM_KOD] [bigint] NULL,
	[MVZ_PRIEM_NAME] [nvarchar](250) NULL,
	[NOM_KOD] [bigint] NULL,
	[NOM_NAME] [nvarchar](250) NULL,
	[KOL] [float] NULL,
	[CaseId] [int] NULL,
	[NOM_ID] [int] NULL,
	[MVZ_IST_ID] [int] NULL,
	[MVZ_PRIEM_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[1CToplivo5Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1CToplivo5Archive](
	[MVZ_KOD] [bigint] NULL,
	[MVZ_NAME] [nvarchar](4000) NULL,
	[NOM_KOD] [bigint] NULL,
	[NOM_NAME] [nvarchar](250) NULL,
	[KOL] [float] NULL,
	[CaseId] [int] NULL,
	[MVZ_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[1CUnitsInOut1.1Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1CUnitsInOut1.1Archive](
	[MVZ_KOD] [bigint] NULL,
	[MVZ_NAME] [nvarchar](250) NULL,
	[IsInput] [bit] NOT NULL,
	[NOM_KOD] [bigint] NULL,
	[NOM_NAME] [nvarchar](250) NULL,
	[KOL] [float] NULL,
	[CaseId] [int] NULL,
	[NOM_ID] [int] NULL,
	[MVZ_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[1CUnitsInOut1Archive]    Script Date: 02.11.2020 13:49:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[1CUnitsInOut1Archive](
	[MVZ_KOD] [bigint] NULL,
	[MVZ_NAME] [nvarchar](250) NULL,
	[NOM_KOD] [bigint] NULL,
	[NOM_NAME] [nvarchar](250) NULL,
	[KOL_POTREB] [float] NULL,
	[KOL_VIRAB] [float] NULL,
	[CaseId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[1CLosses3Archive]  WITH CHECK ADD  CONSTRAINT [FK_1CLosses3Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1CLosses3Archive] CHECK CONSTRAINT [FK_1CLosses3Archive_Cases]
GO
ALTER TABLE [dbo].[1CMixing6Archive]  WITH CHECK ADD  CONSTRAINT [FK_1CMixing6Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1CMixing6Archive] CHECK CONSTRAINT [FK_1CMixing6Archive_Cases]
GO
ALTER TABLE [dbo].[1COstatki4Archive]  WITH CHECK ADD  CONSTRAINT [FK_1COstatki4Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1COstatki4Archive] CHECK CONSTRAINT [FK_1COstatki4Archive_Cases]
GO
ALTER TABLE [dbo].[1CTcexInOut2Archive]  WITH CHECK ADD  CONSTRAINT [FK_1CTcexInOut2Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1CTcexInOut2Archive] CHECK CONSTRAINT [FK_1CTcexInOut2Archive_Cases]
GO
ALTER TABLE [dbo].[1CToplivo5Archive]  WITH CHECK ADD  CONSTRAINT [FK_1CToplivo5Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1CToplivo5Archive] CHECK CONSTRAINT [FK_1CToplivo5Archive_Cases]
GO
ALTER TABLE [dbo].[1CUnitsInOut1.1Archive]  WITH CHECK ADD  CONSTRAINT [FK_1CUnitsInOut1.1Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1CUnitsInOut1.1Archive] CHECK CONSTRAINT [FK_1CUnitsInOut1.1Archive_Cases]
GO
ALTER TABLE [dbo].[1CUnitsInOut1Archive]  WITH CHECK ADD  CONSTRAINT [FK_1CUnitsInOut1Archive_Cases] FOREIGN KEY([CaseId])
REFERENCES [dbo].[Cases] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[1CUnitsInOut1Archive] CHECK CONSTRAINT [FK_1CUnitsInOut1Archive_Cases]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CLosses3Archive', @level2type=N'COLUMN',@level2name=N'MVZ_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CLosses3Archive', @level2type=N'COLUMN',@level2name=N'MVZ_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CLosses3Archive', @level2type=N'COLUMN',@level2name=N'NOM_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CLosses3Archive', @level2type=N'COLUMN',@level2name=N'NOM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CLosses3Archive', @level2type=N'COLUMN',@level2name=N'KOL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CLosses3Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CMixing6Archive', @level2type=N'COLUMN',@level2name=N'MVZ_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CMixing6Archive', @level2type=N'COLUMN',@level2name=N'MVZ_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Тип' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CMixing6Archive', @level2type=N'COLUMN',@level2name=N'TYP'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CMixing6Archive', @level2type=N'COLUMN',@level2name=N'KOL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CMixing6Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1COstatki4Archive', @level2type=N'COLUMN',@level2name=N'NOM_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1COstatki4Archive', @level2type=N'COLUMN',@level2name=N'NOM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1COstatki4Archive', @level2type=N'COLUMN',@level2name=N'KOL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1COstatki4Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CTcexInOut2Archive', @level2type=N'COLUMN',@level2name=N'NOM_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CTcexInOut2Archive', @level2type=N'COLUMN',@level2name=N'NOM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CTcexInOut2Archive', @level2type=N'COLUMN',@level2name=N'KOL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CTcexInOut2Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CToplivo5Archive', @level2type=N'COLUMN',@level2name=N'NOM_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CToplivo5Archive', @level2type=N'COLUMN',@level2name=N'NOM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CToplivo5Archive', @level2type=N'COLUMN',@level2name=N'KOL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CToplivo5Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1.1Archive', @level2type=N'COLUMN',@level2name=N'NOM_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1.1Archive', @level2type=N'COLUMN',@level2name=N'NOM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1.1Archive', @level2type=N'COLUMN',@level2name=N'KOL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1.1Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Код номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1Archive', @level2type=N'COLUMN',@level2name=N'NOM_KOD'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Наименование номенклатуры' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1Archive', @level2type=N'COLUMN',@level2name=N'NOM_NAME'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Потребленное количество' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1Archive', @level2type=N'COLUMN',@level2name=N'KOL_POTREB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Количество выработки' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1Archive', @level2type=N'COLUMN',@level2name=N'KOL_VIRAB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Идентификатор периода' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'1CUnitsInOut1Archive', @level2type=N'COLUMN',@level2name=N'CaseId'
GO


