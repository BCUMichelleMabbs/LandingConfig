IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CYMRU\Ke068888')
CREATE LOGIN [CYMRU\Ke068888] FROM WINDOWS
GO
CREATE USER [CYMRU\Ke068888] FOR LOGIN [CYMRU\Ke068888]
GO
