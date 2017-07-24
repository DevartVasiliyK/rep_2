SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER child] (
  [col1] AS ([col15]+cos(sin((1)))) PERSISTED NOT NULL,
  [col2] [int] NOT NULL,
  [col3] AS ([col13]+(1)),
  [col4] AS ([col13]-(1)),
  [col5] [int] NULL CONSTRAINT [U-31-default_constraint_col5] DEFAULT (123),
  [col6] [int] NULL,
  [col7] [int] NULL DEFAULT (4),
  [col8] AS ((([col15]-(1))+(1))+(1)) PERSISTED,
  [col9] AS (((([col15]-(1))+(1))+(1))+(1)),
  [col10] AS ((((([col15]-(1))+(1))+(1))+(1))+(1)),
  [col11] AS (((((([col15]-(1))+(1))+(1))+(1))+(1))+(1)) PERSISTED,
  [col12] AS ((((((([col15]-(1))+(1))+(1))+(1))+(1))+(1))+(1)) PERSISTED,
  [col13] [int] NULL,
  [col14] [int] NULL,
  [col15] [int] NULL,
  CONSTRAINT [U-31-PK_CONSTRAINT] PRIMARY KEY NONCLUSTERED ([col1], [col2]),
  CONSTRAINT [U-31-UK] UNIQUE ([col7]),
  CONSTRAINT [U-31-UK_CONSTR] UNIQUE CLUSTERED ([col3]),
  CONSTRAINT [U-31-UK_nonclustered_col4 ASC, col5 DESC, col6] UNIQUE ([col4], [col5] DESC, [col6]),
  UNIQUE ([col4]),
  UNIQUE ([col8]),
  UNIQUE ([col8], [col9]),
  UNIQUE ([col12]),
  UNIQUE ([col11]),
  CHECK ([col7]>=(4)),
  CHECK ([col14]<(12)),
  CONSTRAINT [U-31-check_constraint_col6] CHECK ([col6] IS NOT NULL)
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER child]
  ADD FOREIGN KEY ([col8]) REFERENCES [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER parent] ([col1])
GO

ALTER TABLE [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-31-fk_col11_ref__parent(col11)] FOREIGN KEY ([col11]) REFERENCES [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER parent] ([col11]) ON DELETE CASCADE
GO

ALTER TABLE [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [U-31-fk_col12_ref__parent(col12)] FOREIGN KEY ([col12]) REFERENCES [ITERATION4].[U-31-Many CONSTRAINTS in one ALTER parent] ([col12])
GO