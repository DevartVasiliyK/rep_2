CREATE TABLE [dbo].[U-44-emp] (
  [empno] [int] NOT NULL,
  [ename] [varchar](10) NULL DEFAULT (NULL),
  [job] [varchar](9) NULL DEFAULT (NULL),
  [mgr] [int] NULL DEFAULT (NULL),
  [hiredate] [datetime] NULL DEFAULT (NULL),
  [sal] [float] NULL DEFAULT (NULL),
  [comm] [float] NULL DEFAULT (NULL),
  [deptno] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([empno])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[U-44-emp]
  ADD CONSTRAINT [U-44-fk__emp_deptno__dept_deptno] FOREIGN KEY ([deptno]) REFERENCES [dbo].[U-44-dept] ([deptno])
GO