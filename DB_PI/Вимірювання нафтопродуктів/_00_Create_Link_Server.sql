USE [master]
GO

/****** Object:  LinkedServer [LINKEDAF]    Script Date: 28.10.2020 9:25:16 ******/
EXEC master.dbo.sp_dropserver @server=N'LINKEDAF', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [LINKEDAF]    Script Date: 28.10.2020 9:25:16 ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LINKEDAF', @srvproduct=N'PI_AF', @provider=N'PIOLEDBENT', @datasrc=N'PI AF', @provstr=N'Integrated Security=SSPI; 
', @catalog=N'Configuration'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LINKEDAF',@useself=N'False',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LINKEDAF', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


