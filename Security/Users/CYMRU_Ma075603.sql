IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CYMRU\Ma075603')
CREATE LOGIN [CYMRU\Ma075603] FROM WINDOWS
GO
CREATE USER [CYMRU\Ma075603] FOR LOGIN [CYMRU\Ma075603]
GO
