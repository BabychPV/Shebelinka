USE [PI_Temp]
GO

/****** Object:  Table [dbo].[ReportMidnight]    Script Date: 23.10.2020 10:20:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReportMidnight]') AND type in (N'U'))
DROP TABLE [dbo].[ReportMidnight]
GO

/****** Object:  Table [dbo].[ReportMidnight]    Script Date: 23.10.2020 10:20:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportMidnight](
	[ID] 	bigint NOT NULL  IDENTITY (1, 1),
	[MidnightID] 	bigint NOT NULL,
	[ElementName] nvarchar(30) NULL,
	[TankNumber] nvarchar(10) NULL,
	[Material] nvarchar(30) NULL,
	[Density] nvarchar(30) NULL,
	[HeightTank] nvarchar(30) NULL,
	[LevelWater] nvarchar(30) NULL,
	[Temperature] nvarchar(30) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReportMidnight]
	ADD CONSTRAINT
	[PK_ReportMidnight] PRIMARY KEY CLUSTERED 
	(ID)  WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO




/****** Object:  Table [dbo].[ReportMidnight_Time]    Script Date: 23.10.2020 10:20:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReportMidnight_Time]') AND type in (N'U'))
DROP TABLE [dbo].[ReportMidnight_Time]
GO

/****** Object:  Table [dbo].[ReportMidnight_Time]    Script Date: 23.10.2020 10:20:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportMidnight_Time](
	[ID] 	bigint NOT NULL IDENTITY (1, 1),
	[Date]	datetime NULL default GetDate()

) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReportMidnight_Time]
	ADD CONSTRAINT
	[PK_ReportMidnight_Time] PRIMARY KEY CLUSTERED 
	(ID)  WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO



--Create foreign key on [ReportMidnight] in table 'ReportMidnight_Time'
ALTER TABLE dbo.ReportMidnight
ADD CONSTRAINT [FK_ReportMidnight_ReportMidnight_Time]
    FOREIGN KEY ([MidnightID])
    REFERENCES [dbo].[ReportMidnight_Time]
        ([ID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
GO


USE [PI_Temp]
GO

/****** Object:  StoredProcedure [dbo].[AF_GetReportData]    Script Date: 28.10.2020 8:52:41 ******/
DROP PROCEDURE [dbo].[AF_GetReportData]
GO

/****** Object:  StoredProcedure [dbo].[AF_GetReportData]    Script Date: 28.10.2020 8:52:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Babych P.V
-- Create date: 2020-10-16
-- Last modify: 2020-10-28
-- Description:	Get Element PI AF
-- =============================================
CREATE PROCEDURE [dbo].[AF_GetReportData] 
	@Date nvarchar(24) = '2020-10-26 23:59:59'
AS
BEGIN

	SET NOCOUNT ON;

	
SELECT  [ElementName]
		,[TankNumber]
		,[Material]
		,[Density]
		,[HeightTank]
		,[LevelWater]
		,[Temperature]
FROM [dbo].[ReportMidnight_Time] T1  left join [dbo].[ReportMidnight] T2 on (T1.id = T2.MidnightID and T1.Date=dateadd (ss,59,dateadd (mi,59,dateadd (hh,23,convert (datetime,CAST( convert(datetime, @Date, 120) AS Date ) )))))

END

GO

USE [PI_Temp]
GO

/****** Object:  StoredProcedure [dbo].[AF_TransferDataToLocalServer]    Script Date: 28.10.2020 8:53:10 ******/
DROP PROCEDURE [dbo].[AF_TransferDataToLocalServer]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Babych P.V
-- Create date: 2020-10-16
-- Last modify: 2020-10-28
-- Description:	Transfer Element PI AF
-- =============================================
CREATE PROCEDURE [dbo].[AF_TransferDataToLocalServer] 
AS
BEGIN

	SET NOCOUNT ON;


	declare @Date datetime =  dateadd (ss,59,dateadd (mi,59,dateadd (hh,23,convert (datetime,CAST( GETDATE() AS Date ) ))));
	declare @IDDate bigint = 0;
	

	IF ( OBJECT_ID('tempdb..#TempToPivot') IS NOT NULL)
	DROP TABLE #TempToPivot

	CREATE TABLE #TempToPivot(

	  ElementName nvarchar(30),
	  TankNumber int,
	  AttributeName  nvarchar(100),
	  Value nvarchar(20)

	)


	IF (@Date IS NOT NULL)
	BEGIN
		INSERT INTO [dbo].[ReportMidnight_Time]
		(Date)
		VALUES(@Date);
		SET @IDDate = IDENT_CURRENT('dbo.ReportMidnight_Time');	
		IF (@IDDate IS NOT NULL)
			BEGIN	
				INSERT #TempToPivot (ElementName,TankNumber,AttributeName,Value)
				SELECT convert (nvarchar(30),[ElementName])
					,convert(int,[TankNumber])
					,convert (nvarchar(100),[AttributeName])
					,convert (nvarchar(20),[Value])
				FROM [LINKEDAF].[������].[Asset].ReportOfTank	
				
				INSERT INTO [dbo].[ReportMidnight]
						   ([MidnightID]
						   ,[ElementName]
						   ,[TankNumber]
						   ,[Material]
						   ,[Density]
						   ,[HeightTank]
						   ,[LevelWater]
						   ,[Temperature])
				SELECT @IDDate as ID, ElementName, TankNumber, [Material], [AI_Info02] as [Density] , [AI_Info01] as [HeightTank] , [AI_Info04] as [LevelWater], [AI_Info03] as [Temperature]
				FROM   
				(select ElementName,TankNumber,AttributeName,Value
				FROM #TempToPivot) p  
				PIVOT  
				(MAX (Value)  
				FOR AttributeName IN ( [Material], [AI_Info01], [AI_Info02] , [AI_Info03] , [AI_Info04]  )  
				) AS pvt
				order by pvt.TankNumber


			END

	END	

	DROP TABLE #TempToPivot;
	
END
GO



USE [msdb]
GO


IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'TransferDataToPiTemp')
EXEC msdb.dbo.sp_delete_job @job_name=N'TransferDataToPiTemp', @delete_unused_schedule=1
GO


DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'TransferDataToPiTemp', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'TransferDataToPiTemp', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa1', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'TransferDataToPiTemp', @server_name = N'UPG01SV-PI1S'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'TransferDataToPiTemp', @step_name=N'Step_01', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [dbo].[AF_TransferDataToLocalServer] ', 
		@database_name=N'PI_Temp', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'TransferDataToPiTemp', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'TransferDataToPiTemp', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa1', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'TransferDataToPiTemp', @name=N'Sched_01', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20201028, 
		@active_end_date=99991231, 
		@active_start_time=235958, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
