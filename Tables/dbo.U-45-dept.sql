﻿CREATE TABLE [dbo].[U-45-dept] (
  [deptno] [int] NOT NULL,
  [loc] [varchar](13) NULL DEFAULT (NULL),
  [dname] [varchar](20) NULL DEFAULT (NULL),
  PRIMARY KEY CLUSTERED ([deptno])
)
ON [PRIMARY]
GO