CREATE TABLE [ITERATION4].[U-25-different_FILLFACTOR] (
  [col1] [int] NULL,
  [col2] [int] NULL,
  [col3] [int] NOT NULL,
  CONSTRAINT [U-25-Constr8] PRIMARY KEY CLUSTERED ([col3]) WITH (FILLFACTOR = 1)
)
ON [PRIMARY]
GO