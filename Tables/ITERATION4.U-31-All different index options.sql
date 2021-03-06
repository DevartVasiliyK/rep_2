﻿SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-31-All different index options] (
  [col1] AS ([col2]+cos(sin((1)+[col3]))) PERSISTED NOT NULL,
  [col2] [int] NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL,
  UNIQUE ([col1]) WITH (FILLFACTOR = 3, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF)
)
ON [PRIMARY]
GO