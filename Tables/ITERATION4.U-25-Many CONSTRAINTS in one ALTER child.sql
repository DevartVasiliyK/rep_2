CREATE TABLE [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER child] (
  [col1] [int] NOT NULL,
  [col2] [int] NOT NULL,
  [col3] [int] NULL,
  [col4] [int] NULL,
  [col5] [int] NULL CONSTRAINT [default_constraint_col5] DEFAULT (123),
  [col6] [int] NULL,
  [col7] [int] NULL DEFAULT (4),
  [col8] [int] NULL,
  [col9] [int] NULL,
  [col10] [int] NULL,
  [col11] [int] NULL,
  [col12] [int] NULL,
  [col13] [int] NULL,
  [col14] [int] NULL,
  [col15] [int] NULL,
  CONSTRAINT [PK_CONSTRAINT] PRIMARY KEY NONCLUSTERED ([col1], [col2]),
  CONSTRAINT [UK] UNIQUE ([col7]),
  CONSTRAINT [UK_CONSTR] UNIQUE CLUSTERED ([col3]),
  CONSTRAINT [UK_nonclustered_col4 ASC, col5 DESC, col6] UNIQUE ([col4], [col5] DESC, [col6]),
  UNIQUE ([col4]),
  UNIQUE ([col8], [col9]),
  CONSTRAINT [check_constraint_col6] CHECK ([col6] IS NOT NULL),
  CHECK ([col7]>=(4)),
  CHECK ([col10]<(12))
)
ON [PRIMARY]
GO

ALTER TABLE [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER child]
  ADD FOREIGN KEY ([col8]) REFERENCES [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER parent] ([col1])
GO

ALTER TABLE [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [fk_col11_ref__parent(col11)] FOREIGN KEY ([col11]) REFERENCES [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER parent] ([col11]) ON DELETE SET NULL
GO

ALTER TABLE [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER child]
  ADD CONSTRAINT [fk_col12_ref__parent(col12)] FOREIGN KEY ([col12]) REFERENCES [ITERATION4].[U-25-Many CONSTRAINTS in one ALTER parent] ([col12])
GO