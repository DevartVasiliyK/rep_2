﻿CREATE TABLE [dbo].[P-2-_char(100)_uniqueidentifier] (
  [pk_int] [int] NOT NULL,
  [comp_char(100)_uniqueidentifier] [char](100) NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO