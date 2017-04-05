CREATE DATABSE monitoring
GO


CREATE TABLE LogonAudit
(
    AuditID INT NOT NULL CONSTRAINT PK_LogonAudit_AuditID 
                PRIMARY KEY CLUSTERED IDENTITY(1,1),
   [SystemUser] [varchar](512) NULL,
   [DBUser] [varchar](512) NULL,
   [APP_NAME] [varchar](512) NULL,
   [SPID] [int] NULL,
   [LogonTime] [datetime] NULL,
   [HOST_NAME] [varchar](512) NULL
);
GO

GRANT INSERT ON LogonAudit TO PUBLIC

CREATE TRIGGER MYLOGONAUDIT
ON  ALL SERVER WITH EXECUTE AS 'sa' FOR LOGON 
AS 
BEGIN
SET NOCOUNT ON
--IF (APP_NAME() not like 'SQLAgent%' OR APP_NAME() not like 'Microsoft SQL Server Management Studio%')
    INSERT INTO monitoring..LogonAudit ([SystemUser], [DBNAME], [APP_NAME], [SPID], [LogonTime], [HOST_NAME] )
		SELECT ORIGINAL_LOGIN(),DB_NAME(),APP_NAME(),@@SPID,GETDATE(),HOST_NAME();
END;

GO

ENABLE TRIGGER MYLOGONAUDIT ON ALL SERVER
--DISABLE TRIGGER MYLOGONAUDIT ON ALL SERVER

--DROP TABLE LogonAudit 
--DROP TRIGGER MYLOGONAUDIT ON ALL SERVER

/*
	Разница по времени (интервал) между двумя строками по столбцу LogonTime

  SELECT t.*, DATEDIFF(SECOND, tnext.LogonTime,t.LogonTime)
  FROM [LogonAudit] t
  JOIN [LogonAudit] tnext
	ON t.[AuditID]=tnext.[AuditID]-1
  
  */
