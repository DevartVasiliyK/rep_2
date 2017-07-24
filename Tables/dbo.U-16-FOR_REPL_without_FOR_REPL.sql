﻿CREATE TABLE [dbo].[U-16-FOR_REPL_without_FOR_REPL] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[U-16-FOR_REPL_without_FOR_REPL] WITH NOCHECK
  ADD CHECK NOT FOR REPLICATION ([col3] IS NOT NULL)
GO