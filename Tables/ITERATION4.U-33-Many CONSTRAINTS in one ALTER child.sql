﻿SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child] (
  [col8] [int] NOT NULL,
  [col9] [int] NULL,
  [col10] AS ([col8]+(1)) PERSISTED NOT NULL,
  [col11] AS ([col8]+(1)) PERSISTED NOT NULL,
  [col12] AS ([col8]+(1)) PERSISTED NOT NULL,
  [col13] [int] NULL,
  [col14] [int] NULL,
  [col15] [int] NULL,
  PRIMARY KEY CLUSTERED ([col8]),
  UNIQUE ([col8], [col9]),
  CHECK ([col10]<(12))
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child]
  ADD FOREIGN KEY ([col8]) REFERENCES [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] ([col8])
GO

ALTER TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-33-fk_col10_ref__parent(col10)] FOREIGN KEY ([col10]) REFERENCES [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] ([col10]) ON DELETE CASCADE
GO

ALTER TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-33-fk_col11_ref__parent(col11)] FOREIGN KEY ([col11]) REFERENCES [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] ([col11])
GO

ALTER TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-33-fk_col11_ref__parent(col11)1] FOREIGN KEY ([col11]) REFERENCES [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] ([col11])
GO

ALTER TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-33-fk_col12_ref__parent(col12)] FOREIGN KEY ([col12]) REFERENCES [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] ([col12])
GO

ALTER TABLE [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-33-fk_col9_ref__parent(col9)] FOREIGN KEY ([col9]) REFERENCES [ITERATION4].[U-33-Many CONSTRAINTS in one ALTER parent] ([col9])
GO