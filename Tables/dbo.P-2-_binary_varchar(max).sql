﻿CREATE TABLE [dbo].[P-2-_binary_varchar(max)] (
  [pk_int] [int] NOT NULL,
  [comp_binary_varchar(max)] [binary](1) NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
GO