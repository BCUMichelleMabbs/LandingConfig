IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CYMRU\mi140036')
CREATE LOGIN [CYMRU\mi140036] FROM WINDOWS
GO
CREATE USER [CYMRU\mi140036] FOR LOGIN [CYMRU\mi140036]
GO