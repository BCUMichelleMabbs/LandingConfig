IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'CYMRU\Ol078170')
CREATE LOGIN [CYMRU\Ol078170] FROM WINDOWS
GO
CREATE USER [CYMRU\Ol078170] FOR LOGIN [CYMRU\Ol078170]
GO
