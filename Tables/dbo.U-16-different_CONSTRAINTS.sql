﻿CREATE TABLE [dbo].[U-16-different_CONSTRAINTS] (
  [col1] [int] NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  PRIMARY KEY CLUSTERED ([col1]),
  CONSTRAINT [U-16-constr2] CHECK ([col3] IS NOT NULL)
)
ON [PRIMARY]
GO